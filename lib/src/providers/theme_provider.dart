import 'package:flutter/material.dart';
import 'package:sudoku/src/models/theme.dart';
import 'package:sudoku/src/models/user.dart';
import 'package:sudoku/src/providers/local_storage_provider.dart';

class ThemeProvider {
  static LocalStorageProvider localStorageProvider = LocalStorageProvider();

  Map<int, Color> color = {
    50: Color.fromRGBO(136, 14, 79, .1),
    100: Color.fromRGBO(136, 14, 79, .2),
    200: Color.fromRGBO(136, 14, 79, .3),
    300: Color.fromRGBO(136, 14, 79, .4),
    400: Color.fromRGBO(136, 14, 79, .5),
    500: Color.fromRGBO(136, 14, 79, .6),
    600: Color.fromRGBO(136, 14, 79, .7),
    700: Color.fromRGBO(136, 14, 79, .8),
    800: Color.fromRGBO(136, 14, 79, .9),
    900: Color.fromRGBO(136, 14, 79, 1),
  };

  AppTheme getCurrentAppTheme(Users user) {
    if (user != null) {
      if (user.hasCustomColor) {
        return AppTheme(
            partnerColor: user.customPartnerColor == null ? AppTheme.themes[user.selectedTheme].partnerColor : MaterialColor(user.customPartnerColor, color),
            themeColor: user.customThemeColor == null ? AppTheme.themes[user.selectedTheme].themeColor : MaterialColor(user.customThemeColor, color));
      } else {
        if (user.hasCompletedGame) {
          return AppTheme.themes[user.selectedTheme];
        } else {
          return AppTheme.themes[user.difficultyLevel];
        }
      }
    } else {
      return AppTheme.themes[0];
    }
  }

  MaterialColor processColor(Color colors) {
    return MaterialColor(int.parse(colors.toString().replaceAll('Color', '').replaceAll('(', '').replaceAll(')', '')), color);
  }
}
