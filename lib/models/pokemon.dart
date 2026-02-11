class Pokemon {
  final int id;
  final String name;
  final String img;
  final List<String> type;
  final String height;
  final String weight;
  final String candy;
  final List<String> weaknesses;

  Pokemon({
    required this.id,
    required this.name,
    required this.img,
    required this.type,
    required this.height,
    required this.weight,
    required this.candy,
    required this.weaknesses,
  });

  // Cette fonction transforme le JSON de l'API en objet Pokemon
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'],
      name: json['name'],
      img: json['img'],
      type: List<String>.from(json['type']),
      height: json['height'],
      weight: json['weight'],
      candy: json['candy'],
      weaknesses: List<String>.from(json['weaknesses']),
    );
  }
}