class User {
  final int? id;
  final String nome;
  final String email;
  final String senha;
  final DateTime dataNascimento;

  User({
    this.id,
    required this.nome,
    required this.email,
    required this.senha,
    required this.dataNascimento,
  });

  static int? _parseInt(Object? value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
      'dataNascimento': dataNascimento.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: _parseInt(map['id']),
      nome: map['nome'],
      email: map['email'],
      senha: map['senha'],
      dataNascimento: DateTime.parse(map['dataNascimento']),
    );
  }
}
