// recipe_model.dart
class Recipe {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double rating;
  final String userId;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
      'userId': userId,
    };
  }

  factory Recipe.fromMap(String id, Map<String, dynamic> map) {
    return Recipe(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      userId: map['userId'] ?? '',
    );
  }
}
