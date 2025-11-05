import 'package:flutter/material.dart';
import '../services/linha_service.dart';
import '../models/linha_onibus_model.dart';

/// Controller para gerenciar linhas de ônibus
/// Responsável por coordenar as operações de busca e seleção de linhas
class LinhaController extends ChangeNotifier {
  final LinhaService _linhaService = LinhaService();
  
  List<LinhaOnibus> _linhas = [];
  List<LinhaOnibus> _linhasFiltradas = [];
  bool _isLoading = false;
  String? _errorMessage;
  LinhaOnibus? _linhaSelecionada;
  
  List<LinhaOnibus> get linhas => _linhasFiltradas.isEmpty ? _linhas : _linhasFiltradas;
  List<LinhaOnibus> get linhasFiltradas => _linhasFiltradas;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LinhaOnibus? get linhaSelecionada => _linhaSelecionada;
  
  /// Carrega todas as linhas disponíveis
  Future<void> carregarLinhas() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _linhas = await _linhaService.buscarLinhas();
      _linhasFiltradas = _linhas;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao carregar linhas: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Filtra linhas por query
  Future<void> filtrarLinhas(String query) async {
    if (query.isEmpty) {
      _linhasFiltradas = _linhas;
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      _linhasFiltradas = await _linhaService.buscarLinhas(query: query);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao filtrar linhas: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Seleciona uma linha
  void selecionarLinha(LinhaOnibus linha) {
    _linhaSelecionada = linha;
    notifyListeners();
  }
  
  /// Limpa a seleção
  void limparSelecao() {
    _linhaSelecionada = null;
    notifyListeners();
  }
  
  /// Valida se uma linha existe
  Future<bool> validarLinha(String numero) async {
    try {
      return await _linhaService.validarLinha(numero);
    } catch (e) {
      return false;
    }
  }
  
  /// Busca uma linha pelo número
  Future<LinhaOnibus?> buscarLinhaPorNumero(String numero) async {
    try {
      return await _linhaService.getLinhaByNumero(numero);
    } catch (e) {
      return null;
    }
  }
}

