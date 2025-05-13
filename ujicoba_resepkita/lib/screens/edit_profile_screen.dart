import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // Menambahkan Image Picker
import 'package:firebase_storage/firebase_storage.dart'; // Menambahkan Firebase Storage

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  File? _profileImage; // Variabel untuk menyimpan foto profil yang dipilih
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Memuat data pengguna dari Firebase
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
      // Dapatkan nomor telepon dari Firestore
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      if (userDoc.exists) {
        _phoneController.text = userDoc['phone'] ?? '';
      }
      // Memuat foto profil dari Firebase Auth
      setState(() {
        _profileImage = null; // Untuk menampilkan foto default jika diperlukan
      });
    }
  }

  // Menyimpan data profil yang sudah diperbarui
  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Jika ada gambar baru, upload gambar ke Firebase Storage
        String? imageUrl;
        if (_profileImage != null) {
          imageUrl = await _uploadProfileImage(_profileImage!);
        }

        // Update nama dan email di Firebase Authentication
        await user.updateProfile(displayName: _nameController.text);
        await user.verifyBeforeUpdateEmail(_emailController.text);

        // Simpan nomor telepon dan foto profil di Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
          {
            'phone': _phoneController.text,
            'profilePicture':
                imageUrl ??
                user.photoURL, // Gunakan foto URL lama jika tidak ada foto baru
          },
        );

        // Tampilkan notifikasi
        if (!mounted) return; // Periksa apakah widget masih terpasang
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );

        // Kembali ke layar profil
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return; // Periksa apakah widget masih terpasang
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
      }
    }
  }

  // Fungsi untuk memilih foto profil dari galeri atau kamera
  Future<void> _pickProfileImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    ); // Mengambil gambar dari galeri
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(
          pickedFile.path,
        ); // Menyimpan path gambar yang dipilih
      });
    }
  }

  // Fungsi untuk mengunggah gambar ke Firebase Storage dan mendapatkan URL
  Future<String?> _uploadProfileImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(
        'profile_pictures/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      final imageUrl = await snapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Your Profile'),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigasi kembali ke halaman sebelumnya
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto Profil
            Center(
              child: GestureDetector(
                onTap: _pickProfileImage, // Fungsi untuk memilih gambar
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      _profileImage != null
                          ? FileImage(_profileImage!)
                          : NetworkImage(
                                FirebaseAuth.instance.currentUser?.photoURL ??
                                    'https://www.example.com/default-profile-pic.jpg',
                              )
                              as ImageProvider,
                ),
              ),
            ),
            SizedBox(height: 16),

            // Input Nama
            Text('Name'),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(hintText: 'Enter your name'),
            ),
            SizedBox(height: 12),

            // Input Email
            Text('Email'),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(hintText: 'Enter your email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 12),

            // Input Phone
            Text('Phone Number'),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(hintText: 'Enter your phone number'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),

            // Save Button
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('Save Your Profile'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
                backgroundColor:
                    Colors
                        .deepPurple, // Corrected 'primary' to 'backgroundColor'
              ),
            ),
          ],
        ),
      ),
    );
  }
}
