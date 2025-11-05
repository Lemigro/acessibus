import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../services/auth_service.dart';

/// Controller para gerenciar perfil do usuário
/// Responsável por coordenar as operações de visualização e edição do perfil
class PerfilController extends ChangeNotifier {
  final PreferencesService _prefs = PreferencesService();
  final AuthService _authService = AuthService();
  
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String _nome = '';
  String _email = '';
  
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String get nome => _nome;
  String get email => _email;
  
  /// Carrega os dados do perfil
  Future<void> carregarDados() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final nome = await _prefs.getNome();
      final email = await _prefs.getEmail();
      
      _nome = nome ?? '';
      _email = email ?? '';
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao carregar dados: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Salva os dados do perfil
  Future<bool> salvarDados(String nome, String email) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _prefs.setNome(nome);
      await _prefs.setEmail(email);
      
      // Atualiza também no AuthService se o usuário estiver logado
      if (_authService.currentUser != null) {
        // Atualiza no Realtime Database se necessário
      }
      
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao salvar dados: $e';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Atualiza nome
  void atualizarNome(String nome) {
    _nome = nome;
    notifyListeners();
  }
  
  /// Atualiza email
  void atualizarEmail(String email) {
    _email = email;
    notifyListeners();
  }
}

