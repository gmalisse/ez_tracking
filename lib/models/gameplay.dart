class Gameplay {
  final int? id;
  final int usersId;
  final int jogosId;
  final double horasJogadas;
  final DateTime dataInicio;
  final DateTime? dataFim;
  final bool zerado;
  final String console;

  Gameplay({
    this.id,
    required this.usersId,
    required this.jogosId,
    required this.horasJogadas,
    required this.dataInicio,
    this.dataFim,
    required this.zerado,
    required this.console,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usersId': usersId,
      'jogosId': jogosId,
      'horasJogadas': horasJogadas,
      'dataInicio': dataInicio.toIso8601String(),
      'dataFim': dataFim?.toIso8601String(),
      'zerado': zerado ? 1 : 0,
      'console': console,
    };
  }

  factory Gameplay.fromMap(Map<String, dynamic> map) {
    return Gameplay(
      id: map['id'],
      usersId: map['usersId'],
      jogosId: map['jogosId'],
      horasJogadas: (map['horasJogadas'] as num).toDouble(),
      dataInicio: DateTime.parse(map['dataInicio']),
      dataFim: map['dataFim'] != null ? DateTime.parse(map['dataFim']) : null,
      zerado: map['zerado'] == 1,
      console: map['console'],
    );
  }
}
