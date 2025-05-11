import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/recipe_model.dart';

class RecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload image to Firebase Storage
  Future<String> uploadImage(File imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = _storage.ref().child('recipe_images').child(fileName);
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  /// Add a new recipe to Firestore
  Future<void> addRecipe({
    required String title,
    required String description,
    required File imageFile,
    required double rating,
    required String userId,
  }) async {
    String imageUrl = await uploadImage(imageFile);
    await _firestore.collection('recipes').add({
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get list of recipes (real-time stream)
  Stream<List<Recipe>> getRecipes() {
    return _firestore
        .collection('recipes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Recipe.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Rate a recipe and update average rating
  Future<void> rateRecipe(String recipeId, String userId, int rating) async {
    final recipeRef = _firestore.collection('recipes').doc(recipeId);
    final ratingRef = recipeRef.collection('ratings').doc(userId);

    // Simpan rating user
    await ratingRef.set({'rating': rating});

    // Ambil semua rating untuk hitung ulang rata-rata
    final ratingsSnapshot = await recipeRef.collection('ratings').get();

    int totalRating = 0;
    for (var doc in ratingsSnapshot.docs) {
      totalRating += doc.get('rating') as int;
    }
    int ratingCount = ratingsSnapshot.docs.length;
    double averageRating = ratingCount > 0 ? totalRating / ratingCount : 0;

    // Update data rata-rata dan jumlah rating di dokumen resep
    await recipeRef.update({
      'averageRating': averageRating,
      'ratingCount': ratingCount,
    });
  }

  /// Edit an existing recipe
  Future<void> editRecipe({
    required String recipeId,
    required String title,
    required String description,
    required File imageFile,
  }) async {
    String imageUrl = await uploadImage(imageFile);
    await _firestore.collection('recipes').doc(recipeId).update({
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
    });
  }

  /// Delete a recipe
  Future<void> deleteRecipe(String recipeId) async {
    // Delete recipe image from Firebase Storage
    final recipeSnapshot =
        await _firestore.collection('recipes').doc(recipeId).get();
    String imageUrl = recipeSnapshot['imageUrl'];
    Reference imageRef = _storage.refFromURL(imageUrl);
    await imageRef.delete();

    // Delete recipe document from Firestore
    await _firestore.collection('recipes').doc(recipeId).delete();
  }

  /// Get recipe document snapshot by recipeId
  Future<DocumentSnapshot> getRecipeDocument(String recipeId) {
    return _firestore.collection('recipes').doc(recipeId).get();
  }

  /// Get user rating document snapshot for a recipe
  Future<DocumentSnapshot> getUserRating(String recipeId, String userId) {
    return _firestore
        .collection('recipes')
        .doc(recipeId)
        .collection('ratings')
        .doc(userId)
        .get();
  }
}
