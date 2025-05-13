import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_screen.dart';
import 'favorite_screen.dart';
import 'post_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key})
    : super(key: key); // Menambahkan parameter 'key'

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;
  late String _username;
  late String _email;
  late String _profilePic;
  int _recipeCount = 0;
  int _followersCount = 0;
  int _followingCount = 0;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  // Mengambil data pengguna dari Firestore dan FirebaseAuth
  Future<void> _getUserData() async {
    _user = _auth.currentUser!;
    if (_user != Null) {
      setState(() {
        _username = _user.displayName ?? "User";
        _email = _user.email ?? "No Email";
        _profilePic =
            _user.photoURL ??
            "https://www.example.com/default-profile-pic.jpg"; // Placeholder URL for default image
      });

      // Ambil data tambahan dari Firestore
      FirebaseFirestore.instance.collection('users').doc(_user.uid).get().then((
        doc,
      ) {
        if (doc.exists) {
          setState(() {
            _recipeCount = doc['recipes'] ?? 0;
            _followersCount = doc['followers'] ?? 0;
            _followingCount = doc['following'] ?? 0;
          });
        }
      });
    }
  }

  // Fungsi untuk logout
  Future<void> _logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        '/login', // Ganti dengan route ke login screen
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Tambahkan pengaturan aplikasi jika diperlukan
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Foto Profil
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(_profilePic),
              ),
            ),
            SizedBox(height: 12),
            // Nama Pengguna dan Email
            Text(
              _username,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(_email, style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 12),
            // Statistik Pengguna
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatColumn("Resep", _recipeCount),
                _buildStatColumn("Pengikut", _followersCount),
                _buildStatColumn("Mengikuti", _followingCount),
              ],
            ),
            SizedBox(height: 20),
            // Tombol Edit Profil
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen()),
                );
              },
              child: Text("Edit Profil"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 12),
            // Tombol Lihat Favorit
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoriteScreen()),
                );
              },
              child: Text("Lihat Favorit"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 12),
            // Tombol Tulis Resep
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PostScreen()),
                );
              },
              child: Text("Tulis Resep"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 12),
            // Tombol Logout
            ElevatedButton(
              onPressed: _logout,
              child: Text("Logout"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan statistik (Resep, Pengikut, Mengikuti)
  Widget _buildStatColumn(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}
