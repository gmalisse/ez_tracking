class Gameplay {
  final int? id;
  final int usersId;
  final int jogosId;
  final double horasJogadas;
  final DateTime dataInicio;
  final DateTime? dataFim;
  final bool zerado;
  final String console;
  final int rating;

  Gameplay({
    this.id,
    required this.usersId,
    required this.jogosId,
    required this.horasJogadas,
    required this.dataInicio,
    this.dataFim,
    required this.zerado,
    required this.console,
    this.rating = 0,
  });

  static int? _parseInt(Object? value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id?.toString(),
      'usersId': usersId.toString(),
      'jogosId': jogosId.toString(),
      'horasJogadas': horasJogadas,
      'dataInicio': dataInicio.toIso8601String(),
      'dataFim': dataFim?.toIso8601String(),
      'zerado': zerado ? 1 : 0,
      'console': console,
      'rating': rating,
    };
  }

  factory Gameplay.fromMap(Map<String, dynamic> map) {
    return Gameplay(
      id: _parseInt(map['id']),
      usersId: _parseInt(map['usersId']) ?? 0,
      jogosId: _parseInt(map['jogosId']) ?? 0,
      horasJogadas: (map['horasJogadas'] as num).toDouble(),
      dataInicio: DateTime.parse(map['dataInicio']),
      dataFim: map['dataFim'] != null ? DateTime.parse(map['dataFim']) : null,
      zerado: map['zerado'] == 1,
      console: map['console'],
      rating: _parseInt(map['rating']) ?? 0,
    );
  }
}
