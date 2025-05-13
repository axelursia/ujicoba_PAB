import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:ujicoba_resepkita/models/recipe_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Menambahkan resep baru
  Future<String?> addRecipe(
    String title,
    String description,
    String imageUrl,
    String userId,
    double rating,
    List<String> ingredients,
    List<String> steps,
  ) async {
    try {
      String recipeId = Uuid().v4(); // Generate unique ID for the recipe
      await _firestore.collection('recipes').doc(recipeId).set({
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'userId': userId,
        'rating': rating,
        'ingredients': ingredients,
        'steps': steps,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return recipeId;
    } catch (e) {
      print('Error adding recipe: $e');
      return null;
    }
  }

  // Mendapatkan daftar resep
  Future<List<Recipe>> getRecipes() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('recipes').get();
      return snapshot.docs.map((doc) {
        return Recipe.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('Error fetching recipes: $e');
      return [];
    }
  }

  // Mendapatkan resep berdasarkan ID
  Future<Recipe?> getRecipeById(String recipeId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('recipes').doc(recipeId).get();
      if (snapshot.exists) {
        return Recipe.fromMap(snapshot.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching recipe by ID: $e');
      return null;
    }
  }

  // Menambahkan resep ke koleksi favorit
  Future<void> addToFavorites(String recipeId, String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'favorites': FieldValue.arrayUnion([recipeId]),
      });
    } catch (e) {
      print('Error adding recipe to favorites: $e');
    }
  }

  // Menghapus resep dari koleksi favorit
  Future<void> removeFromFavorites(String recipeId, String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'favorites': FieldValue.arrayRemove([recipeId]),
      });
    } catch (e) {
      print('Error removing recipe from favorites: $e');
    }
  }

  // Mengambil gambar dari storage
  Future<String?> uploadRecipeImage(String path) async {
    try {
      File imageFile = File(path);
      String fileName = Uuid().v4();
      UploadTask uploadTask = _storage
          .ref('recipe_images/$fileName')
          .putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
