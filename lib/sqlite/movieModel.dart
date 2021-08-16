class movieModel {
  int? id;
  final String title;
  final String director;
  final String picture;

  movieModel({
    this.id,
    required this.title,
    required this.director,
    required this.picture,
  });

  factory movieModel.fromMap(Map<String, dynamic> map) {
    return movieModel(
      id: map['id'],
      title: map['title'],
      director: map['director'],
      picture: map['picture'],
    );
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "director": director,
        "picture": picture,
      };
}
