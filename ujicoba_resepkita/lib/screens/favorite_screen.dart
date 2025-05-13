import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ujicoba_resepkita/models/recipe_model.dart';
import 'package:ujicoba_resepkita/screens/detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key})
    : super(key: key); // Menambahkan parameter key

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  // Mendapatkan daftar resep favorit pengguna
  Future<List<Recipe>> _getFavoriteRecipes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      if (userDoc.exists) {
        final favoriteRecipeIds = List<String>.from(userDoc['favorites'] ?? []);
        if (favoriteRecipeIds.isNotEmpty) {
          // Ambil resep berdasarkan ID yang ada di favorit
          final snapshot =
              await FirebaseFirestore.instance
                  .collection('recipes')
                  .where('id', whereIn: favoriteRecipeIds)
                  .get();

          return snapshot.docs.map((doc) {
            return Recipe.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();
        }
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Resep Favoritmu"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari Resep Kesukaanmu',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
            SizedBox(height: 20),

            // List Favorite Recipes
            Expanded(
              child: FutureBuilder<List<Recipe>>(
                future: _getFavoriteRecipes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Tidak ada resep favorit.'));
                  }

                  final favoriteRecipes =
                      snapshot.data!.where((recipe) {
                        return recipe.title.toLowerCase().contains(
                              searchQuery,
                            ) ||
                            recipe.authorName.toLowerCase().contains(
                              searchQuery,
                            );
                      }).toList();

                  return ListView.builder(
                    itemCount: favoriteRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = favoriteRecipes[index];
                      return _buildRecipeCard(recipe);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Membuat tampilan untuk setiap kartu resep
  Widget _buildRecipeCard(Recipe recipe) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(recipe: recipe),
            ),
          );
        },
        contentPadding: EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            recipe.imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          recipe.title,
          style: TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Icon(Icons.star, color: Colors.yellow, size: 16),
            SizedBox(width: 4),
            Text(recipe.rating.toString(), style: TextStyle(fontSize: 14)),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.favorite, color: Colors.red),
          onPressed: () {
            _removeFromFavorites(recipe.id); // Hapus dari favorit
          },
        ),
      ),
    );
  }

  // Fungsi untuk menghapus resep dari favorit
  Future<void> _removeFromFavorites(String recipeId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      final userDoc = await userRef.get();

      if (userDoc.exists) {
        final favorites = List<String>.from(userDoc['favorites'] ?? []);
        favorites.remove(recipeId); // Menghapus resep dari favorit
        await userRef.update({'favorites': favorites});
        setState(() {}); // Memperbarui tampilan
      }
    }
  }
}
