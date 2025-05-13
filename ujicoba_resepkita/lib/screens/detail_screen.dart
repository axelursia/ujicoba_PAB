import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ujicoba_resepkita/models/recipe_model.dart';
import 'package:share_plus/share_plus.dart';

class DetailScreen extends StatefulWidget {
  final Recipe recipe;

  const DetailScreen({super.key, required this.recipe});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  bool _isFollowing = false;
  bool _isLoadingFollowStatus = true;

  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _checkIfFollowing();
  }

  Future<void> _checkIfFollowing() async {
    if (currentUser == null) {
      setState(() {
        _isFollowing = false;
        _isLoadingFollowStatus = false;
      });
      return;
    }
    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .get();

    if (userDoc.exists) {
      final following = List<String>.from(userDoc.data()?['following'] ?? []);
      setState(() {
        _isFollowing = following.contains(widget.recipe.userId);
        _isLoadingFollowStatus = false;
      });
    } else {
      setState(() {
        _isFollowing = false;
        _isLoadingFollowStatus = false;
      });
    }
  }

  Future<void> _toggleFollow() async {
    if (currentUser == null) return;

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid);
    final followedUserRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.recipe.userId);

    final userDoc = await userRef.get();
    final followedUserDoc = await followedUserRef.get();

    if (!userDoc.exists || !followedUserDoc.exists) {
      // Bisa tambahkan handling error jika perlu
      return;
    }

    final following = List<String>.from(userDoc.data()?['following'] ?? []);
    final followers = List<String>.from(
      followedUserDoc.data()?['followers'] ?? [],
    );

    if (_isFollowing) {
      // Unfollow
      following.remove(widget.recipe.userId);
      followers.remove(currentUser!.uid);
    } else {
      // Follow
      following.add(widget.recipe.userId);
      followers.add(currentUser!.uid);
    }

    // Update kedua dokumen secara paralel
    await Future.wait([
      userRef.update({'following': following}),
      followedUserRef.update({'followers': followers}),
    ]);

    setState(() {
      _isFollowing = !_isFollowing;
    });
  }

  Future<void> _submitComment() async {
    if (currentUser != null && _commentController.text.isNotEmpty) {
      final commentText = _commentController.text.trim();
      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.recipe.id)
          .collection('comments')
          .add({
            'userId': currentUser!.uid,
            'userName': currentUser!.displayName ?? 'Anonymous',
            'comment': commentText,
            'createdAt': FieldValue.serverTimestamp(),
          });
      _commentController.clear();
    }
  }

  Future<void> _saveRecipeToFavorites() async {
    if (currentUser == null) return;

    final recipeId = widget.recipe.id;
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid);
    final userDoc = await userRef.get();

    if (userDoc.exists) {
      final favorites = List<String>.from(userDoc.data()?['favorites'] ?? []);
      if (!favorites.contains(recipeId)) {
        favorites.add(recipeId);
        await userRef.update({'favorites': favorites});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resep berhasil disimpan ke favorit')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Resep sudah ada di favorit')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.title),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              SharePlus.instance.share(
                ShareParams(
                  text:
                      'Check out this recipe: ${widget.recipe.title}\n${widget.recipe.imageUrl}',
                  subject: 'Resep Menarik',
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Resep
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(widget.recipe.imageUrl, fit: BoxFit.cover),
              ),
              SizedBox(height: 16),

              // Nama dan Tanggal + Tombol Follow
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      widget.recipe.authorAvatarUrl,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    widget.recipe.authorName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Spacer(),
                  _isLoadingFollowStatus
                      ? CircularProgressIndicator()
                      : (currentUser != null &&
                              widget.recipe.userId != currentUser!.uid
                          ? ElevatedButton(
                            onPressed: _toggleFollow,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isFollowing
                                      ? Colors.grey
                                      : Colors.deepPurple,
                            ),
                            child: Text(_isFollowing ? 'Following' : 'Follow'),
                          )
                          : SizedBox.shrink()),
                ],
              ),
              SizedBox(height: 8),

              // Tanggal (hardcoded, bisa diganti dengan data asli)
              Text('7 April 2025', style: TextStyle(color: Colors.grey)),
              SizedBox(height: 8),

              // Deskripsi
              Text(widget.recipe.description, style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),

              // Bahan Utama
              Text(
                'Bahan Utama',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),
              ...widget.recipe.ingredients.map(
                (ingredient) => Text('• $ingredient'),
              ),

              SizedBox(height: 16),

              // Alat & Perlengkapan
              Text(
                'Alat & Perlengkapan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),
              ...widget.recipe.tools.map((tool) => Text('• $tool')),

              SizedBox(height: 16),

              // Cara Memasak
              Text(
                'Cara Memasak Resep',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),
              ...widget.recipe.steps.asMap().entries.map((entry) {
                int stepNumber = entry.key + 1;
                String step = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step $stepNumber: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(child: Text(step)),
                    ],
                  ),
                );
              }),

              SizedBox(height: 16),

              // Rating Resep
              Text(
                'Beri Rating Resep Ini',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < widget.recipe.rating.round()
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      // TODO: Implementasikan update rating ke Firebase jika diperlukan
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Rating ${index + 1} belum diimplementasikan',
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),

              SizedBox(height: 16),

              // Form Komentar
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Tulis komentarmu disini...',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _submitComment,
                child: Text('Kirim Komentar'),
              ),

              // Daftar Komentar
              SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('recipes')
                        .doc(widget.recipe.id)
                        .collection('comments')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final comments = snapshot.data!.docs;
                  if (comments.isEmpty) {
                    return Center(child: Text('Belum ada komentar.'));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment =
                          comments[index].data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(comment['userName'] ?? 'Anonymous'),
                        subtitle: Text(comment['comment'] ?? ''),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveRecipeToFavorites,
        child: Icon(Icons.favorite_border),
        tooltip: 'Simpan ke Favorit',
      ),
    );
  }
}
