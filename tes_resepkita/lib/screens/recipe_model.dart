class Recipe {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String authorId;
  final String authorName;
  final String authorAvatarUrl;
  final DateTime createdAt;
  final List<String> mainIngredients;
  final List<String> equipment;
  final List<RecipeStep> steps;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.authorId,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.createdAt,
    required this.mainIngredients,
    required this.equipment,
    required this.steps,
  });
}

class RecipeStep {
  final String imageUrl;
  final String description;

  RecipeStep({required this.imageUrl, required this.description});
}
