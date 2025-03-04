import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF800000); // Maroon
  static const Color scaffoldBackgroundColor = Colors.white;

  static final ThemeData themeData = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      labelStyle: TextStyle(color: Colors.black),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black), // Replaces bodyText1
      bodyMedium: TextStyle(color: Colors.black), // Replaces bodyText2
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black), // Large titles
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black), // Medium titles
    ),
  );
}
