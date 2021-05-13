import 'package:flutter/material.dart';

class AppTheme {
  MaterialColor themeColor;
  MaterialColor partnerColor;
  AppTheme({
    @required this.themeColor,
    @required this.partnerColor,
  });

  static List<AppTheme> themes = [
    AppTheme(themeColor: Colors.blue, partnerColor: Colors.orange),
    AppTheme(themeColor: Colors.teal, partnerColor: Colors.amber),
    AppTheme(themeColor: Colors.amber, partnerColor: Colors.purple),
    AppTheme(themeColor: Colors.orange, partnerColor: Colors.blue),
    AppTheme(themeColor: Colors.red, partnerColor: Colors.green),
    AppTheme(themeColor: Colors.pink, partnerColor: Colors.amber),
    AppTheme(themeColor: Colors.purple, partnerColor: Colors.amber),
  ];
}
