import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'notificacao_service.dart';

/// Serviço para comunicação com dispositivos IoT via MQTT
/// 
/// Este serviço permite:
/// - Conectar ao broker MQTT
/// - Subscrever tópicos para receber dados do dispositivo
/// - Publicar comandos para o dispositivo
/// - Receber notificações quando o ônibus está chegando
class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  final NotificacaoService _notificacaoService = NotificacaoService();
  MqttServerClient? _client;
  bool _conectado = false;
  bool _monitorando = false;
  String? _linhaSelecionada;
  String? _deviceId;
  
  // Configurações padrão do broker MQTT (carregadas do .env ou valores padrão)
  String get _broker {
    try {
      if (dotenv.isInitialized) {
        return dotenv.env['MQTT_BROKER'] ?? '134.209.9.157';
      }
    } catch (e) {}
    return '134.209.9.157';
  }
  
  int get _port {
    try {
      if (dotenv.isInitialized) {
        return int.tryParse(dotenv.env['MQTT_PORT'] ?? '1883') ?? 1883;
      }
    } catch (e) {}
    return 1883;
  }
  
  String get _username {
    try {
      if (dotenv.isInitialized) {
        return dotenv.env['MQTT_USERNAME'] ?? 'acessibus';
      }
    } catch (e) {}
    return 'acessibus';
  }
  
  String get _password {
    try {
      if (dotenv.isInitialized) {
        return dotenv.env['MQTT_PASSWORD'] ?? '123456';
      }
    } catch (e) {}
    return '123456';
  }
  
  String _clientId = 'acessibus_app_${DateTime.now().millisecondsSinceEpoch}';

  // Tópicos MQTT (conforme códigos Arduino)
  static const String _topicoParadasSolicitacoes = 'paradas/solicitacoes';
  static const String _topicoLocalizacaoOnibus = 'localizacao_onibus';
  
  // Callbacks para notificar quando receber dados
  Function(String linha, double distancia, String alerta)? _onDadosParada;
  Function(String linha, double lat, double lon)? _onLocalizacaoOnibus;

  // Variáveis internas para sobrescrever valores padrão
  String? _brokerOverride;
  int? _portOverride;
  String? _usernameOverride;
  String? _passwordOverride;
  
  String get _brokerValue => _brokerOverride ?? _broker;
  int get _portValue => _portOverride ?? _port;
  String get _usernameValue => _usernameOverride ?? _username;
  String get _passwordValue => _passwordOverride ?? _password;

  /// Configura as credenciais do broker MQTT
  /// 
  /// [broker] - IP ou hostname do broker MQTT
  /// [port] - Porta do broker (padrão: 1883)
  /// [username] - Usuário para autenticação
  /// [password] - Senha para autenticação
  void configurarBroker({
    String? broker,
    int? port,
    String? username,
    String? password,
  }) {
    if (broker != null) _brokerOverride = broker;
    if (port != null) _portOverride = port;
    if (username != null) _usernameOverride = username;
    if (password != null) _passwordOverride = password;
  }

  /// Configura o ID do dispositivo
  /// 
  /// [deviceId] - ID único do dispositivo na parada
  void configurarDeviceId(String deviceId) {
    _deviceId = deviceId;
  }

  /// Configura callback para receber dados da parada
  /// 
  /// [callback] - Função chamada quando receber dados: (linha, distancia, alerta)
  void onDadosParada(Function(String linha, double distancia, String alerta) callback) {
    _onDadosParada = callback;
  }

  /// Configura callback para receber localização do ônibus
  /// 
  /// [callback] - Função chamada quando receber localização: (linha, lat, lon)
  void onLocalizacaoOnibus(Function(String linha, double lat, double lon) callback) {
    _onLocalizacaoOnibus = callback;
  }

  /// Conecta ao broker MQTT
  Future<bool> conectar() async {
    if (_conectado && _client != null) {
      return true;
    }

    try {
      // Cria cliente MQTT
      _client = MqttServerClient.withPort(_brokerValue, _clientId, _portValue);
      _client!.logging(on: false);
      _client!.keepAlivePeriod = 20;
      _client!.autoReconnect = true;
      _client!.onDisconnected = _onDisconnected;
      _client!.onConnected = _onConnected;
      _client!.onSubscribed = _onSubscribed;

      // Configura credenciais
      final connMessage = MqttConnectMessage()
          .withClientIdentifier(_clientId)
          .startClean()
          .withWillQos(MqttQos.atLeastOnce)
          .authenticateAs(_usernameValue, _passwordValue);

      _client!.connectionMessage = connMessage;

      // Conecta
      await _client!.connect();

      if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
        _conectado = true;
        print('MQTT conectado ao broker $_brokerValue:$_portValue');
        return true;
      } else {
        print('Falha ao conectar MQTT: ${_client!.connectionStatus}');
        return false;
      }
    } catch (e) {
      print('Erro ao conectar MQTT: $e');
      _conectado = false;
      return false;
    }
  }

  /// Desconecta do broker MQTT
  Future<void> desconectar() async {
    await pararMonitoramento();
    
    if (_client != null) {
      _client!.disconnect();
      _client = null;
    }
    
    _conectado = false;
  }

  /// Callback quando conecta ao broker
  void _onConnected() {
    print('MQTT: Conectado ao broker');
    _conectado = true;
  }

  /// Callback quando desconecta do broker
  void _onDisconnected() {
    print('MQTT: Desconectado do broker');
    _conectado = false;
  }

  /// Callback quando subscreve em um tópico
  void _onSubscribed(String topic) {
    print('MQTT: Subscrito ao tópico: $topic');
  }

  /// Inicia monitoramento de dados do dispositivo via MQTT
  /// 
  /// Subscreve aos tópicos:
  /// - paradas/solicitacoes/{idOnibus} - dados da parada (distância, alerta)
  /// - localizacao_onibus/linha_{linha} - localização do ônibus (lat, lon)
  /// 
  /// [deviceId] - ID do dispositivo na parada (opcional)
  /// [linha] - Número da linha para monitorar localização (opcional)
  Future<bool> iniciarMonitoramento({
    String? deviceId,
    String? linha,
  }) async {
    if (_monitorando) return true;

    if (deviceId != null) {
      _deviceId = deviceId;
    }

    // Conecta se não estiver conectado
    if (!_conectado) {
      final conectou = await conectar();
      if (!conectou) {
        return false;
      }
    }

    try {
      // Subscreve aos tópicos usando wildcards para receber todas as mensagens
      // Tópico: paradas/solicitacoes/+ (recebe todas as solicitações)
      _client!.subscribe('${_topicoParadasSolicitacoes}/+', MqttQos.atLeastOnce);
      
      // Se uma linha foi especificada, subscreve na localização do ônibus
      if (linha != null && linha.isNotEmpty) {
        final topicoLocalizacao = '$_topicoLocalizacaoOnibus/linha_$linha';
        _client!.subscribe(topicoLocalizacao, MqttQos.atLeastOnce);
        _linhaSelecionada = linha;
        print('MQTT: Subscrito ao tópico de localização: $topicoLocalizacao');
      }

      // Listener para mensagens recebidas
      _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
        final recMess = c![0].payload as MqttPublishMessage;
        final topic = c[0].topic;
        final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        _processarMensagem(topic, payload);
      });

      _monitorando = true;
      print('MQTT: Monitoramento iniciado');
      return true;
    } catch (e) {
      print('Erro ao iniciar monitoramento MQTT: $e');
      _monitorando = false;
      return false;
    }
  }

  /// Processa mensagens recebidas do broker MQTT
  void _processarMensagem(String topic, String payload) {
    try {
      print('MQTT: Mensagem recebida no tópico $topic: $payload');

      // Processa mensagens da parada (paradas/solicitacoes/{idOnibus})
      if (topic.contains(_topicoParadasSolicitacoes)) {
        _processarDadosParada(topic, payload);
      }
      
      // Processa mensagens de localização do ônibus (localizacao_onibus/linha_{linha})
      if (topic.contains(_topicoLocalizacaoOnibus)) {
        _processarLocalizacaoOnibus(topic, payload);
      }
    } catch (e) {
      print('Erro ao processar mensagem MQTT: $e');
    }
  }

  /// Processa dados da parada (paradas/solicitacoes/{idOnibus})
  /// 
  /// Tópico exemplo: paradas/solicitacoes/onibus_132A
  /// Payload exemplo: {"distancia":0.45,"alerta":"ALERTA: Proximo!"}
  void _processarDadosParada(String topic, String payload) {
    try {
      // Extrai o ID do ônibus do tópico (ex: "onibus_132A" de "paradas/solicitacoes/onibus_132A")
      final parts = topic.split('/');
      final idOnibus = parts.length > 2 ? parts[2] : '';
      
      // Extrai o número da linha do ID (ex: "132A" de "onibus_132A")
      String linha = idOnibus;
      if (idOnibus.startsWith('onibus_')) {
        linha = idOnibus.substring(7); // Remove "onibus_"
      }

      // Faz parse do JSON
      final jsonData = jsonDecode(payload) as Map<String, dynamic>;
      final distancia = (jsonData['distancia'] as num?)?.toDouble() ?? 0.0;
      final alerta = jsonData['alerta']?.toString() ?? '';

      print('MQTT: Dados da parada - Linha: $linha, Distância: $distancia m, Alerta: $alerta');

      // Chama callback se configurado
      if (_onDadosParada != null) {
        _onDadosParada!(linha, distancia, alerta);
      }

      // Verifica se o ônibus está próximo (distância < 0.5m conforme código Arduino)
      if (distancia < 0.5 && alerta.toLowerCase().contains('proximo')) {
        _processarAlerta(linha, distancia, alerta);
      }
    } catch (e) {
      print('Erro ao processar dados da parada MQTT: $e');
    }
  }

  /// Processa localização do ônibus (localizacao_onibus/linha_{linha})
  /// 
  /// Tópico exemplo: localizacao_onibus/linha_132A
  /// Payload exemplo: {"lat":-8.047600,"lon":-34.877000}
  void _processarLocalizacaoOnibus(String topic, String payload) {
    try {
      // Extrai o número da linha do tópico (ex: "132A" de "localizacao_onibus/linha_132A")
      final parts = topic.split('/');
      String linha = '';
      if (parts.length > 1) {
        final linhaPart = parts[1];
        if (linhaPart.startsWith('linha_')) {
          linha = linhaPart.substring(6); // Remove "linha_"
        }
      }

      // Faz parse do JSON
      final jsonData = jsonDecode(payload) as Map<String, dynamic>;
      final lat = (jsonData['lat'] as num?)?.toDouble();
      final lon = (jsonData['lon'] as num?)?.toDouble();

      if (lat != null && lon != null) {
        print('MQTT: Localização do ônibus - Linha: $linha, Lat: $lat, Lon: $lon');

        // Chama callback se configurado
        if (_onLocalizacaoOnibus != null) {
          _onLocalizacaoOnibus!(linha, lat, lon);
        }
      }
    } catch (e) {
      print('Erro ao processar localização do ônibus MQTT: $e');
    }
  }

  /// Processa alertas de chegada do ônibus
  Future<void> _processarAlerta(String linha, double distancia, String alerta) async {
    try {
      print('MQTT: Alerta - Linha: $linha, Distância: ${distancia.toStringAsFixed(2)}m');

      // Notifica o usuário
      final distanciaStr = distancia.toStringAsFixed(2);
      await _notificacaoService.notificarOnibusChegando(linha, distancia: distanciaStr);
    } catch (e) {
      print('Erro ao processar alerta MQTT: $e');
    }
  }

  /// Envia a linha de ônibus selecionada para o dispositivo via MQTT
  /// 
  /// NOTA: Atualmente não é usado, pois a parada publica automaticamente
  /// quando o botão é pressionado. Mantido para uso futuro.
  /// 
  /// [linha] - Número ou nome da linha de ônibus
  Future<bool> enviarLinha(String linha) async {
    // Atualmente não implementado, pois a parada envia dados
    // automaticamente quando o botão é pressionado
    _linhaSelecionada = linha;
    return true;
  }

  /// Para o monitoramento do dispositivo
  Future<void> pararMonitoramento() async {
    if (!_monitorando) return;

    try {
      if (_client != null) {
        // Unsubscribe dos tópicos
        _client!.unsubscribe('${_topicoParadasSolicitacoes}/+');
        
        if (_linhaSelecionada != null && _linhaSelecionada!.isNotEmpty) {
          final topicoLocalizacao = '$_topicoLocalizacaoOnibus/linha_${_linhaSelecionada}';
          _client!.unsubscribe(topicoLocalizacao);
        }
      }

      _monitorando = false;
      print('MQTT: Monitoramento parado');
    } catch (e) {
      print('Erro ao parar monitoramento MQTT: $e');
    }
  }

  /// Verifica se o dispositivo está disponível via MQTT
  Future<bool> verificarDisponibilidade() async {
    if (!_conectado) {
      final conectou = await conectar();
      if (!conectou) {
        return false;
      }
    }

    // Se está conectado, assume que está disponível
    return _conectado;
  }

  /// Retorna se está conectado ao broker
  bool get conectado => _conectado;

  /// Retorna se está monitorando
  bool get monitorando => _monitorando;

  /// Retorna a linha selecionada
  String? get linhaSelecionada => _linhaSelecionada;

  /// Retorna o ID do dispositivo configurado
  String? get deviceId => _deviceId;

  /// Retorna o broker configurado
  String get broker => _brokerValue;

  /// Retorna a porta configurada
  int get port => _portValue;
}

