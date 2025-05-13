import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> recipes =
      []; // This will hold the recipes that match the search query.

  @override
  void initState() {
    super.initState();
    // Fetch recipes or handle search query initialization here
  }

  void _searchRecipes(String query) {
    // You can replace this with your logic to search from the data source (Firebase, local DB, etc.)
    setState(() {
      recipes =
          [
                'Recipe 1',
                'Recipe 2',
                'Recipe 3', // Just some mock data for now
              ]
              .where(
                (recipe) => recipe.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pencarian Resep'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Cari resep...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _searchRecipes,
            ),
            const SizedBox(height: 20),
            Expanded(
              child:
                  recipes.isEmpty
                      ? const Center(child: Text('Tidak ada resep ditemukan.'))
                      : ListView.builder(
                        itemCount: recipes.length,
                        itemBuilder: (context, index) {
                          final recipe = recipes[index];
                          return ListTile(
                            title: Text(recipe),
                            onTap: () {
                              // Handle navigation to recipe detail screen if required
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
}
