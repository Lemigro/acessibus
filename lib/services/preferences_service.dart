import 'package:shared_preferences/shared_preferences.dart';

/// Serviço para gerenciar preferências do usuário
class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  // Chaves de preferências
  static const String _keyNome = 'user_nome';
  static const String _keyEmail = 'user_email';
  static const String _keyTamanhoFonte = 'tamanho_fonte';
  static const String _keyDarkTheme = 'dark_theme';
  static const String _keyAltoContraste = 'alto_contraste';
  static const String _keyLeitorTela = 'leitor_tela';
  static const String _keyVibracao = 'vibracao';
  static const String _keySom = 'som';
  static const String _keyLuz = 'luz';
  static const String _keyTamanhoFonteEspecifico = 'tamanho_fonte_especifico';
  static const String _keyDeviceIdFirebase = 'device_id_firebase';
  static const String _keyIpESP8266 = 'ip_esp8266';
  static const String _keyIdOnibusRealtime = 'id_onibus_realtime';

  // Métodos para dados do perfil
  Future<String?> getNome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNome);
  }

  Future<void> setNome(String nome) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNome, nome);
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  Future<void> setEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
  }

  // Métodos para configurações de acessibilidade
  Future<double> getTamanhoFonte() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyTamanhoFonte) ?? 1.0;
  }

  Future<void> setTamanhoFonte(double tamanho) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyTamanhoFonte, tamanho);
  }

  Future<bool> getDarkTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkTheme) ?? false;
  }

  Future<void> setDarkTheme(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkTheme, valor);
  }

  Future<bool> getAltoContraste() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAltoContraste) ?? false;
  }

  Future<void> setAltoContraste(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAltoContraste, valor);
  }

  Future<bool> getLeitorTela() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLeitorTela) ?? true;
  }

  Future<void> setLeitorTela(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLeitorTela, valor);
  }

  Future<bool> getVibracao() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyVibracao) ?? true;
  }

  Future<void> setVibracao(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyVibracao, valor);
  }

  Future<bool> getSom() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySom) ?? true;
  }

  Future<void> setSom(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySom, valor);
  }

  Future<bool> getLuz() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLuz) ?? true;
  }

  Future<void> setLuz(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLuz, valor);
  }

  Future<int> getTamanhoFonteEspecifico() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTamanhoFonteEspecifico) ?? 18;
  }

  Future<void> setTamanhoFonteEspecifico(int tamanho) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTamanhoFonteEspecifico, tamanho);
  }

  // Métodos para configuração do dispositivo
  Future<String?> getDeviceIdFirebase() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDeviceIdFirebase);
  }

  Future<void> setDeviceIdFirebase(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDeviceIdFirebase, deviceId);
  }

  Future<String?> getIpESP8266() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyIpESP8266);
  }

  Future<void> setIpESP8266(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyIpESP8266, ip);
  }

  Future<String?> getIdOnibusRealtime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyIdOnibusRealtime);
  }

  Future<void> setIdOnibusRealtime(String idOnibus) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyIdOnibusRealtime, idOnibus);
  }
}

