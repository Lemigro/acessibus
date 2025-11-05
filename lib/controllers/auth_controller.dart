import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Controller para gerenciar autenticação
/// Responsável por coordenar as operações de login e cadastro
class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  String? _errorMessage;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _authService.currentUser != null;
  
  Map<String, dynamic>? get currentUser => _authService.currentUser;
  
  /// Realiza login com email e senha
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final success = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (success) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Email ou senha incorretos';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Realiza cadastro com email e senha
  Future<bool> cadastrar(String nome, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final success = await _authService.signUpWithEmailAndPassword(
        nome: nome,
        email: email,
        password: password,
      );
      
      if (success) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Erro ao criar conta. Tente novamente.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Realiza logout
  Future<void> logout() async {
    await _authService.signOut();
    notifyListeners();
  }
  
  /// Carrega usuário salvo
  Future<void> loadUser() async {
    await _authService.loadUserFromPrefs();
    notifyListeners();
  }
  
  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('user-not-found')) {
      return 'Usuário não encontrado';
    } else if (error.toString().contains('wrong-password')) {
      return 'Senha incorreta';
    } else if (error.toString().contains('email-already-in-use')) {
      return 'Este email já está em uso';
    } else if (error.toString().contains('weak-password')) {
      return 'Senha muito fraca';
    } else if (error.toString().contains('invalid-email')) {
      return 'Email inválido';
    }
    return 'Erro: ${error.toString()}';
  }
}

