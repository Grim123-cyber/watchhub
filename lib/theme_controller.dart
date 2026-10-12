import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  ThemeController._privateConstructor();

  static final ThemeController instance =
      ThemeController._privateConstructor();

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode {
    return _isDarkMode
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  void toggleTheme(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }
}