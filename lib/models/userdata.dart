class UserData {
  final int? id;
  final int userId;
  final int jogosJogados;
  final double totalHoras;
  final String generoFavorito;
  final String jogoMaisHoras;

  UserData({
    this.id,
    required this.userId,
    required this.jogosJogados,
    required this.totalHoras,
    required this.generoFavorito,
    required this.jogoMaisHoras,
  });

  static int? _parseInt(Object? value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseDouble(Object? value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '.'));
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'jogosJogados': jogosJogados,
      'totalHoras': totalHoras,
      'generoFavorito': generoFavorito,
      'jogoMaisHoras': jogoMaisHoras,
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      id: _parseInt(map['id']),
      userId: _parseInt(map['userId']) ?? 0,
      jogosJogados: _parseInt(map['jogosJogados']) ?? 0,
      totalHoras: _parseDouble(map['totalHoras']) ?? 0.0,
      generoFavorito: map['generoFavorito'] ?? '',
      jogoMaisHoras: map['jogoMaisHoras'] ?? '',
    );
  }
}
