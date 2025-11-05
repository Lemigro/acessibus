import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'notificacao_service.dart';

/// Serviço para comunicação com ESP8266 via Firebase Realtime Database
/// 
/// Compatível com o código Arduino que envia dados para:
/// /dados/{idOnibus}/distancia
/// /dados/{idOnibus}/alerta
/// /dados/{idOnibus}/onibus
class FirebaseRealtimeService {
  static final FirebaseRealtimeService _instance = FirebaseRealtimeService._internal();
  factory FirebaseRealtimeService() => _instance;
  FirebaseRealtimeService._internal();

  final NotificacaoService _notificacaoService = NotificacaoService();
  StreamSubscription<DatabaseEvent>? _realtimeSubscription;
  bool _monitorando = false;
  String? _linhaMonitorada;
  String? _linhaSelecionada;

  // Configurações Firebase
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Inicia monitoramento de uma linha de ônibus no Realtime Database
  /// 
  /// [idOnibus] - ID do ônibus no formato "onibus_132A" ou "onibus_251B"
  /// Este formato corresponde ao código Arduino
  Future<bool> iniciarMonitoramentoRealtime({required String idOnibus}) async {
    if (_monitorando) {
      // Se já está monitorando outra linha, para primeiro
      await pararMonitoramento();
    }

    _linhaMonitorada = idOnibus;

    try {
      // Escuta mudanças no caminho /dados/{idOnibus}
      final path = 'dados/$idOnibus';
      _realtimeSubscription = _database.child(path).onValue.listen(
        (DatabaseEvent event) {
          if (event.snapshot.value == null) return;

          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data == null) return;

          // Extrai dados
          final distancia = data['distancia']?.toString();
          final alerta = data['alerta']?.toString() ?? '';
          final onibus = data['onibus']?.toString() ?? '';

          // Converte distância para double
          double? distanciaNum;
          if (distancia != null) {
            try {
              distanciaNum = double.parse(distancia);
            } catch (e) {
              print('Erro ao converter distância: $e');
            }
          }

          // Verifica se o ônibus está próximo (distância < 0.5m conforme código Arduino)
          final onibusProximo = distanciaNum != null && distanciaNum < 0.5;

          if (onibusProximo && onibus.isNotEmpty) {
            // Extrai número da linha do ID (ex: "onibus_132A" -> "132A")
            String linha = onibus;
            if (onibus.startsWith('onibus_')) {
              linha = onibus.substring(7); // Remove "onibus_"
            }

            _linhaSelecionada = linha;

            // Notifica o usuário
            _notificacaoService.notificarOnibusChegando(
              linha,
              distancia: distanciaNum != null ? '${distanciaNum.toStringAsFixed(2)}m' : null,
            );
          } else if (!onibusProximo) {
            // Reset quando ônibus não está mais próximo
            if (_linhaSelecionada != null) {
              _linhaSelecionada = null;
            }
          }
        },
        onError: (error) {
          print('Erro ao escutar Realtime Database: $error');
        },
      );

      _monitorando = true;
      return true;
    } catch (e) {
      print('Erro ao iniciar monitoramento Realtime Database: $e');
      return false;
    }
  }

  /// Para o monitoramento
  Future<void> pararMonitoramento() async {
    _monitorando = false;
    await _realtimeSubscription?.cancel();
    _realtimeSubscription = null;
    _linhaMonitorada = null;
  }

  /// Verifica se o dispositivo está disponível
  /// 
  /// Verifica se existe dados no caminho /dados/{idOnibus}
  Future<bool> verificarDisponibilidade({required String idOnibus}) async {
    try {
      final path = 'dados/$idOnibus';
      final snapshot = await _database.child(path).get();
      return snapshot.exists;
    } catch (e) {
      print('Erro ao verificar disponibilidade Realtime Database: $e');
      return false;
    }
  }

  /// Retorna a linha monitorada
  String? get linhaMonitorada => _linhaMonitorada;

  /// Retorna a última linha detectada
  String? get ultimaLinhaDetectada => _linhaSelecionada;

  /// Verifica se está monitorando
  bool get isMonitorando => _monitorando;
}

