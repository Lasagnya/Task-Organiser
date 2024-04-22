import 'package:flutter/material.dart';

/// Светлая тема приложения.
ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
      seedColor: Colors.purple.shade300
  ),
  textTheme: ThemeData.light().textTheme.apply(
    bodyColor: Colors.grey.shade800,
    displayColor: Colors.black,
  ),
  useMaterial3: true,
);