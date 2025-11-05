import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/welcome_page.dart';
import 'pages/login_page.dart';
import 'pages/cadastro_page.dart';
import 'pages/linha_onibus_page.dart';
import 'pages/selecionar_linha_page.dart';
import 'pages/mapa_page.dart';
import 'pages/configuracoes_page.dart';
import 'pages/perfil_page.dart';
import 'pages/alerta_onibus_page.dart';
import 'pages/informacoes_onibus_page.dart';
import 'services/notificacao_service.dart';
import 'services/theme_service.dart';
import 'models/linha_onibus_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Força orientação portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Inicializa serviço de notificações
  await NotificacaoService().inicializar();
  
  runApp(const AcessibusApp());
}

class AcessibusApp extends StatefulWidget {
  const AcessibusApp({super.key});

  @override
  State<AcessibusApp> createState() => _AcessibusAppState();
}

class _AcessibusAppState extends State<AcessibusApp> {
  final ThemeService _themeService = ThemeService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarTema();
  }

  Future<void> _carregarTema() async {
    await _themeService.carregarConfiguracoes();
    _themeService.addListener(_onThemeChanged);
    setState(() {
      _isLoading = false;
    });
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        title: 'Acessibus',
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // Garante que o ThemeService está inicializado
    final altoContraste = _themeService.altoContraste ?? false;

    // Garante que todas as rotas estão definidas antes de construir o MaterialApp
    final routes = <String, WidgetBuilder>{
        '/welcome': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/cadastro': (context) => const CadastroPage(),
        '/linhaOnibus': (context) => const LinhaOnibusPage(),
        '/selecionarLinha': (context) => const SelecionarLinhaPage(),
        '/mapa': (context) => const MapaPage(),
        '/configuracoes': (context) => const ConfiguracoesPage(),
        '/perfil': (context) => const PerfilPage(),
        '/alerta': (context) {
          final route = ModalRoute.of(context);
          if (route == null) {
            return const WelcomePage();
          }
          final args = route.settings.arguments as Map<String, dynamic>?;
          return AlertaOnibusPage(
            linha: args?['linha'] ?? '',
            distancia: args?['distancia'],
          );
        },
        '/informacoesOnibus': (context) {
          final route = ModalRoute.of(context);
          if (route == null) {
            return const WelcomePage();
          }
          final args = route.settings.arguments as Map<String, dynamic>?;
          if (args == null || args['linha'] == null) {
            return const WelcomePage();
          }
          final linha = args['linha'];
          if (linha is! LinhaOnibus) {
            return const WelcomePage();
          }
          return InformacoesOnibusPage(
            linha: linha,
          );
        },
      };

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Acessibus',
      home: const WelcomePage(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: altoContraste ? Brightness.dark : Brightness.light,
        ),
        scaffoldBackgroundColor: altoContraste
            ? Colors.black
            : const Color(0xFFF5F5DC),
        useMaterial3: false,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.green),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.green),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      routes: routes,
    );
  }
}
