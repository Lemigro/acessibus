import 'package:flutter/material.dart';
import '../controllers/linha_controller.dart';
import '../services/theme_service.dart';
import '../models/linha_onibus_model.dart';

class SelecionarLinhaPage extends StatefulWidget {
  const SelecionarLinhaPage({super.key});

  @override
  State<SelecionarLinhaPage> createState() => _SelecionarLinhaPageState();
}

class _SelecionarLinhaPageState extends State<SelecionarLinhaPage> {
  final TextEditingController _linhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final LinhaController _linhaControllerMVC = LinhaController();
  final ThemeService _themeService = ThemeService();
  bool _altoContraste = false;

  @override
  void initState() {
    super.initState();
    _carregarConfiguracoes();
    _themeService.addListener(_onThemeChanged);
    _linhaControllerMVC.addListener(_onLinhaChanged);
    _carregarLinhas();
    _linhaController.addListener(_filtrarLinhas);
    // Limpa o campo de texto quando a tela é carregada
    _linhaController.clear();
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

  void _onLinhaChanged() {
    if (mounted) {
      setState(() {});
      if (_linhaControllerMVC.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_linhaControllerMVC.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Limpa o campo quando volta para esta tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _linhaController.clear();
    });
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    _linhaControllerMVC.removeListener(_onLinhaChanged);
    _linhaController.removeListener(_filtrarLinhas);
    _linhaController.dispose();
    super.dispose();
  }

  Future<void> _carregarLinhas() async {
    await _linhaControllerMVC.carregarLinhas();
  }

  void _filtrarLinhas() {
    final query = _linhaController.text;
    _linhaControllerMVC.filtrarLinhas(query);
  }

  void _selecionarLinha(LinhaOnibus linha) {
    // Limpa o campo de texto antes de navegar
    _linhaController.clear();
    Navigator.pushNamed(
      context,
      '/informacoesOnibus',
      arguments: {'linha': linha},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _altoContraste ? Colors.black : Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? Theme.of(context).colorScheme.surface 
            : Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Volta para a tela inicial (linha de ônibus)
            // Se não houver tela anterior, navega diretamente
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/linhaOnibus');
            }
          },
          tooltip: 'Voltar para tela inicial',
        ),
        title: Semantics(
          header: true,
          child: const Text(
            "Selecionar Linha",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Ícone
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 16),
              child: Semantics(
                label: 'Acessibus',
                child: const Icon(
                  Icons.directions_bus,
                  size: 60,
                  color: Colors.green,
                ),
              ),
            ),
            // Campo de busca
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Semantics(
                  label: 'Campo para digitar ou escolher a linha de ônibus',
                  hint: 'Digite o número ou nome da linha',
                  textField: true,
                  child: TextFormField(
                    controller: _linhaController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.directions_bus, color: Colors.green),
                      hintText: "Digite ou escolha a linha",
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, digite uma linha';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.search,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Lista de linhas
            Expanded(
              child: _linhaControllerMVC.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _linhaControllerMVC.linhas.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhuma linha encontrada',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _linhaControllerMVC.linhas.length,
                          itemBuilder: (context, index) {
                            final linha = _linhaControllerMVC.linhas[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 4,
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.directions_bus,
                                  color: Colors.green,
                                  size: 32,
                                ),
                                title: Text(
                                  'Linha ${linha.numero}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Text(
                                  '${linha.origem} → ${linha.destino}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () => _selecionarLinha(linha),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
