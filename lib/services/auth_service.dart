import 'package:firebase_database/firebase_database.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'preferences_service.dart';

/// Serviço para gerenciar autenticação do usuário usando Realtime Database
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final PreferencesService _prefs = PreferencesService();

  Map<String, dynamic>? _currentUser;

  /// Retorna o usuário atual
  Map<String, dynamic>? get currentUser => _currentUser;

  /// Login com email e senha
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Busca usuário no Realtime Database
      final emailKey = email.toLowerCase().replaceAll('.', '_').replaceAll('@', '_at_');
      final userRef = _database.child('user').child(emailKey);
      final snapshot = await userRef.get();

      if (!snapshot.exists) {
        throw Exception('user-not-found');
      }

      final userData = snapshot.value as Map<dynamic, dynamic>?;
      if (userData == null) {
        throw Exception('user-not-found');
      }

      // Verifica senha (simples hash SHA256)
      final passwordHash = _hashPassword(password);
      final storedPasswordHash = userData['senha']?.toString();

      if (passwordHash != storedPasswordHash) {
        throw Exception('wrong-password');
      }

      // Login bem-sucedido
      _currentUser = {
        'email': userData['email']?.toString() ?? email,
        'nome': userData['name']?.toString() ?? '',
        'emailKey': emailKey,
      };

      // Salva dados localmente
      await _prefs.setEmail(_currentUser!['email'] as String);
      if (_currentUser!['nome'] != null && _currentUser!['nome'].toString().isNotEmpty) {
        await _prefs.setNome(_currentUser!['nome'] as String);
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Cadastro com email e senha
  Future<bool> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? nome,
  }) async {
    try {
      // Verifica se usuário já existe
      final emailKey = email.toLowerCase().replaceAll('.', '_').replaceAll('@', '_at_');
      final userRef = _database.child('user').child(emailKey);
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        throw Exception('email-already-in-use');
      }

      // Cria hash da senha
      final passwordHash = _hashPassword(password);

      // Salva usuário no Realtime Database
      final userData = {
        'email': email,
        'name': nome ?? '',
        'senha': passwordHash,
        'criadoEm': ServerValue.timestamp,
        'ultimoAcesso': ServerValue.timestamp,
      };

      await userRef.set(userData);

      // Login automático após cadastro
      _currentUser = {
        'email': email,
        'nome': nome ?? '',
        'emailKey': emailKey,
      };

      // Salva dados localmente
      await _prefs.setEmail(email);
      if (nome != null && nome.isNotEmpty) {
        await _prefs.setNome(nome);
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Login com Google (simulado - salva no Realtime Database)
  Future<bool> signInWithGoogle() async {
    try {
      // Por enquanto, desabilitado - precisa de configuração do Google Sign-In
      // Para usar, seria necessário configurar o app Android
      throw Exception('google-sign-in-not-configured');
    } catch (e) {
      rethrow;
    }
  }

  /// Hash simples da senha (SHA256)
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Logout
  Future<void> signOut() async {
    if (_currentUser != null) {
      // Atualiza último acesso
      final emailKey = _currentUser!['emailKey'] as String?;
      if (emailKey != null) {
        try {
          await _database
              .child('user')
              .child(emailKey)
              .child('ultimoAcesso')
              .set(ServerValue.timestamp);
        } catch (e) {
          print('Erro ao atualizar último acesso: $e');
        }
      }
    }

    _currentUser = null;
  }

  /// Verifica se o usuário está autenticado
  bool get isAuthenticated => _currentUser != null;

  /// Carrega usuário salvo localmente (se houver)
  Future<void> loadUserFromPrefs() async {
    try {
      final email = await _prefs.getEmail();
      if (email != null) {
        // Tenta carregar dados do usuário do Realtime Database
        final emailKey = email.toLowerCase().replaceAll('.', '_').replaceAll('@', '_at_');
        final userRef = _database.child('user').child(emailKey);
        final snapshot = await userRef.get();

        if (snapshot.exists) {
          final userData = snapshot.value as Map<dynamic, dynamic>?;
          if (userData != null) {
            _currentUser = {
              'email': userData['email']?.toString() ?? email,
              'nome': userData['name']?.toString() ?? '',
              'emailKey': emailKey,
            };
          }
        }
      }
    } catch (e) {
      print('Erro ao carregar usuário: $e');
    }
  }
}

