import 'package:flutter/material.dart';

/// Состояние темы приложения.
class ThemeState extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  /// Изменить тему на [value].
  void changeMode(ThemeMode value) {
    themeMode = value;
    notifyListeners();
  }
}