class IGDBPlataforma {
  final int id;
  final String name;

  IGDBPlataforma({
    required this.id,
    required this.name,
  });

  factory IGDBPlataforma.fromJson(Map<String, dynamic> json) {
    return IGDBPlataforma(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Desconhecido',
    );
  }
}