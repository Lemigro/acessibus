import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../services/theme_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _authController = AuthController();
  final _themeService = ThemeService();
  bool _obscurePassword = true;
  bool _altoContraste = false;

  @override
  void initState() {
    super.initState();
    _carregarConfiguracoes();
    _themeService.addListener(_onThemeChanged);
    _authController.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    _authController.removeListener(_onAuthChanged);
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
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

  void _onAuthChanged() {
    if (mounted) {
      setState(() {});
      if (_authController.isAuthenticated) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/linhaOnibus',
          (route) => false,
        );
      } else if (_authController.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_authController.errorMessage!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _fazerLogin() async {
    if (_formKey.currentState!.validate()) {
      await _authController.login(
        _emailController.text.trim(),
        _senhaController.text,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: _altoContraste ? Colors.black : theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Botão de voltar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Semantics(
                  label: 'Botão para voltar à tela de boas-vindas',
                  button: true,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.green),
                    onPressed: () {
                      Navigator.pushNamed(context, '/welcome');
                    },
                  ),
                ),
              ),
            ),
            // Conteúdo principal
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ícone de ônibus
                        Semantics(
                          label: 'Acessibus - Login',
                          child: const Icon(
                            Icons.directions_bus,
                            size: 80,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Campo de e-mail
                        Semantics(
                          label: 'Campo de e-mail para login',
                          hint: 'Digite seu endereço de e-mail',
                          textField: true,
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.email, color: Colors.green),
                              hintText: "E-mail",
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor, digite seu e-mail';
                              }
                              if (!value.contains('@') || !value.contains('.')) {
                                return 'Por favor, digite um e-mail válido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Campo de senha
                        Semantics(
                          label: 'Campo de senha para login',
                          hint: 'Digite sua senha',
                          textField: true,
                          child: TextFormField(
                            controller: _senhaController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _fazerLogin(),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock, color: Colors.green),
                              hintText: "Senha",
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor, digite sua senha';
                              }
                              if (value.length < 6) {
                                return 'A senha deve ter pelo menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Botão de entrar
                        Semantics(
                          label: 'Botão para fazer login',
                          button: true,
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _authController.isLoading ? null : _fazerLogin,
                              child: _authController.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text("Entrar"),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Texto de cadastro
                        Semantics(
                          label: 'Link para página de cadastro',
                          button: true,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/cadastro');
                            },
                            child: const Text(
                              "Não tem conta? Cadastre-se",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

