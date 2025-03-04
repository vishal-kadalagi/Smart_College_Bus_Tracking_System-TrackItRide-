import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color; // Button color
  final Color textColor; // Text color
  final double fontSize; // Font size of the label text
  final EdgeInsetsGeometry padding; // Padding inside the button
  final BorderRadiusGeometry borderRadius; // Border radius for rounded corners

  const CustomButton({
    required this.label,
    required this.onPressed,
    this.color = Colors.blue, // Default color is blue
    this.textColor = Colors.white, // Default text color is white
    this.fontSize = 16.0, // Default font size is 16
    this.padding = const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0), // Default padding
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)), // Default border radius
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color, // Set button color (changed from 'primary' to 'backgroundColor')
        padding: padding, // Set button padding
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius, // Apply rounded corners
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor, // Set text color
          fontSize: fontSize, // Set font size
        ),
      ),
    );
  }
}
