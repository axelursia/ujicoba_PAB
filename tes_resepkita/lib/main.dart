import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:tes_resepkita/screens/splash_screen.dart';

// Import screens
import 'screens/home_screens.dart';
import 'screens/post_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/pengaturan_screen.dart';

// Import providers
import 'providers/auth_providers.dart';
import 'providers/rating_providers.dart';

// Import theme
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Menambahkan penanganan kesalahan untuk inisialisasi Firebase
    await Firebase.initializeApp();
  } catch (e) {
    // Menampilkan error jika inisialisasi Firebase gagal
    print('Firebase initialization error: $e');
  }
  runApp(const ResepKitaApp());
}

class ResepKitaApp extends StatelessWidget {
  const ResepKitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RatingProvider()),
        // Tambahkan provider lain jika perlu
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Resep Kita',
        theme: appTheme,
        home: const SplashScreen(), // SplashScreen sebagai halaman pertama
        routes: {
          '/home': (context) => HomeScreen(),
          '/post': (context) => const PostScreen(),
          '/profile': (context) {
            final authProvider = Provider.of<AuthProvider>(
              context,
              listen: false,
            );
            final currentUserId = authProvider.user?.uid ?? '';
            return ProfileScreen(
              userId: currentUserId,
            ); // tanpa const karena userId dinamis
          },
          '/settings': (context) => const PengaturanScreen(),
        },
        supportedLocales: const [
          Locale('id', ''), // Bahasa Indonesia
          Locale('en', ''), // Bahasa Inggris
        ],
      ),
    );
  }
}
