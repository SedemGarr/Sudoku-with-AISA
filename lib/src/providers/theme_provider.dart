import 'package:sudoku/src/models/theme.dart';
import 'package:sudoku/src/models/user.dart';
import 'package:sudoku/src/providers/local_storage_provider.dart';

class ThemeProvider {
  static LocalStorageProvider localStorageProvider = LocalStorageProvider();

  AppTheme getCurrentAppTheme(Users user) {
    if (user != null) {
      if (user.hasCompletedGame) {
        return AppTheme.themes[user.selectedTheme];
      } else {
        return AppTheme.themes[user.difficultyLevel];
      }
    } else {
      return AppTheme.themes[0];
    }
  }
}
