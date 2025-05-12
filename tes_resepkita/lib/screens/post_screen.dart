import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _titleController = TextEditingController();
  final _storyController = TextEditingController();

  List<TextEditingController> _ingredientControllers = [];
  List<_StepData> _steps = [];

  File? _recipeImage;

  final ImagePicker _picker = ImagePicker();

  // Daftar kategori resep yang bisa dipilih
  final List<String> _categories = [
    'Makanan Anak Kost',
    'Makanan Cemilan',
    'Makanan Utama',
    'Makanan Pembuka',
    'Minuman',
    'Makanan Penutup',
    'Makanan Diet',
  ];

  // Kategori yang dipilih user
  final Set<String> _selectedCategories = {};

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi dengan 3 bahan dan 3 langkah default
    _ingredientControllers = List.generate(3, (_) => TextEditingController());
    _steps = List.generate(3, (_) => _StepData());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _storyController.dispose();
    for (var c in _ingredientControllers) {
      c.dispose();
    }
    for (var step in _steps) {
      step.dispose();
    }
    super.dispose();
  }

  Future<void> _pickRecipeImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _recipeImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickStepImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _steps[index].imageFile = File(pickedFile.path);
      });
    }
  }

  void _addIngredient() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _addStep() {
    setState(() {
      _steps.add(_StepData());
    });
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  Future<void> _saveRecipe() async {
    // Validasi input sederhana
    if (_titleController.text.trim().isEmpty) {
      _showMessage('Judul resep tidak boleh kosong');
      return;
    }
    if (_ingredientControllers.isEmpty ||
        _ingredientControllers.every((c) => c.text.trim().isEmpty)) {
      _showMessage('Tambahkan minimal satu bahan resep');
      return;
    }
    if (_steps.isEmpty ||
        _steps.every((s) => s.descriptionController.text.trim().isEmpty)) {
      _showMessage('Tambahkan minimal satu langkah memasak');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulasi proses penyimpanan (misal ke backend atau lokal)
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    _showMessage('Resep berhasil disimpan (simulasi)');
  }

  void _uploadRecipe() {
    // Placeholder untuk fungsi upload ke server/backend
    _showMessage('Fitur upload belum tersedia');
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLength = 100,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildIngredientInput(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: _buildTextField(
        controller: _ingredientControllers[index],
        label: 'Bahan Resep',
        hint: 'Contoh: 500gr Kaldu Ayam',
        maxLength: 100,
      ),
    );
  }

  Widget _buildStepInput(int index) {
    final step = _steps[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _pickStepImage(index),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child:
                  step.imageFile != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(step.imageFile!, fit: BoxFit.cover),
                      )
                      : const Icon(Icons.camera_alt, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTextField(
              controller: step.descriptionController,
              label: 'Langkah ${index + 1}',
              hint: 'Tulis cara memasaknya disini',
              maxLength: 200,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          _categories.map((cat) {
            final selected = _selectedCategories.contains(cat);
            return ChoiceChip(
              label: Text(cat),
              selected: selected,
              onSelected: (_) => _toggleCategory(cat),
              selectedColor: Colors.blue.shade300,
              backgroundColor: Colors.grey.shade200,
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.black87,
              ),
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catet Resepmu'),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul Resep
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Judul Resep',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Maks. 35 Karakter',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _titleController,
                      maxLength: 35,
                      decoration: InputDecoration(
                        hintText: 'Tulis nama resep buatanmu ...',
                        filled: true,
                        fillColor: Colors.grey.shade300,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Cerita Resep
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cerita Resep',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Maks. 500 Karakter',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _storyController,
                      maxLength: 500,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Contoh : Resep enak, simple dari ...',
                        filled: true,
                        fillColor: Colors.grey.shade300,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Foto Resep
                    const Text(
                      'Foto Resep',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pilih foto resepmu semenarik mungkin, ya.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickRecipeImage,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade200,
                        ),
                        child:
                            _recipeImage != null
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _recipeImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : const Icon(
                                  Icons.camera_alt,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Bahan Resep
                    const Text(
                      'Bahan Resep',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(
                      _ingredientControllers.length,
                      (index) => _buildIngredientInput(index),
                    ),
                    TextButton.icon(
                      onPressed: _addIngredient,
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Bahan'),
                    ),

                    const SizedBox(height: 20),

                    // Cara Memasak
                    const Text(
                      'Cara Memasak',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pilih foto yang jelas dan semenarik mungkin, ya.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(
                      _steps.length,
                      (index) => _buildStepInput(index),
                    ),
                    TextButton.icon(
                      onPressed: _addStep,
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Langkah'),
                    ),

                    const SizedBox(height: 20),

                    // Kategori Resep
                    const Text(
                      'Kategori Resep',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tambahkan kategori agar resep kamu lebih mudah dicari.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    _buildCategoryChips(),

                    const SizedBox(height: 30),

                    // Tombol Simpan dan Upload
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveRecipe,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Simpan Resep'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _uploadRecipe,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Upload'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }
}

class _StepData {
  File? imageFile;
  final TextEditingController descriptionController = TextEditingController();

  void dispose() {
    descriptionController.dispose();
  }
}
