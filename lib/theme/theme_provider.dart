import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_data.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkTheme = false;
  bool get isDarkTheme => _isDarkTheme;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    _isDarkTheme = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', isDark);
    notifyListeners();
  }

  ThemeData get currentTheme => _isDarkTheme ? AppTheme.darkTheme : AppTheme.theme;
  
  Color get primaryColor => _isDarkTheme ? Colors.deepPurple : Color(0xff68DAE4);
  Color get scaffoldBackgroundColor => _isDarkTheme ? Colors.black : Colors.white;
  Color get textColor => _isDarkTheme ? Colors.white : Colors.black;
  Color get cardColor => _isDarkTheme ? Colors.grey[900]! : Colors.white;
  Color get borderColor => _isDarkTheme ? Colors.grey[700]! : Colors.grey[300]!;
}
