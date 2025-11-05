import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'notificacao_service.dart';

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
}

/// Serviço para comunicação com dispositivo ESP8266
/// 
/// O ESP8266 pode funcionar de duas formas:
/// 1. Servidor HTTP: ESP8266 cria um servidor HTTP local que o app consulta
/// 2. Cliente HTTP: ESP8266 envia dados para um endpoint (Firebase, servidor próprio, etc.)
class ESP8266Service {
  static final ESP8266Service _instance = ESP8266Service._internal();
  factory ESP8266Service() => _instance;
  ESP8266Service._internal();

  final NotificacaoService _notificacaoService = NotificacaoService();
  Timer? _pollingTimer;
  bool _monitorando = false;
  String? _ipESP8266;
  String? _linhaSelecionada;
  
  // Configuração padrão do ESP8266
  static const int _portaPadrao = 80;
  static const Duration _intervaloPolling = Duration(seconds: 2);

  /// Configura o IP do ESP8266
  /// 
  /// [ip] - IP do ESP8266 (ex: "192.168.1.100")
  void configurarIP(String ip) {
    _ipESP8266 = ip;
  }

  /// Inicia monitoramento via polling HTTP
  /// 
  /// O app consulta periodicamente o ESP8266 para verificar se o ônibus está chegando
  Future<bool> iniciarMonitoramento({String? ip}) async {
    if (_monitorando) return true;

    if (ip != null) {
      _ipESP8266 = ip;
    }

    if (_ipESP8266 == null || _ipESP8266!.isEmpty) {
      // Tenta descobrir o IP automaticamente ou usa um padrão
      // Em produção, você pode usar um serviço de descoberta
      throw Exception('IP do ESP8266 não configurado');
    }

    _monitorando = true;

    // Inicia polling
    _pollingTimer = Timer.periodic(_intervaloPolling, (timer) async {
      await _verificarStatus();
    });

    return true;
  }

  /// Para o monitoramento
  Future<void> pararMonitoramento() async {
    _monitorando = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Verifica o status do ESP8266
  Future<void> _verificarStatus() async {
    if (!_monitorando || _ipESP8266 == null) return;

    try {
      // Endpoint do ESP8266 para verificar status
      final url = Uri.parse('http://$_ipESP8266:$_portaPadrao/status');
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          throw TimeoutException('Timeout ao conectar com ESP8266');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Formato esperado do ESP8266:
        // {
        //   "onibus_chegando": true/false,
        //   "linha": "100",
        //   "distancia": "50" (opcional, em metros)
        // }
        
        if (data['onibus_chegando'] == true) {
          final linha = data['linha']?.toString() ?? '';
          final distancia = data['distancia']?.toString();
          
          if (linha.isNotEmpty && linha != _linhaSelecionada) {
            _linhaSelecionada = linha;
            
            // Notifica o usuário
            await _notificacaoService.notificarOnibusChegando(
              linha,
              distancia: distancia,
            );
          }
        } else {
          // Ônibus não está chegando, reset linha selecionada
          _linhaSelecionada = null;
        }
      }
    } catch (e) {
      // Erro de conexão, mas continua tentando
      print('Erro ao verificar status ESP8266: $e');
    }
  }

  /// Envia a linha selecionada para o ESP8266
  /// 
  /// [linha] - Número da linha de ônibus
  Future<bool> enviarLinha(String linha) async {
    if (_ipESP8266 == null || _ipESP8266!.isEmpty) {
      return false;
    }

    try {
      final url = Uri.parse('http://$_ipESP8266:$_portaPadrao/configurar');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'linha': linha,
        }),
      ).timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          throw TimeoutException('Timeout ao enviar para ESP8266');
        },
      );

      if (response.statusCode == 200) {
        _linhaSelecionada = linha;
        return true;
      }
      
      return false;
    } catch (e) {
      print('Erro ao enviar linha para ESP8266: $e');
      return false;
    }
  }

  /// Verifica se o ESP8266 está disponível
  Future<bool> verificarDisponibilidade() async {
    if (_ipESP8266 == null || _ipESP8266!.isEmpty) {
      return false;
    }

    try {
      final url = Uri.parse('http://$_ipESP8266:$_portaPadrao/ping');
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 2),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Retorna o IP configurado
  String? get ip => _ipESP8266;

  /// Verifica se está monitorando
  bool get isMonitorando => _monitorando;
}

