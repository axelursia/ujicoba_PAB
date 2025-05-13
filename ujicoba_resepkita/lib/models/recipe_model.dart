class Recipe {
  String id;
  String title;
  String description;
  String imageUrl;
  String userId;
  double rating;
  List<String> ingredients;
  List<String> steps;
  String authorAvatarUrl; // Field baru untuk avatar penulis
  String authorName; // Field baru untuk nama penulis
  List<String> tools; // Field baru untuk alat yang digunakan

  // Konstruktor untuk menginisialisasi semua field
  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.userId,
    required this.rating,
    required this.ingredients,
    required this.steps,
    required this.authorAvatarUrl, // Inisialisasi avatar penulis
    required this.authorName, // Inisialisasi nama penulis
    required this.tools, // Inisialisasi tools
  });

  // Factory constructor untuk membuat objek Recipe dari Map
  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      userId: map['userId'],
      rating: map['rating'],
      ingredients: List<String>.from(map['ingredients']),
      steps: List<String>.from(map['steps']),
      authorAvatarUrl: map['authorAvatarUrl'] ?? '', // Ambil URL avatar penulis
      authorName: map['authorName'] ?? 'Unknown', // Ambil nama penulis
      tools: List<String>.from(map['tools'] ?? []), // Ambil data alat
    );
  }
}
