import 'package:flutter/material.dart';

class AppTheme {
  MaterialColor themeColor;
  AppTheme({
    @required this.themeColor,
  });

  static List<AppTheme> themes = [
    AppTheme(
      themeColor: Colors.blue,
    ),
    AppTheme(
      themeColor: Colors.teal,
    ),
    AppTheme(
      themeColor: Colors.amber,
    ),
    AppTheme(
      themeColor: Colors.orange,
    ),
    AppTheme(
      themeColor: Colors.red,
    ),
    AppTheme(
      themeColor: Colors.pink,
    ),
    AppTheme(
      themeColor: Colors.purple,
    ),
  ];
}
