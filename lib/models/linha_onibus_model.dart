/// Modelo de Linha de Ônibus
class LinhaOnibus {
  final int? id;
  final String numero;
  final String nome;
  final String origem;
  final String destino;
  final String? descricao;

  LinhaOnibus({
    this.id,
    required this.numero,
    required this.nome,
    required this.origem,
    required this.destino,
    this.descricao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numero': numero,
      'nome': nome,
      'origem': origem,
      'destino': destino,
      'descricao': descricao,
    };
  }

  factory LinhaOnibus.fromMap(Map<String, dynamic> map) {
    return LinhaOnibus(
      id: map['id'] as int?,
      numero: map['numero'] as String,
      nome: map['nome'] as String,
      origem: map['origem'] as String,
      destino: map['destino'] as String,
      descricao: map['descricao'] as String?,
    );
  }

  LinhaOnibus copyWith({
    int? id,
    String? numero,
    String? nome,
    String? origem,
    String? destino,
    String? descricao,
  }) {
    return LinhaOnibus(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      nome: nome ?? this.nome,
      origem: origem ?? this.origem,
      destino: destino ?? this.destino,
      descricao: descricao ?? this.descricao,
    );
  }

  @override
  String toString() {
    return 'LinhaOnibus(numero: $numero, nome: $nome, origem: $origem, destino: $destino)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LinhaOnibus && other.numero == numero;
  }

  @override
  int get hashCode => numero.hashCode;
}

