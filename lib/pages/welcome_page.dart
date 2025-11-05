import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final ThemeService _themeService = ThemeService();
  bool _altoContraste = false;

  @override
  void initState() {
    super.initState();
    _carregarConfiguracoes();
    _themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  Future<void> _carregarConfiguracoes() async {
    await _themeService.carregarConfiguracoes();
    if (mounted) {
      setState(() {
        _altoContraste = _themeService.altoContraste ?? false;
      });
    }
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {
        _altoContraste = _themeService.altoContraste ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _altoContraste ? Colors.black : const Color(0xFFF5F5DC),
      body: SafeArea(
        child: Column(
          children: [
            // Título verde
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Center(
                child: Semantics(
                  header: true,
                  child: const Text(
                    "Bem-vindo ao Acessibus!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Logo + Botões agrupados
            Column(
              children: [
                // Ícone de ônibus
                Semantics(
                  label: 'Acessibus - Aplicativo de acessibilidade para transporte público',
                  child: const Icon(
                    Icons.directions_bus,
                    size: 100,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 40),

                // Botão Entrar
                Semantics(
                  label: 'Botão para fazer login na aplicação',
                  button: true,
                  child: SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 60, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text(
                        "Entrar",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Botão Cadastrar-se
                Semantics(
                  label: 'Botão para criar uma nova conta',
                  button: true,
                  child: SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/cadastro');
                      },
                      child: const Text(
                        "Cadastrar-se",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Espaço na parte inferior
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

