import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF800000); // Maroon
const Color secondaryColor = Colors.white; // White background
const Color textColor = Colors.black; // Text Color

final ThemeData appTheme = ThemeData(
  primaryColor: primaryColor,
  scaffoldBackgroundColor: secondaryColor,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: textColor),
    bodyMedium: TextStyle(color: textColor),
  ),
);
