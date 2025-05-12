import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  String userName = '';
  String fullName = '';
  String userEmail = '';
  String userPhotoUrl = '';
  int recipeCount = 0;
  int followersCount = 0;
  int followingCount = 0;

  List<Recipe> userRecipes = [];
  List<Recipe> filteredRecipes = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadUserData();
    _loadUserRecipes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    var userDoc = await _firestore.collection('users').doc(widget.userId).get();
    if (userDoc.exists) {
      setState(() {
        userName = userDoc['username'] ?? '';
        fullName = userDoc['name'] ?? '';
        userEmail = userDoc['email'] ?? '';
        userPhotoUrl = userDoc['photoUrl'] ?? '';
        followersCount = userDoc['followers'] ?? 0;
        followingCount = userDoc['following'] ?? 0;
      });
    }
  }

  Future<void> _loadUserRecipes() async {
    var querySnapshot =
        await _firestore
            .collection('recipes')
            .where('userId', isEqualTo: widget.userId)
            .get();

    final recipes =
        querySnapshot.docs
            .map((doc) => Recipe.fromMap(doc.id, doc.data()))
            .toList();

    setState(() {
      userRecipes = recipes;
      filteredRecipes = recipes;
      recipeCount = recipes.length;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredRecipes =
          userRecipes
              .where((recipe) => recipe.title.toLowerCase().contains(query))
              .toList();
    });
  }

  void _navigateTo(String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(userId: widget.userId),
                ),
              ).then((_) => _loadUserData());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      userPhotoUrl.isNotEmpty
                          ? NetworkImage(userPhotoUrl)
                          : const AssetImage('assets/images/default_avatar.png')
                              as ImageProvider,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCountColumn('Resep', recipeCount),
                          _buildCountColumn('Pengikut', followersCount),
                          _buildCountColumn('Mengikuti', followingCount),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFeatureButton(
                  Icons.explore,
                  'Explore',
                  () => _navigateTo('/explore'),
                ),
                _buildFeatureButton(
                  Icons.bookmark,
                  'Resep disimpan',
                  () => _navigateTo('/saved_recipes'),
                ),
                _buildFeatureButton(
                  Icons.restaurant_menu,
                  'Resep',
                  () => _navigateTo('/my_recipes'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari resep saya',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child:
                  filteredRecipes.isEmpty
                      ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/empty_profile.png',
                            width: 150,
                            height: 150,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Resep kreasimu masih kosong nih!!!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Mulai tulis resepmu dan dapatkan point\nuntuk setiap resep yang di publish',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      )
                      : ListView.builder(
                        itemCount: filteredRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = filteredRecipes[index];
                          return Card(
                            child: ListTile(
                              leading: Image.network(
                                recipe.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                              title: Text(recipe.title),
                              subtitle: Text(
                                'Rating: ${recipe.rating.toStringAsFixed(1)}',
                              ),
                              onTap: () {
                                // Navigasi ke detail resep jika ada
                              },
                            ),
                          );
                        },
                      ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Tulis Resep'),
              onPressed: () => _navigateTo('/post'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountColumn(String label, int count) {
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildFeatureButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[200],
            child: Icon(icon, size: 28, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
