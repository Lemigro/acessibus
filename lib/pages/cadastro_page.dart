import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../services/theme_service.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
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
    _nomeController.dispose();
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastro realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
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

  Future<void> _fazerCadastro() async {
    if (_formKey.currentState!.validate()) {
      await _authController.cadastrar(
        _nomeController.text.trim(),
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
                        // Ícone de cadastro
                        Semantics(
                          label: 'Acessibus - Cadastro',
                          child: const Icon(
                            Icons.person_add,
                            size: 80,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Título
                        const Text(
                          "Cadastro",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Campo Nome
                        Semantics(
                          label: 'Campo de nome completo',
                          hint: 'Digite seu nome completo',
                          textField: true,
                          child: TextFormField(
                            controller: _nomeController,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person, color: Colors.green),
                              hintText: "Nome",
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor, digite seu nome';
                              }
                              if (value.trim().length < 3) {
                                return 'O nome deve ter pelo menos 3 caracteres';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Campo Email
                        Semantics(
                          label: 'Campo de e-mail',
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

                        // Campo Senha
                        Semantics(
                          label: 'Campo de senha',
                          hint: 'Digite sua senha',
                          textField: true,
                          child: TextFormField(
                            controller: _senhaController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _fazerCadastro(),
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

                        // Botão Cadastrar
                        Semantics(
                          label: 'Botão para realizar cadastro',
                          button: true,
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _authController.isLoading ? null : _fazerCadastro,
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
                                  : const Text("Cadastrar"),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Texto de já tem conta
                        Semantics(
                          label: 'Link para página de login',
                          button: true,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: const Text.rich(
                              TextSpan(
                                text: "Já tenho conta ",
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                                children: [
                                  TextSpan(
                                    text: "→ Entrar",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
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

