import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/services.dart';
import 'preferences_service.dart';

/// Serviço para gerenciar notificações locais e alertas multimodais
class NotificacaoService {
  static final NotificacaoService _instance = NotificacaoService._internal();
  factory NotificacaoService() => _instance;
  NotificacaoService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final PreferencesService _preferences = PreferencesService();
  bool _inicializado = false;

  /// Inicializa o serviço de notificações
  Future<void> inicializar() async {
    if (_inicializado) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _inicializado = true;
  }

  /// Callback quando o usuário toca na notificação
  void _onNotificationTapped(NotificationResponse response) {
    // Pode navegar para uma tela específica se necessário
    print('Notificação tocada: ${response.payload}');
  }

  /// Mostra notificação quando o ônibus está chegando
  /// 
  /// [linha] - Número da linha de ônibus
  /// [distancia] - Distância aproximada (opcional)
  Future<void> notificarOnibusChegando(String linha, {String? distancia}) async {
    await inicializar();

    // Verifica configurações de acessibilidade
    final som = await _preferences.getSom();
    final vibracao = await _preferences.getVibracao();

    // Ativa vibração se configurado
    if (vibracao) {
      await _vibrar();
    }

    // Toca som se configurado
    if (som) {
      await _tocarSom();
    }

    // Mostra notificação visual
    final distanciaTexto = distancia != null ? ' (a $distancia metros)' : '';
    final titulo = 'Ônibus Chegando!';
    final corpo = 'Linha $linha está se aproximando da parada$distanciaTexto';

    const androidDetails = AndroidNotificationDetails(
      'onibus_chegando',
      'Alertas de Ônibus',
      channelDescription: 'Notificações quando o ônibus está chegando',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1,
      titulo,
      corpo,
      details,
      payload: linha,
    );
  }

  /// Ativa vibração no dispositivo
  Future<void> _vibrar() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        // Padrão de vibração: 3 pulsos curtos
        await Vibration.vibrate(pattern: [0, 200, 100, 200, 100, 200]);
      }
    } catch (e) {
      print('Erro ao vibrar: $e');
    }
  }

  /// Toca som de alerta
  Future<void> _tocarSom() async {
    try {
      // Usa o sistema de som do sistema
      // Você pode usar um arquivo de áudio personalizado se necessário
      SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      print('Erro ao tocar som: $e');
    }
  }

  /// Cancela todas as notificações
  Future<void> cancelarTodas() async {
    await _notifications.cancelAll();
  }
}

