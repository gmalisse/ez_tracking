class IGDBGame {
  final int? id;
  final String name;

  IGDBGame({
    required this.id,
    required this.name
  });

  factory IGDBGame.fromJson(Map<String, dynamic> json) {
    return IGDBGame(
      id: json['id'],
      name: json['name'],
    );
  }
}