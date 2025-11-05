import 'database_service.dart';
import '../models/linha_onibus_model.dart';

/// Serviço para gerenciar linhas de ônibus
/// 
/// Este serviço será responsável por:
/// - Buscar linhas de ônibus disponíveis
/// - Validar linhas de ônibus
/// - Armazenar linhas favoritas do usuário
class LinhaService {
  static final LinhaService _instance = LinhaService._internal();
  factory LinhaService() => _instance;
  LinhaService._internal();

  final DatabaseService _dbService = DatabaseService();
  final List<String> _linhasFavoritas = [];

  /// Lista de linhas favoritas do usuário
  List<String> get linhasFavoritas => List.unmodifiable(_linhasFavoritas);

  /// Busca linhas de ônibus disponíveis
  /// 
  /// Agora busca do banco de dados local
  Future<List<LinhaOnibus>> buscarLinhas({String? query}) async {
    if (query != null && query.isNotEmpty) {
      return await _dbService.buscarLinhas(query);
    }
    return await _dbService.getAllLinhas();
  }

  /// Busca apenas os números das linhas (para compatibilidade)
  Future<List<String>> buscarNumerosLinhas({String? query}) async {
    final linhas = await buscarLinhas(query: query);
    return linhas.map((linha) => linha.numero).toList();
  }

  /// Valida se uma linha de ônibus existe
  Future<bool> validarLinha(String numero) async {
    final linha = await _dbService.getLinhaByNumero(numero.trim());
    return linha != null;
  }

  /// Obtém uma linha pelo número
  Future<LinhaOnibus?> getLinhaByNumero(String numero) async {
    return await _dbService.getLinhaByNumero(numero);
  }

  /// Adiciona uma linha aos favoritos
  void adicionarFavorita(String linha) {
    if (!_linhasFavoritas.contains(linha)) {
      _linhasFavoritas.add(linha);
    }
  }

  /// Remove uma linha dos favoritos
  void removerFavorita(String linha) {
    _linhasFavoritas.remove(linha);
  }

  /// Verifica se uma linha está nos favoritos
  bool isFavorita(String linha) {
    return _linhasFavoritas.contains(linha);
  }
}

