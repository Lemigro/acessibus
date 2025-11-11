import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
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
    if (_inicializado) {
      print('NotificaçãoService: Já inicializado');
      return;
    }

    try {
      print('NotificaçãoService: Inicializando...');
      
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

      final initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized != null) {
        print('NotificaçãoService: ✅ Inicializado com sucesso');
        _inicializado = true;
      } else {
        print('NotificaçãoService: ⚠️ Inicialização retornou null');
        _inicializado = true; // Tenta mesmo assim
      }
    } catch (e, stackTrace) {
      print('NotificaçãoService: ❌ Erro ao inicializar: $e');
      print('Stack trace: $stackTrace');
      _inicializado = true; // Tenta mesmo assim para não bloquear
    }
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
      // Verifica se o dispositivo tem vibrator disponível
      final bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
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

  /// Mostra notificação quando um botão é pressionado na parada
  /// 
  /// [linha] - Número da linha de ônibus
  /// [tipoDeficiencia] - "visual" ou "auditivo"
  /// [mensagem] - Mensagem de alerta
  Future<void> notificarAlertaBotao(
    String linha, {
    required String tipoDeficiencia,
    String? mensagem,
  }) async {
    try {
      print('NotificaçãoService: Preparando notificação de botão - Linha: $linha, Tipo: $tipoDeficiencia');
      
      await inicializar();

      final tipo = tipoDeficiencia.toLowerCase();
      final isVisual = tipo == 'visual';
      final isAuditivo = tipo == 'auditivo';

      print('NotificaçãoService: Tipo processado - Visual: $isVisual, Auditivo: $isAuditivo');

      // Para deficiência visual: vibração forte e repetida
      if (isVisual) {
        print('NotificaçãoService: Ativando vibração intensa...');
        await _vibrarIntenso();
      }

      // Para deficiência auditiva: som alto e repetido
      if (isAuditivo) {
        print('NotificaçãoService: Tocando som intenso...');
        await _tocarSomIntenso();
      }

      // Mostra notificação visual
      final titulo = isVisual 
          ? '🚌 Alerta Visual - Linha $linha'
          : '🔊 Alerta Auditivo - Linha $linha';
      
      final corpo = mensagem ?? 
          (isVisual 
              ? 'Ônibus da linha $linha está chegando! (Alerta Visual)'
              : 'Ônibus da linha $linha está chegando! (Alerta Auditivo)');

      print('NotificaçãoService: Título: $titulo');
      print('NotificaçãoService: Corpo: $corpo');

      const androidDetails = AndroidNotificationDetails(
        'alerta_botao',
        'Alertas de Botões',
        channelDescription: 'Notificações quando botões são pressionados na parada',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
        showWhen: true,
        enableLights: true,
        color: Colors.green,
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

      print('NotificaçãoService: Exibindo notificação...');
      await _notifications.show(
        2,
        titulo,
        corpo,
        details,
        payload: '$linha|$tipoDeficiencia',
      );
      
      print('NotificaçãoService: ✅ Notificação exibida com sucesso!');
    } catch (e, stackTrace) {
      print('NotificaçãoService: ❌ Erro ao exibir notificação: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// Ativa vibração intensa para deficiência visual
  Future<void> _vibrarIntenso() async {
    try {
      final bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        // Padrão de vibração intensa: 5 pulsos longos e fortes
        await Vibration.vibrate(pattern: [0, 500, 200, 500, 200, 500, 200, 500, 200, 500]);
      }
    } catch (e) {
      print('Erro ao vibrar intensamente: $e');
    }
  }

  /// Toca som intenso para deficiência auditiva
  Future<void> _tocarSomIntenso() async {
    try {
      // Toca o som de alerta 3 vezes com intervalo
      for (int i = 0; i < 3; i++) {
        SystemSound.play(SystemSoundType.alert);
        if (i < 2) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
    } catch (e) {
      print('Erro ao tocar som intenso: $e');
    }
  }

  /// Cancela todas as notificações
  Future<void> cancelarTodas() async {
    await _notifications.cancelAll();
  }
}

