import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:tes_resepkita/providers/rating_providers.dart';
import '../widgets/star_rating.dart';

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

class DetailScreen extends StatefulWidget {
  final Recipe recipe;
  final String currentUserId;

  const DetailScreen({
    Key? key,
    required this.recipe,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late RatingProvider ratingProvider;
  final TextEditingController _commentController = TextEditingController();
  bool isFollowing =
      false; // Simulasi status follow, bisa dihubungkan ke backend

  @override
  void initState() {
    super.initState();
    ratingProvider = Provider.of<RatingProvider>(context, listen: false);
    ratingProvider.loadRating(widget.recipe.id, widget.currentUserId);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildIngredientList(List<String> ingredients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          ingredients
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text("• $item"),
                ),
              )
              .toList(),
    );
  }

  Widget _buildEquipmentList(List<String> equipment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          equipment
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text("• $item"),
                ),
              )
              .toList(),
    );
  }

  Widget _buildStepsList(List<RecipeStep> steps) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: steps.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final step = steps[index];
          return SizedBox(
            width: 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    step.imageUrl,
                    height: 90,
                    width: 140,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          height: 90,
                          width: 140,
                          child: const Icon(Icons.image_not_supported),
                        ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Step ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  step.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _toggleFollow() {
    setState(() {
      isFollowing = !isFollowing;
    });
    // TODO: Hubungkan dengan backend untuk update status follow
  }

  void _saveRecipe() {
    // TODO: Implementasi simpan resep ke favorit user
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Resep disimpan!')));
  }

  void _shareRecipe() {
    // TODO: Implementasi share resep (bisa pakai package share_plus)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur bagikan belum tersedia')),
    );
  }

  void _submitComment() {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    // TODO: Simpan komentar ke backend Firestore
    _commentController.clear();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Komentar terkirim')));
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final formattedDate = DateFormat(
      'd MMMM yyyy',
      'id',
    ).format(recipe.createdAt);

    return Scaffold(
      appBar: AppBar(title: Text(recipe.title), leading: const BackButton()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Consumer<RatingProvider>(
          builder: (context, ratingProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar resep
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    recipe.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          height: 200,
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 50,
                          ),
                        ),
                  ),
                ),
                const SizedBox(height: 12),

                // Profil pembuat resep dan tombol Follow
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(recipe.authorAvatarUrl),
                      onBackgroundImageError: (_, __) {},
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            recipe.authorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _toggleFollow,
                      child: Text(isFollowing ? 'Following' : 'Follow'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Judul dan deskripsi resep
                Text(
                  recipe.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  recipe.description,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 12),

                // Tombol Simpan dan Bagikan
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _saveRecipe,
                      icon: const Icon(Icons.bookmark),
                      label: const Text('Simpan Resep'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _shareRecipe,
                      icon: const Icon(Icons.share),
                      label: const Text('Bagikan'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Bahan Utama
                _buildSectionTitle('Bahan Utama'),
                _buildIngredientList(recipe.mainIngredients),
                const SizedBox(height: 20),

                // Alat & Perlengkapan
                _buildSectionTitle('Alat & Perlengkapan'),
                _buildEquipmentList(recipe.equipment),
                const SizedBox(height: 20),

                // Cara Memasak Resep
                _buildSectionTitle('Cara Memasak Resep'),
                _buildStepsList(recipe.steps),
                const SizedBox(height: 20),

                // Rating
                _buildSectionTitle('Beri Rating Resep Ini'),
                Row(
                  children: [
                    StarRating(
                      rating: ratingProvider.userRating,
                      onRatingChanged: (newRating) {
                        ratingProvider.submitRating(
                          recipe.id,
                          widget.currentUserId,
                          newRating,
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${ratingProvider.averageRating.toStringAsFixed(1)} (${ratingProvider.ratingCount} penilaian)',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Komentar
                _buildSectionTitle('Komentar'),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(
                        'https://ui-avatars.com/api/?name=User',
                      ), // Ganti dengan avatar user sebenarnya
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'Tulis komentar kamu disini....',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        minLines: 1,
                        maxLines: 3,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _submitComment,
                    ),
                  ],
                ),

                // TODO: Tampilkan daftar komentar di bawah sini (bisa dibuat widget terpisah)
              ],
            );
          },
        ),
      ),
    );
  }
}
