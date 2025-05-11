import 'package:flutter/material.dart';

// Model sederhana untuk resep favorit
class FavoriteRecipe {
  final String id;
  final String title;
  final String imageUrl;
  final double rating;
  final String userName;
  bool isFavorite;

  FavoriteRecipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.rating,
    required this.userName,
    this.isFavorite = true,
  });
}

class FavoriteScreens extends StatefulWidget {
  const FavoriteScreens({Key? key}) : super(key: key);

  @override
  State<FavoriteScreens> createState() => _FavoriteScreensState();
}

class _FavoriteScreensState extends State<FavoriteScreens> {
  final TextEditingController _searchController = TextEditingController();

  // Contoh data resep favorit
  final List<FavoriteRecipe> _allFavorites = [
    FavoriteRecipe(
      id: '1',
      title: 'Rendang',
      imageUrl:
          'https://images.unsplash.com/photo-1604908177520-7a7a7a7a7a7a', // Ganti dengan URL valid
      rating: 4.0,
      userName: 'Sigit Rendang',
    ),
    FavoriteRecipe(
      id: '2',
      title: 'Ayam kecap',
      imageUrl: 'https://images.unsplash.com/photo-1604908177521-8b8b8b8b8b8b',
      rating: 3.9,
      userName: 'coki parade',
    ),
    FavoriteRecipe(
      id: '3',
      title: 'Soto',
      imageUrl: 'https://images.unsplash.com/photo-1604908177522-9c9c9c9c9c9c',
      rating: 4.1,
      userName: 'Sugeng tumbler',
    ),
    FavoriteRecipe(
      id: '4',
      title: 'Sop',
      imageUrl: 'https://images.unsplash.com/photo-1604908177523-adadadadadad',
      rating: 3.4,
      userName: 'Aan android',
    ),
  ];

  List<FavoriteRecipe> _filteredFavorites = [];

  @override
  void initState() {
    super.initState();
    _filteredFavorites = List.from(_allFavorites);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFavorites =
          _allFavorites.where((recipe) {
            return recipe.title.toLowerCase().contains(query) ||
                recipe.userName.toLowerCase().contains(query);
          }).toList();
    });
  }

  void _toggleFavorite(String id) {
    setState(() {
      final index = _allFavorites.indexWhere((r) => r.id == id);
      if (index != -1) {
        _allFavorites[index].isFavorite = !_allFavorites[index].isFavorite;
        _onSearchChanged(); // Refresh filtered list
      }
    });
  }

  void _openDetail(FavoriteRecipe recipe) {
    // Navigasi ke detail screen
    // Pastikan Anda sudah punya route ke detail_screen.dart
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                DetailScreen(recipeId: recipe.id, recipeTitle: recipe.title),
      ),
    );
  }

  void _onViewAll() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur Lihat Semua belum tersedia')),
    );
  }

  int _selectedIndex = 2; // Favorite tab aktif

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navigasi sesuai index
    switch (index) {
      case 0:
        // Home
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        // Add
        Navigator.pushReplacementNamed(context, '/post');
        break;
      case 2:
        // Favorite (sudah di sini)
        break;
      case 3:
        // Profile
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resep Favoritmu'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari Resep Kesukaanmu',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(height: 8),

            // Lihat Semua
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _onViewAll,
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Grid resep favorit
            Expanded(
              child:
                  _filteredFavorites.isEmpty
                      ? const Center(
                        child: Text('Tidak ada resep favorit ditemukan'),
                      )
                      : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.75,
                            ),
                        itemCount: _filteredFavorites.length,
                        itemBuilder: (context, index) {
                          final recipe = _filteredFavorites[index];
                          return GestureDetector(
                            onTap: () => _openDetail(recipe),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // User info
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 12,
                                          backgroundImage: NetworkImage(
                                            'https://ui-avatars.com/api/?name=${Uri.encodeComponent(recipe.userName)}&background=random',
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            recipe.userName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Image resep
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      recipe.imageUrl,
                                      height: 100,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          height: 100,
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.broken_image,
                                            size: 40,
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // Judul resep
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      recipe.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  // Rating dan favorite icon
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          recipe.rating.toStringAsFixed(1),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            recipe.isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color:
                                                recipe.isFavorite
                                                    ? Colors.red
                                                    : Colors.grey,
                                          ),
                                          onPressed:
                                              () => _toggleFavorite(recipe.id),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Tambah'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorit'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// Dummy DetailScreen untuk navigasi, ganti dengan implementasi asli Anda
class DetailScreen extends StatelessWidget {
  final String recipeId;
  final String recipeTitle;

  const DetailScreen({
    Key? key,
    required this.recipeId,
    required this.recipeTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipeTitle)),
      body: Center(
        child: Text('Detail resep untuk $recipeTitle (ID: $recipeId)'),
      ),
    );
  }
}
