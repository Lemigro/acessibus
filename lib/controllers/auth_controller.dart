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
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('user-not-found')) {
      return 'Usuário não encontrado';
    } else if (errorStr.contains('wrong-password')) {
      return 'Senha incorreta';
    } else if (errorStr.contains('email-already-in-use')) {
      return 'Este email já está em uso';
    } else if (errorStr.contains('weak-password')) {
      return 'Senha muito fraca';
    } else if (errorStr.contains('invalid-email')) {
      return 'Email inválido';
    } else if (errorStr.contains('network-request-failed') || errorStr.contains('network')) {
      return 'Erro de conexão. Verifique sua internet.';
    } else if (errorStr.contains('popup') || errorStr.contains('blocked')) {
      return 'Popup bloqueado pelo navegador. Permita popups para este site.';
    } else if (errorStr.contains('permission-denied') || errorStr.contains('403')) {
      return 'Erro de permissão. Verifique as configurações do Firebase.';
    }
    
    // Log do erro para debug
    print('Erro de autenticação: $error');
    return 'Erro ao autenticar: ${error.toString()}';
  }
}

