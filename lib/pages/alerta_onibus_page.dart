import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

/// Tela de alerta quando o ônibus está chegando
class AlertaOnibusPage extends StatefulWidget {
  final String linha;
  final String? distancia;

  const AlertaOnibusPage({
    super.key,
    required this.linha,
    this.distancia,
  });

  @override
  State<AlertaOnibusPage> createState() => _AlertaOnibusPageState();
}

class _AlertaOnibusPageState extends State<AlertaOnibusPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final PreferencesService _preferences = PreferencesService();
  bool _altoContraste = false;

  @override
  void initState() {
    super.initState();
    _carregarConfiguracoes();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _carregarConfiguracoes() async {
    final altoContraste = await _preferences.getAltoContraste();
    setState(() {
      _altoContraste = altoContraste;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _altoContraste ? Colors.black : const Color(0xFFF5F5DC),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícone animado
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _altoContraste ? Colors.red : Colors.green,
                      border: Border.all(
                        color: _altoContraste ? Colors.white : Colors.green,
                        width: 4,
                      ),
                    ),
                    child: const Icon(
                      Icons.directions_bus,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Título
                Semantics(
                  header: true,
                  child: Text(
                    'Ônibus Chegando!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _altoContraste ? Colors.white : Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),

                // Linha
                Semantics(
                  label: 'Linha de ônibus que está chegando',
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: _altoContraste
                          ? Colors.grey[900]
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _altoContraste
                            ? Colors.white
                            : Colors.green,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      'Linha ${widget.linha}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _altoContraste
                            ? Colors.white
                            : Colors.green,
                      ),
                    ),
                  ),
                ),

                // Distância (se disponível)
                if (widget.distancia != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Aproximadamente ${widget.distancia} metros',
                    style: TextStyle(
                      fontSize: 18,
                      color: _altoContraste
                          ? Colors.grey[300]
                          : Colors.grey[700],
                    ),
                  ),
                ],

                const SizedBox(height: 60),

                // Botão Fechar
                Semantics(
                  label: 'Botão para fechar o alerta',
                  button: true,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _altoContraste
                            ? Colors.grey[800]
                            : Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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


