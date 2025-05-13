import 'package:flutter/material.dart';
import 'package:ujicoba_resepkita/models/recipe_model.dart';
import 'package:ujicoba_resepkita/screens/detail_screen.dart';
import 'package:ujicoba_resepkita/widgets/custom_bottom_nav.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key); // Menambahkan parameter 'key'

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Inisialisasi notifikasi
  void initializeNotifications() async {
    var androidInitialize = AndroidInitializationSettings('app_icon');
    var initializationSettings = InitializationSettings(
      android: androidInitialize,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Menampilkan notifikasi
  void showNotification(String title, String body) async {
    var androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.high,
    );
    var generalDetails = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(0, title, body, generalDetails);
  }

  @override
  void initState() {
    super.initState();
    initializeNotifications();
  }

  // Contoh dummy data resep per kategori
  final List<Recipe> recipesToday = [
    Recipe(
      id: '1',
      title: 'Rendang',
      imageUrl: 'https://example.com/rendang.jpg',
      authorName: 'Radis Tapati',
      authorAvatarUrl: 'https://example.com/avatar1.jpg',
      rating: 4.4,
      description: 'Resep rendang khas Padang',
      ingredients: ['Daging Sapi', 'Kelapa Parut', 'Bumbu Rendang'],
      steps: ['Masak daging', 'Tambah bumbu', 'Masak hingga matang'],
      tools: ['Panci', 'Kompor'],
      userId: 'user_1',
    ),
    Recipe(
      id: '2',
      title: 'Nasi Goreng',
      imageUrl: 'https://example.com/nasigoreng.jpg',
      authorName: 'Tio Kencana',
      authorAvatarUrl: 'https://example.com/avatar2.jpg',
      rating: 4.1,
      description: 'Nasi goreng spesial dengan telur',
      ingredients: ['Nasi', 'Telur', 'Bumbu Nasi Goreng'],
      steps: ['Tumis bumbu', 'Masukkan nasi', 'Aduk rata'],
      tools: ['Wajan', 'Kompor'],
      userId: 'user_2',
    ),
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header sapaan dan notifikasi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo Sobat ResepKita',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Mau Masak Apa Hari ini ?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.notifications),
                    onPressed: () {
                      showNotification(
                        'Resep Baru',
                        'Cek resep baru yang telah ditambahkan!',
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Search bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Cari Resep Terbaru',
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

              // Expanded ListView untuk konten resep
              Expanded(
                child: ListView(
                  children: [
                    _buildRecipeSection('Resep Hari ini', recipesToday),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: CustomBottomNav(),
    );
  }

  Widget _buildRecipeSection(String title, List<Recipe> recipes) {
    // Filter resep berdasarkan search query
    final filteredRecipes =
        recipes.where((recipe) {
          return recipe.title.toLowerCase().contains(searchQuery) ||
              recipe.authorName.toLowerCase().contains(searchQuery);
        }).toList();

    if (filteredRecipes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(child: Text('Tidak ada resep ditemukan')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Judul dan tombol lihat semua
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigasi ke halaman daftar resep kategori ini
                print('Lihat Semua $title');
              },
              child: Text('Lihat Semua', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
        SizedBox(height: 8),

        // List horizontal resep
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filteredRecipes.length,
            itemBuilder: (context, index) {
              final recipe = filteredRecipes[index];
              return _buildRecipeCard(recipe);
            },
          ),
        ),

        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Container(
      width: 160,
      margin: EdgeInsets.only(right: 12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Navigasi ke detail resep
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(recipe: recipe),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar resep
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    recipe.imageUrl,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 8),

                // Nama pembuat dengan avatar
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: NetworkImage(recipe.authorAvatarUrl),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        recipe.authorName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8),

                // Judul resep
                Text(
                  recipe.title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 4),

                // Rating dan ikon favorit
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellow, size: 16),
                    SizedBox(width: 4),
                    Text(
                      recipe.rating.toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.favorite_border),
                      onPressed: () {
                        // TODO: Handle toggle favorite
                        print('Favorite toggled for ${recipe.title}');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
