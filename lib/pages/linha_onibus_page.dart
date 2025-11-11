import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/theme_service.dart';

class LinhaOnibusPage extends StatefulWidget {
  const LinhaOnibusPage({super.key});

  @override
  State<LinhaOnibusPage> createState() => _LinhaOnibusPageState();
}

class _LinhaOnibusPageState extends State<LinhaOnibusPage> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  final ThemeService _themeService = ThemeService();
  bool _altoContraste = false;
  bool _isAnimating = false; // Flag para controlar animações simultâneas

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
    if (_isPlatformSupported()) {
      _getCurrentLocation();
    } else {
      setState(() {
        _isLoadingLocation = false;
      });
    }
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

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });

      // Anima a câmera de forma segura, evitando múltiplas animações simultâneas
      if (_mapController != null && _currentPosition != null) {
        _safeAnimateCamera(
          CameraUpdate.newLatLng(
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao obter localização: $e'),
            backgroundColor: Colors.orange,
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
        automaticallyImplyLeading: false,
        title: Semantics(
          header: true,
          child: const Text(
            "Linha de Ônibus",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/configuracoes');
            },
            tooltip: 'Configurações',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/welcome',
                (route) => false,
              );
            },
            tooltip: 'Sair',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Mapa
            if (_isPlatformSupported())
              Expanded(
                child: Stack(
                  children: [
                    GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: _kInitialPosition,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                        // Se já temos a localização, centraliza o mapa
                        if (_currentPosition != null) {
                          _safeAnimateCamera(
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
                    // Indicador de carregamento
                    if (_isLoadingLocation)
                      Container(
                        color: Colors.black.withValues(alpha: 0.3),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    // Botão para centralizar na localização
                    // Posicionado à esquerda para não sobrepor os controles de zoom do Google Maps
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.green,
                        onPressed: _getCurrentLocation,
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              // Fallback para plataformas não suportadas
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
            
            // Botões de ação
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Botão Selecionar Linha
                  Semantics(
                    label: 'Botão para selecionar linha de ônibus',
                    button: true,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/selecionarLinha');
                        },
                        child: const Text(
                          "Selecionar Linha",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Botão Ver Mapa
                  Semantics(
                    label: 'Botão para ver mapa de pontos de parada',
                    button: true,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/mapa');
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "Ver Mapa",
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    // Cancela qualquer animação em andamento
    _isAnimating = false;
    // Limpa o controller do mapa de forma segura
    _mapController?.dispose();
    _mapController = null;
    super.dispose();
  }
}
