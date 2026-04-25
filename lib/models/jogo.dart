class Jogo {
  final int? id;
  final String nome;

  Jogo({this.id, required this.nome});

  Map<String, dynamic> toMap() {
    return {'id': id, 'nome': nome};
  }

  static int? _parseInt(Object? value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  factory Jogo.fromMap(Map<String, dynamic> map) {
    return Jogo(id: _parseInt(map['id']), nome: map['nome']);
  }
}
