import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.deepOrange,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.deepOrange,
    foregroundColor: Colors.white,
    elevation: 2,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor:
          Colors.deepOrange, // Perbaikan dari 'primary' ke 'backgroundColor'
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(fontSize: 16),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(),
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  ),
  textTheme: const TextTheme(
    bodyMedium:
        TextStyle(fontSize: 14), // Perbaikan dari 'bodyText2' ke 'bodyMedium'
  ),
);
