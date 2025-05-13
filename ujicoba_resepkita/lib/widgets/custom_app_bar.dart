import 'package:flutter/material.dart';
import 'package:ujicoba_resepkita/screens/profile_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  CustomAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.deepPurple,
      actions: [
        // Tombol untuk membuka Profil
        IconButton(
          icon: Icon(Icons.account_circle),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
        ),
        // Tombol untuk notifikasi
        IconButton(
          icon: Icon(Icons.notifications),
          onPressed: () {
            // Implementasikan logika untuk membuka notifikasi
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
