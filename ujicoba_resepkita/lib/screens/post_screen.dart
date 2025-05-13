import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key})
    : super(key: key); // Menambahkan parameter 'key' pada konstruktor

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _stepController = TextEditingController();
  String? _selectedCategory;
  File? _imageFile;
  final List<String> _ingredients = []; // Menggunakan final untuk list
  final List<String> _steps = []; // Menggunakan final untuk list
  final ImagePicker _picker = ImagePicker();

  // Fungsi untuk memilih gambar resep
  Future<void> _pickRecipeImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    ); // Memilih gambar dari galeri
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Menyimpan gambar yang dipilih
      });
    }
  }

  // Fungsi untuk mengunggah gambar ke Firebase Storage
  Future<String?> _uploadImageToStorage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(
        'recipe_images/${Uuid().v4()}.jpg',
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

  // Fungsi untuk menyimpan resep ke Firestore
  Future<void> _saveRecipe() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Mengunggah gambar jika ada
        String? imageUrl;
        if (_imageFile != null) {
          imageUrl = await _uploadImageToStorage(_imageFile!);
        }

        // Menyimpan resep ke Firestore
        await FirebaseFirestore.instance.collection('recipes').add({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'ingredients': _ingredients,
          'steps': _steps,
          'imageUrl': imageUrl ?? '',
          'userId': user.uid,
          'category': _selectedCategory,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Resep berhasil disimpan!')));
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan resep: $e')));
      }
    }
  }

  // Fungsi untuk menambah bahan ke daftar bahan
  void _addIngredient() {
    if (_ingredientController.text.isNotEmpty) {
      setState(() {
        _ingredients.add(_ingredientController.text);
        _ingredientController.clear(); // Kosongkan input
      });
    }
  }

  // Fungsi untuk menambah langkah ke daftar langkah
  void _addStep() {
    if (_stepController.text.isNotEmpty) {
      setState(() {
        _steps.add(_stepController.text);
        _stepController.clear(); // Kosongkan input
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catat Resepmu'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Judul Resep
            Text('Judul Resep (Maks. 35 Karakter)'),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Tulis nama resep buatanku...',
              ),
              maxLength: 35,
            ),
            SizedBox(height: 12),

            // Deskripsi Resep
            Text('Cerita Resep (Maks. 500 Karakter)'),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Contoh: Resep enak, simple dari...',
              ),
              maxLength: 500,
              maxLines: 4,
            ),
            SizedBox(height: 12),

            // Foto Resep
            Text('Foto Resep'),
            GestureDetector(
              onTap: _pickRecipeImage,
              child:
                  _imageFile == null
                      ? Icon(Icons.camera_alt, size: 100, color: Colors.grey)
                      : Image.file(_imageFile!, height: 100, fit: BoxFit.cover),
            ),
            SizedBox(height: 12),

            // Bahan Resep
            Text('Bahan Resep'),
            TextField(
              controller: _ingredientController,
              decoration: InputDecoration(hintText: 'Contoh: 500gr Kaldu Ayam'),
            ),
            ElevatedButton(
              onPressed: _addIngredient,
              child: Text('Tambah Bahan'),
            ),
            SizedBox(height: 12),
            Column(
              children:
                  _ingredients
                      .map((ingredient) => ListTile(title: Text(ingredient)))
                      .toList(),
            ),
            SizedBox(height: 12),

            // Cara Memasak
            Text('Cara Memasak Resep'),
            TextField(
              controller: _stepController,
              decoration: InputDecoration(
                hintText: 'Contoh: Masukkan daging dalam panci presto',
              ),
            ),
            ElevatedButton(onPressed: _addStep, child: Text('Tambah Langkah')),
            SizedBox(height: 12),
            Column(
              children:
                  _steps
                      .map((step) => ListTile(title: Text('Langkah: $step')))
                      .toList(),
            ),
            SizedBox(height: 12),

            // Kategori Resep
            Text('Kategori Resep'),
            DropdownButton<String>(
              value: _selectedCategory,
              hint: Text('Pilih Kategori'),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              items:
                  [
                        'Makanan Utama',
                        'Minuman',
                        'Makanan Penutup',
                        'Makanan Anak Kost',
                      ]
                      .map(
                        (category) => DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
            ),
            SizedBox(height: 20),

            // Simpan Resep
            ElevatedButton(
              onPressed: _saveRecipe,
              child: Text('Simpan Resep'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 12),

            // Tombol Upload (optional, jika ingin meng-upload)
            ElevatedButton(
              onPressed: () {
                // Implement logic for uploading the recipe to server (optional)
                print('Recipe uploaded');
              },
              child: Text('Upload'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
