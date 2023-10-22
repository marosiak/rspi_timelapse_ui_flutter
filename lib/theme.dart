import 'package:flutter/material.dart';


ThemeData defaultTheme(BuildContext context) {
  return ThemeData.from(
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.blue,
        // brightness: Brightness.dark
      ),
      textTheme: Theme.of(context).textTheme?.copyWith(
        headlineSmall: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        headlineMedium: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        headlineLarge: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
      ));
}