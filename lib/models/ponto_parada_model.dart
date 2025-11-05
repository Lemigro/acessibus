/// Modelo de Ponto de Parada
class PontoParada {
  final int? id;
  final String nome;
  final double latitude;
  final double longitude;
  final String? descricao;

  PontoParada({
    this.id,
    required this.nome,
    required this.latitude,
    required this.longitude,
    this.descricao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'latitude': latitude,
      'longitude': longitude,
      'descricao': descricao,
    };
  }

  factory PontoParada.fromMap(Map<String, dynamic> map) {
    return PontoParada(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      descricao: map['descricao'] as String?,
    );
  }

  PontoParada copyWith({
    int? id,
    String? nome,
    double? latitude,
    double? longitude,
    String? descricao,
  }) {
    return PontoParada(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      descricao: descricao ?? this.descricao,
    );
  }

  @override
  String toString() {
    return 'PontoParada(nome: $nome, latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PontoParada && 
           other.nome == nome && 
           other.latitude == latitude && 
           other.longitude == longitude;
  }

  @override
  int get hashCode => nome.hashCode ^ latitude.hashCode ^ longitude.hashCode;
}

