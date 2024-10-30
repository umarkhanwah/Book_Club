import 'package:flutter/material.dart';

class OurTheme {
  final Color _lightGreen = const Color.fromARGB(255, 213, 235, 220);
  final Color _lightGrey = const Color.fromARGB(255, 164, 164, 164);
  final Color _darkerGrey = const Color.fromARGB(255, 119, 124, 135);
  ThemeData buildTheme() {
    return ThemeData(
      scaffoldBackgroundColor: _lightGreen,
      canvasColor: _lightGreen,
      primaryColor: _lightGreen,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: _lightGrey, // Set the accent color here
      ),
      secondaryHeaderColor: _darkerGrey,
      hintColor: _lightGrey,
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: _lightGrey),
        prefixIconColor: _lightGrey,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: _lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: _lightGreen),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(_darkerGrey),
            foregroundColor: WidgetStatePropertyAll(Colors.white)),
      ),
    );
  }
}
