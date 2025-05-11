import 'package:flutter/material.dart';
import 'package:tes_resepkita/services/recipe_service.dart';

class RatingProvider extends ChangeNotifier {
  final RecipeService _recipeService = RecipeService();

  double averageRating = 0;
  int ratingCount = 0;
  int userRating = 0;

  Future<void> loadRating(String recipeId, String userId) async {
    // Menggunakan method getRecipeDocument dari RecipeService
    final recipeSnapshot = await _recipeService.getRecipeDocument(recipeId);

    if (recipeSnapshot.exists) {
      averageRating = (recipeSnapshot.get('averageRating') ?? 0).toDouble();
      ratingCount = recipeSnapshot.get('ratingCount') ?? 0;
    } else {
      averageRating = 0;
      ratingCount = 0;
    }

    // Menggunakan method getUserRating dari RecipeService
    final userRatingDoc = await _recipeService.getUserRating(recipeId, userId);
    if (userRatingDoc.exists) {
      userRating = userRatingDoc.get('rating') ?? 0;
    } else {
      userRating = 0;
    }

    notifyListeners();
  }

  Future<void> submitRating(String recipeId, String userId, int rating) async {
    await _recipeService.rateRecipe(recipeId, userId, rating);
    await loadRating(recipeId, userId);
  }
}
