import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notificacao_service.dart';
import 'firebase_realtime_service.dart';

/// Serviço para comunicação com ESP8266 via Firebase
/// 
/// Suporta tanto Firestore quanto Realtime Database
/// O ESP8266 pode enviar dados para qualquer um dos dois
class FirebaseDeviceService {
  static final FirebaseDeviceService _instance = FirebaseDeviceService._internal();
  factory FirebaseDeviceService() => _instance;
  FirebaseDeviceService._internal();

  final NotificacaoService _notificacaoService = NotificacaoService();
  final FirebaseRealtimeService _realtimeService = FirebaseRealtimeService();
  StreamSubscription<DocumentSnapshot>? _firestoreSubscription;
  bool _monitorandoFirestore = false;
  bool _monitorandoRealtime = false;
  String? _deviceId;
  String? _linhaSelecionada;
  String? _idOnibusRealtime; // ID no formato "onibus_132A"

  // Configurações Firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Configura o ID do dispositivo ESP8266
  /// 
  /// [deviceId] - ID único do dispositivo ESP8266 na parada (para Firestore)
  /// [idOnibus] - ID do ônibus no formato "onibus_132A" (para Realtime Database)
  void configurarDeviceId(String deviceId, {String? idOnibus}) {
    _deviceId = deviceId;
    if (idOnibus != null) {
      _idOnibusRealtime = idOnibus;
    }
  }

  /// Inicia monitoramento via Realtime Database (prioridade)
  /// 
  /// Compatível com código Arduino que usa Realtime Database
  /// [idOnibus] - ID no formato "onibus_132A" ou "onibus_251B"
  Future<bool> iniciarMonitoramentoRealtime({String? idOnibus}) async {
    if (_idOnibusRealtime == null && idOnibus == null) {
      return false;
    }

    final id = idOnibus ?? _idOnibusRealtime;
    if (id == null) return false;

    try {
      final iniciado = await _realtimeService.iniciarMonitoramentoRealtime(
        idOnibus: id,
      );
      if (iniciado) {
        _monitorandoRealtime = true;
        _idOnibusRealtime = id;
      }
      return iniciado;
    } catch (e) {
      print('Erro ao iniciar monitoramento Realtime Database: $e');
      return false;
    }
  }

  /// Inicia monitoramento via Firestore
  /// 
  /// Escuta mudanças no documento do dispositivo em tempo real
  Future<bool> iniciarMonitoramentoFirestore({String? deviceId}) async {
    if (_monitorandoFirestore) return true;

    if (deviceId != null) {
      _deviceId = deviceId;
    }

    if (_deviceId == null || _deviceId!.isEmpty) {
      throw Exception('ID do dispositivo não configurado');
    }

    try {
      // Escuta mudanças no documento do dispositivo
      _firestoreSubscription = _firestore
          .collection('dispositivos')
          .doc(_deviceId)
          .snapshots()
          .listen(
        (DocumentSnapshot snapshot) async {
          if (!snapshot.exists) return;

          final data = snapshot.data() as Map<String, dynamic>?;
          if (data == null) return;

          // Verifica se o ônibus está chegando
          final onibusChegando = data['onibus_chegando'] as bool? ?? false;
          final linha = data['linha']?.toString() ?? '';
          final distancia = data['distancia']?.toString();

          if (onibusChegando && linha.isNotEmpty) {
            // Notifica o usuário
            _linhaSelecionada = linha;
            
            await _notificacaoService.notificarOnibusChegando(
              linha,
              distancia: distancia,
            );
            
            // Tenta mostrar tela de alerta se o app estiver em primeiro plano
            // Nota: Para navegação, precisamos do BuildContext ou NavigatorKey
            // Isso será gerenciado pelo widget listener
          } else {
            // Reset quando ônibus não está mais chegando
            if (_linhaSelecionada != null) {
              _linhaSelecionada = null;
            }
          }
        },
        onError: (error) {
          print('Erro ao escutar Firestore: $error');
        },
      );

      _monitorandoFirestore = true;
      return true;
    } catch (e) {
      print('Erro ao iniciar monitoramento Firestore: $e');
      return false;
    }
  }

  /// Inicia monitoramento (tenta Realtime Database primeiro, depois Firestore)
  /// 
  /// [deviceId] - ID do dispositivo para Firestore
  /// [idOnibus] - ID do ônibus para Realtime Database (ex: "onibus_132A")
  Future<bool> iniciarMonitoramento({
    String? deviceId,
    String? idOnibus,
  }) async {
    // Prioridade 1: Realtime Database (compatível com código Arduino)
    if (idOnibus != null && idOnibus.isNotEmpty) {
      final iniciado = await iniciarMonitoramentoRealtime(idOnibus: idOnibus);
      if (iniciado) {
        return true;
      }
    }

    // Prioridade 2: Firestore
    if (deviceId != null && deviceId.isNotEmpty) {
      return await iniciarMonitoramentoFirestore(deviceId: deviceId);
    }

    return false;
  }

  /// Para o monitoramento
  Future<void> pararMonitoramento() async {
    _monitorandoFirestore = false;
    await _firestoreSubscription?.cancel();
    _firestoreSubscription = null;
    await _realtimeService.pararMonitoramento();
    _monitorandoRealtime = false;
  }

  /// Envia a linha selecionada para o Firebase
  /// 
  /// O ESP8266 pode ler essa informação para saber qual linha monitorar
  /// [linha] - Número da linha de ônibus
  /// [userId] - ID do usuário (opcional)
  Future<bool> enviarLinhaSelecionada(String linha, {String? userId}) async {
    if (_deviceId == null || _deviceId!.isEmpty) {
      return false;
    }

    try {
      await _firestore.collection('dispositivos').doc(_deviceId).update({
        'linha_selecionada': linha,
        'usuario_id': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _linhaSelecionada = linha;
      return true;
    } catch (e) {
      print('Erro ao enviar linha para Firebase: $e');
      return false;
    }
  }

  /// Verifica se o dispositivo está disponível
  Future<bool> verificarDisponibilidade() async {
    // Prioridade 1: Verifica Realtime Database
    if (_idOnibusRealtime != null && _idOnibusRealtime!.isNotEmpty) {
      final disponivel = await _realtimeService.verificarDisponibilidade(
        idOnibus: _idOnibusRealtime!,
      );
      if (disponivel) return true;
    }

    // Prioridade 2: Verifica Firestore
    if (_deviceId != null && _deviceId!.isEmpty == false) {
      try {
        final doc = await _firestore
            .collection('dispositivos')
            .doc(_deviceId)
            .get();
        return doc.exists;
      } catch (e) {
        return false;
      }
    }

    return false;
  }

  /// Retorna o ID do dispositivo configurado (Firestore)
  String? get deviceId => _deviceId;

  /// Retorna o ID do ônibus configurado (Realtime Database)
  String? get idOnibusRealtime => _idOnibusRealtime;

  /// Verifica se está monitorando
  bool get isMonitorando => _monitorandoFirestore || _monitorandoRealtime;

  /// Retorna a última linha detectada
  String? get ultimaLinhaDetectada {
    if (_monitorandoRealtime) {
      return _realtimeService.ultimaLinhaDetectada;
    }
    return _linhaSelecionada;
  }
}

