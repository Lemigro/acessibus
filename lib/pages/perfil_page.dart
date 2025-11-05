import 'package:flutter/material.dart';
import '../controllers/perfil_controller.dart';
import '../services/theme_service.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _perfilController = PerfilController();
  final ThemeService _themeService = ThemeService();
  bool _altoContraste = false;

  @override
  void initState() {
    super.initState();
    _carregarConfiguracoes();
    _themeService.addListener(_onThemeChanged);
    _perfilController.addListener(_onPerfilChanged);
    _carregarDados();
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

  void _onPerfilChanged() {
    if (mounted) {
      setState(() {
        _nomeController.text = _perfilController.nome ?? '';
        _emailController.text = _perfilController.email ?? '';
      });
      
      if (_perfilController.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_perfilController.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      } else if (!_perfilController.isSaving && 
                 _perfilController.nome.isNotEmpty && 
                 mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dados salvos com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        // Não fecha automaticamente, permite ao usuário ver a mensagem
      }
    }
  }

  Future<void> _carregarDados() async {
    try {
      await _perfilController.carregarDados();
      if (mounted) {
        setState(() {
          _nomeController.text = _perfilController.nome ?? '';
          _emailController.text = _perfilController.email ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _salvarDados() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    try {
      await _perfilController.salvarDados(
        _nomeController.text.trim(),
        _emailController.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    _perfilController.removeListener(_onPerfilChanged);
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _altoContraste ? Colors.black : const Color(0xFFF5F5DC),
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Voltar',
        ),
        title: Semantics(
          header: true,
          child: const Text(
            "Meu Perfil",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: _perfilController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      // Ícone de perfil
                      Semantics(
                        label: 'Ícone de perfil do usuário',
                        child: const Center(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.green,
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Campo Nome
                      Semantics(
                        label: 'Campo para editar nome do usuário',
                        textField: true,
                        child: TextFormField(
                          controller: _nomeController,
                          decoration: const InputDecoration(
                            labelText: 'Nome',
                            hintText: 'Digite seu nome',
                            prefixIcon: Icon(Icons.person, color: Colors.green),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor, informe seu nome';
                            }
                            if (value.trim().length < 3) {
                              return 'O nome deve ter pelo menos 3 caracteres';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Campo Email
                      Semantics(
                        label: 'Campo para editar email do usuário',
                        textField: true,
                        child: TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'Digite seu email',
                            prefixIcon: Icon(Icons.email, color: Colors.green),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor, informe seu email';
                            }
                            final emailRegex = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                            );
                            if (!emailRegex.hasMatch(value.trim())) {
                              return 'Por favor, informe um email válido';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Botão Salvar
                      Semantics(
                        label: 'Botão para salvar alterações do perfil',
                        button: true,
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _perfilController.isSaving ? null : _salvarDados,
                            child: _perfilController.isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Salvar Alterações',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

