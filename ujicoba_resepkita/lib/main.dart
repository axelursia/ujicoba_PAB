import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ujicoba_resepkita/screens/home_screen.dart';
import 'package:ujicoba_resepkita/screens/sign_in_screen.dart';
import 'package:ujicoba_resepkita/screens/splash_Screen.dart';
import 'firebase_options.dart'; // Pastikan file ini terimport dengan benar

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pastikan Firebase diinisialisasi dengan benar
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions
            .currentPlatform, // Gunakan options sesuai platform
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResepKita',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen();
          }
          if (snapshot.hasData) {
            return HomeScreen();
          } else {
            return SignInScreen();
          }
        },
      ),
    );
  }
}
