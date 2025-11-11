import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../services/database_service.dart';
import '../models/linha_onibus_model.dart';
import '../models/ponto_parada_model.dart';
import '../services/directions_service.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../services/mqtt_service.dart';

class InformacoesOnibusPage extends StatefulWidget {
  final LinhaOnibus linha;

  const InformacoesOnibusPage({
    super.key,
    required this.linha,
  });

  @override
  State<InformacoesOnibusPage> createState() => _InformacoesOnibusPageState();
}

class _InformacoesOnibusPageState extends State<InformacoesOnibusPage> {
  GoogleMapController? _mapController;
  final DirectionsService _directionsService = DirectionsService();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final AuthService _authService = AuthService();
  final ThemeService _themeService = ThemeService();
  final MqttService _mqttService = MqttService();
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  Map<String, dynamic>? _localizacaoOnibus;
  bool _monitorando = false;
  bool _linhaConfirmada = false;
  StreamSubscription? _subscription;
  bool _altoContraste = false;
  bool _isAnimating = false; // Flag para controlar animações simultâneas
  DateTime? _lastMarkerUpdate; // Timestamp da última atualização de marcadores
  Timer? _markerUpdateTimer; // Timer para throttling de atualizações

  // Coordenadas padrão (Recife)
  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(-8.0476, -34.8770),
    zoom: 13.0,
  );

  @override
  void initState() {
    super.initState();
    _carregarConfiguracoes();
    _themeService.addListener(_onThemeChanged);
    _verificarLinhaConfirmada();
    if (_isPlatformSupported()) {
      _getCurrentLocation();
      _carregarRota();
      _iniciarMonitoramento();
    } else {
      setState(() {
        _isLoadingLocation = false;
      });
    }
    // Configura callback MQTT para receber localização em tempo real
    // IMPORTANTE: Configurar ANTES de subscrever para não perder mensagens
    _configurarMqttCallback();
    // Subscreve ao tópico MQTT da linha
    _subscreverMqttLinha();
    
    print('InformacoesOnibusPage: ✅ Inicialização completa - Pronto para receber localização via MQTT');
  }

  Future<void> _verificarLinhaConfirmada() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null || currentUser.isEmpty) return;

      final emailKey = currentUser['emailKey'] as String?;
      if (emailKey == null || emailKey.isEmpty) return;

      final linhaRef = _database.child('user').child(emailKey).child('linhaSelecionada');
      final snapshot = await linhaRef.get();

      if (snapshot.exists && snapshot.value != null) {
        final linhaData = snapshot.value as Map<dynamic, dynamic>;
        final linhaNumero = linhaData['numero'] as String?;
        
        if (linhaNumero == widget.linha.numero) {
          setState(() {
            _linhaConfirmada = true;
          });
        }
      }
    } catch (e) {
      // Silenciosamente ignora erros
    }
  }

  Future<void> _carregarConfiguracoes() async {
    await _themeService.carregarConfiguracoes();
    setState(() {
      _altoContraste = _themeService.altoContraste;
    });
  }

  void _onThemeChanged() {
    setState(() {
      _altoContraste = _themeService.altoContraste;
    });
  }

  /// Formata timestamp para exibição
  String _formatarTimestamp(dynamic timestamp) {
    try {
      if (timestamp == null) return 'N/A';
      final int ts = timestamp is int ? timestamp : timestamp as int;
      final dateTime = DateTime.fromMillisecondsSinceEpoch(ts);
      final agora = DateTime.now();
      final diferenca = agora.difference(dateTime);
      
      if (diferenca.inSeconds < 60) {
        return 'há ${diferenca.inSeconds}s';
      } else if (diferenca.inMinutes < 60) {
        return 'há ${diferenca.inMinutes}min';
      } else {
        return 'há ${diferenca.inHours}h';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    _subscription?.cancel();
    _pararMonitoramento();
    // Remove callback MQTT (define como função vazia)
    _mqttService.onLocalizacaoOnibus((String linha, double lat, double lon) {
      // Callback removido - não faz nada
    });
    // Cancela timer de atualização de marcadores
    _markerUpdateTimer?.cancel();
    // Cancela qualquer animação em andamento
    _isAnimating = false;
    // Limpa o controller do mapa de forma segura
    _mapController?.dispose();
    _mapController = null;
    super.dispose();
  }

  /// Verifica se a plataforma suporta Google Maps
  bool _isPlatformSupported() {
    if (kIsWeb) return false;
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    return true;
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;
      
      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });

      if (!mounted) return;
      _updateMarkers();
      
      // Anima a câmera de forma segura, evitando múltiplas animações simultâneas
      if (mounted) {
        _safeAnimateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoadingLocation = false;
      });
      
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao obter localização: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _carregarRota() async {
    try {
      if (!mounted) return;
      
      // Buscar pontos de parada da linha (simulado)
      // Em produção, você buscaria da tabela linha_ponto
      final DatabaseService dbService = DatabaseService();
      final pontos = await dbService.getAllPontos();
      
      if (!mounted) return;
      
      // Filtrar pontos relacionados à linha (simulado)
      List<PontoParada> pontosLinha = pontos.where((ponto) {
        return ponto.nome.toLowerCase().contains(widget.linha.origem.toLowerCase()) ||
            ponto.nome.toLowerCase().contains(widget.linha.destino.toLowerCase());
      }).toList();

      if (pontosLinha.isEmpty) {
        pontosLinha = pontos.take(2).toList();
      }

      if (pontosLinha.length < 2) {
        return;
      }

      final origin = LatLng(
        pontosLinha.first.latitude,
        pontosLinha.first.longitude,
      );
      final destination = LatLng(
        pontosLinha.last.latitude,
        pontosLinha.last.longitude,
      );

      List<LatLng>? waypoints;
      if (pontosLinha.length > 2) {
        waypoints = pontosLinha
            .sublist(1, pontosLinha.length - 1)
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList();
      }

      final result = await _directionsService.getRoute(
        origin: origin,
        destination: destination,
        waypoints: waypoints,
        travelMode: 'transit',
      );

      if (!mounted) return;

      if (result != null && result.points.isNotEmpty) {
        setState(() {
          _polylines = {
            Polyline(
              polylineId: PolylineId('rota_${widget.linha.numero}'),
              points: result.points,
              color: Colors.blue,
              width: 5,
              patterns: [],
            ),
          };
        });

        if (result.bounds != null && mounted) {
          _safeAnimateCamera(
            CameraUpdate.newLatLngBounds(result.bounds!, 100),
          );
        }
      }
    } catch (e) {
      // Ignora erros de API (INVALID_REQUEST é comum quando não há rota válida)
      if (e.toString().contains('INVALID_REQUEST')) {
        print('InformacoesOnibusPage: Rota não disponível para esta linha (normal)');
        return;
      }
      
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar rota: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  /// Atualiza os marcadores do mapa com throttling para evitar atualizações muito frequentes
  void _updateMarkers({bool animateCamera = false}) {
    // Throttling: só atualiza marcadores no máximo a cada 500ms
    final now = DateTime.now();
    if (_lastMarkerUpdate != null && 
        now.difference(_lastMarkerUpdate!).inMilliseconds < 500) {
      // Agenda atualização para depois
      _markerUpdateTimer?.cancel();
      _markerUpdateTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          _updateMarkers(animateCamera: animateCamera);
        }
      });
      return;
    }

    _lastMarkerUpdate = now;
    _markerUpdateTimer?.cancel();

    Set<Marker> markers = {};

    // Marcar localização atual do usuário
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
          infoWindow: const InfoWindow(title: 'Sua Localização'),
        ),
      );
    }

    // Marcar localização do ônibus (se disponível)
    if (_localizacaoOnibus != null) {
      final lat = _localizacaoOnibus!['latitude']?.toDouble();
      final lng = _localizacaoOnibus!['longitude']?.toDouble();
      
      if (lat != null && lng != null) {
        markers.add(
          Marker(
            markerId: const MarkerId('onibus_location'),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(
              title: 'Ônibus ${widget.linha.numero}',
              snippet: 'Localização em tempo real',
            ),
          ),
        );

        // Só anima a câmera se explicitamente solicitado (não automaticamente)
        if (animateCamera) {
          _safeAnimateCamera(
            CameraUpdate.newLatLng(LatLng(lat, lng)),
          );
        }
      }
    }

    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }
  }

  /// Configura callback MQTT para receber localização em tempo real
  void _configurarMqttCallback() {
    print('InformacoesOnibusPage: ========== CONFIGURANDO CALLBACK MQTT ==========');
    print('InformacoesOnibusPage: Linha esperada: "${widget.linha.numero}"');
    
    _mqttService.onLocalizacaoOnibus((String linha, double lat, double lon) {
      print('InformacoesOnibusPage: ========== CALLBACK MQTT EXECUTADO ==========');
      print('InformacoesOnibusPage: 📍 Localização recebida via MQTT!');
      print('InformacoesOnibusPage: Linha recebida: "$linha"');
      print('InformacoesOnibusPage: Linha esperada: "${widget.linha.numero}"');
      print('InformacoesOnibusPage: Lat: $lat, Lon: $lon');
      print('InformacoesOnibusPage: Widget montado: $mounted');
      
      // Compara linhas de forma case-insensitive
      final linhaRecebida = linha.trim().toUpperCase();
      final linhaEsperada = widget.linha.numero.trim().toUpperCase();
      
      print('InformacoesOnibusPage: Comparando "$linhaRecebida" com "$linhaEsperada"');
      print('InformacoesOnibusPage: São iguais? ${linhaRecebida == linhaEsperada}');
      
      // Só processa se for a linha atual
      if (linhaRecebida == linhaEsperada) {
        print('InformacoesOnibusPage: ✅ Linha corresponde! Atualizando localização...');
        
        if (!mounted) {
          print('InformacoesOnibusPage: ⚠️ Widget não está montado, ignorando atualização');
          return;
        }
        
        print('InformacoesOnibusPage: Chamando setState...');
        setState(() {
          _localizacaoOnibus = {
            'latitude': lat,
            'longitude': lon,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'fonte': 'mqtt', // Indica que veio do MQTT
          };
        });
        
        print('InformacoesOnibusPage: ✅ Estado atualizado com localização: Lat=$lat, Lon=$lon');
        print('InformacoesOnibusPage: _localizacaoOnibus agora é: $_localizacaoOnibus');
        
        // Atualiza marcadores sem animar câmera automaticamente
        if (mounted) {
          print('InformacoesOnibusPage: Atualizando marcadores...');
          _updateMarkers(animateCamera: false);
          print('InformacoesOnibusPage: ✅ Marcadores atualizados no mapa');
        }
        
        print('InformacoesOnibusPage: ===========================================');
      } else {
        print('InformacoesOnibusPage: ⏭️ Linha não corresponde (recebida: "$linhaRecebida", esperada: "$linhaEsperada")');
        print('InformacoesOnibusPage: ===========================================');
      }
    });
    
    print('InformacoesOnibusPage: ✅ Callback MQTT configurado com sucesso');
    print('InformacoesOnibusPage: ===========================================');
  }

  /// Subscreve ao tópico MQTT da linha para receber localização em tempo real
  Future<void> _subscreverMqttLinha() async {
    try {
      print('InformacoesOnibusPage: Subscrevendo ao tópico MQTT da linha ${widget.linha.numero}');
      
      // Verifica se o MQTT já está conectado e monitorando
      if (!_mqttService.conectado) {
        print('InformacoesOnibusPage: MQTT não está conectado, aguardando conexão...');
        // Aguarda um pouco para garantir que o MQTT inicializou
        await Future.delayed(const Duration(seconds: 2));
      }
      
      // Reinicia monitoramento com a linha específica para subscrever ao tópico
      final sucesso = await _mqttService.iniciarMonitoramento(linha: widget.linha.numero);
      
      if (sucesso) {
        print('InformacoesOnibusPage: ✅ Subscrito ao tópico localizacao_onibus/linha_${widget.linha.numero}');
        print('InformacoesOnibusPage: ✅ MQTT está conectado: ${_mqttService.conectado}');
        print('InformacoesOnibusPage: ✅ MQTT está monitorando: ${_mqttService.monitorando}');
      } else {
        print('InformacoesOnibusPage: ❌ Falha ao subscrever ao tópico MQTT');
      }
    } catch (e, stackTrace) {
      print('InformacoesOnibusPage: ❌ Erro ao subscrever ao tópico MQTT: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> _iniciarMonitoramento() async {
    if (_monitorando) return;

    setState(() {
      _monitorando = true;
    });

    try {
      // Buscar localização do ônibus via Firebase Realtime Database (fallback)
      final idOnibus = 'onibus_${widget.linha.numero}';
      
      // Listener para mudanças na localização do ônibus
      // Usa throttling para evitar atualizações muito frequentes
      _subscription = _database
          .child('dados')
          .child(idOnibus)
          .onValue
          .listen((event) {
        if (event.snapshot.exists && mounted) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            // Atualiza dados sem animar câmera automaticamente
            setState(() {
              _localizacaoOnibus = Map<String, dynamic>.from(
                data.map((key, value) => MapEntry(key.toString(), value)),
              );
            });
            // Atualiza marcadores sem animar câmera (throttling já está dentro)
            _updateMarkers(animateCamera: false);
          }
        }
      });
    } catch (e) {
      setState(() {
        _monitorando = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao monitorar ônibus: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _pararMonitoramento() {
    _subscription?.cancel();
    _subscription = null;
    _markerUpdateTimer?.cancel();
    setState(() {
      _monitorando = false;
      _localizacaoOnibus = null;
    });
    _updateMarkers();
  }

  /// Anima a câmera de forma segura, evitando múltiplas animações simultâneas
  /// que podem causar problemas com buffers de imagem no Android
  Future<void> _safeAnimateCamera(CameraUpdate update) async {
    if (_mapController == null || _isAnimating || !mounted) return;
    
    try {
      _isAnimating = true;
      await _mapController!.animateCamera(update);
    } catch (e) {
      // Ignora erros de animação se o widget foi desmontado
      if (mounted) {
        debugPrint('Erro ao animar câmera: $e');
      }
    } finally {
      // Aguarda um delay maior antes de permitir nova animação (aumentado para 800ms)
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _isAnimating = false;
        }
      });
    }
  }

  Future<void> _confirmarLinha() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null || currentUser.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Você precisa estar logado para confirmar uma linha'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final emailKey = currentUser['emailKey'] as String?;
      if (emailKey == null || emailKey.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao obter dados do usuário'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Salva a linha selecionada no Firebase
      final linhaData = {
        'numero': widget.linha.numero,
        'nome': widget.linha.nome,
        'origem': widget.linha.origem,
        'destino': widget.linha.destino,
        'confirmadoEm': ServerValue.timestamp,
      };

      await _database
          .child('user')
          .child(emailKey)
          .child('linhaSelecionada')
          .set(linhaData);

      setState(() {
        _linhaConfirmada = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Linha ${widget.linha.numero} selecionada! Você será notificado quando o ônibus chegar.',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Volta para a tela inicial após confirmar
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/linhaOnibus',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao confirmar linha: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _altoContraste ? Colors.black : Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? Theme.of(context).colorScheme.surface 
            : Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Volta para a tela anterior (selecionar linha)
            Navigator.pop(context);
          },
          tooltip: 'Voltar para selecionar linha',
        ),
        title: Semantics(
          header: true,
          child: Text(
            'Linha ${widget.linha.numero}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _monitorando ? Icons.location_on : Icons.location_off,
              color: Colors.white,
            ),
            onPressed: _monitorando ? _pararMonitoramento : _iniciarMonitoramento,
            tooltip: _monitorando ? 'Parar monitoramento' : 'Iniciar monitoramento',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Informações do ônibus
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).cardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.directions_bus,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Linha ${widget.linha.numero}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              widget.linha.nome,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.blue.withOpacity(0.2)
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Origem',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.linha.origem,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.green,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.green.withOpacity(0.2)
                                : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Destino',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.linha.destino,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_localizacaoOnibus != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.red.withOpacity(0.2)
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Localização do Ônibus',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Indicador de fonte (MQTT ou Firebase)
                                    if (_localizacaoOnibus!['fonte'] == 'mqtt')
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'MQTT',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Lat: ${_localizacaoOnibus!['latitude']?.toStringAsFixed(6) ?? 'N/A'}, '
                                  'Lng: ${_localizacaoOnibus!['longitude']?.toStringAsFixed(6) ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_localizacaoOnibus!['timestamp'] != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Atualizado: ${_formatarTimestamp(_localizacaoOnibus!['timestamp'])}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (_monitorando)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.red,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ] else if (_monitorando) ...[
                    // Mostra indicador de espera quando está monitorando mas ainda não recebeu localização
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.orange.withOpacity(0.2)
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.orange,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Aguardando localização do ônibus via MQTT...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Mapa
            if (_isPlatformSupported())
              Expanded(
                child: Stack(
                  children: [
                    GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: _kInitialPosition,
                      markers: _markers,
                      polylines: _polylines,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: true,
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                        if (_currentPosition != null) {
                          controller.animateCamera(
                            CameraUpdate.newLatLng(
                              LatLng(
                                _currentPosition!.latitude,
                                _currentPosition!.longitude,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    if (_isLoadingLocation)
                      Container(
                        color: Colors.black.withValues(alpha: 0.3),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    // Botão para centralizar na localização (lado esquerdo para não sobrepor zoom)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.green,
                        onPressed: _getCurrentLocation,
                        tooltip: 'Centralizar na minha localização',
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Botão para centralizar no ônibus (se disponível, lado esquerdo)
                    if (_localizacaoOnibus != null)
                      Positioned(
                        bottom: 80,
                        left: 16,
                        child: FloatingActionButton(
                          mini: true,
                          backgroundColor: Colors.red,
                          onPressed: () {
                            final lat = _localizacaoOnibus!['latitude']?.toDouble();
                            final lng = _localizacaoOnibus!['longitude']?.toDouble();
                            if (lat != null && lng != null) {
                              // Atualiza marcadores e anima câmera quando o usuário clica no botão
                              _updateMarkers(animateCamera: true);
                            }
                          },
                          tooltip: 'Centralizar no ônibus',
                          child: const Icon(
                            Icons.directions_bus,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.map,
                        size: 80,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Mapa disponível apenas em Android e iOS',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Botão Confirmar Linha
            if (!_linhaConfirmada)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Semantics(
                  label: 'Botão para selecionar esta linha de ônibus',
                  button: true,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _confirmarLinha,
                      icon: const Icon(Icons.check_circle, size: 24),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Selecionar Linha ${widget.linha.numero}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(24.0),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.green.withOpacity(0.2)
                                : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green, width: 2),
                          ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Linha Selecionada',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              'Você será notificado quando o ônibus chegar',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

