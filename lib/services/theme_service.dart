import 'package:flutter/material.dart';
import 'preferences_service.dart';

/// Serviço para gerenciar o tema da aplicação (dark theme, alto contraste, tamanho de fonte, etc.)
class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  final PreferencesService _prefs = PreferencesService();
  
  bool _darkTheme = false;
  bool _altoContraste = false;
  double _tamanhoFonte = 1.0;
  int _tamanhoFonteEspecifico = 18;
  bool _leitorTela = true;

  bool get darkTheme => _darkTheme;
  bool get altoContraste => _altoContraste;
  double get tamanhoFonte => _tamanhoFonte;
  int get tamanhoFonteEspecifico => _tamanhoFonteEspecifico;
  bool get leitorTela => _leitorTela;

  /// Carrega as configurações salvas
  Future<void> carregarConfiguracoes() async {
    _darkTheme = await _prefs.getDarkTheme();
    _altoContraste = await _prefs.getAltoContraste();
    _tamanhoFonte = await _prefs.getTamanhoFonte();
    _tamanhoFonteEspecifico = await _prefs.getTamanhoFonteEspecifico();
    _leitorTela = await _prefs.getLeitorTela();
    notifyListeners();
  }

  /// Atualiza o dark theme e notifica os listeners
  Future<void> setDarkTheme(bool valor) async {
    await _prefs.setDarkTheme(valor);
    _darkTheme = valor;
    notifyListeners();
  }

  /// Atualiza o alto contraste e notifica os listeners
  Future<void> setAltoContraste(bool valor) async {
    await _prefs.setAltoContraste(valor);
    _altoContraste = valor;
    notifyListeners();
  }

  /// Atualiza o tamanho da fonte e notifica os listeners
  Future<void> setTamanhoFonte(double valor) async {
    await _prefs.setTamanhoFonte(valor);
    final tamanhoEspecifico = (18 * valor).round();
    await _prefs.setTamanhoFonteEspecifico(tamanhoEspecifico);
    _tamanhoFonte = valor;
    _tamanhoFonteEspecifico = tamanhoEspecifico;
    notifyListeners();
  }

  /// Atualiza o leitor de tela e notifica os listeners
  Future<void> setLeitorTela(bool valor) async {
    await _prefs.setLeitorTela(valor);
    _leitorTela = valor;
    notifyListeners();
  }
}

