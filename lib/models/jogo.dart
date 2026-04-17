class Jogo {
  final int? id;
  final String nome;

  Jogo({this.id, required this.nome});

  Map<String, dynamic> toMap() {
    return {'id': id, 'nome': nome};
  }

  factory Jogo.fromMap(Map<String, dynamic> map) {
    return Jogo(id: map['id'], nome: map['nome']);
  }
}
