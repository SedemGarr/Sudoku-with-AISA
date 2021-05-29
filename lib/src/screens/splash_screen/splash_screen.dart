import 'package:flutter/material.dart';
import 'package:sudoku/src/models/theme.dart';
import 'package:sudoku/src/models/user.dart';
import 'package:sudoku/src/providers/local_storage_provider.dart';
import 'package:sudoku/src/providers/theme_provider.dart';
import 'package:sudoku/src/screens/auth_screen/auth_screen.dart';
import 'splash_screen_ui.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenView createState() => SplashScreenView();
}

abstract class SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  Users user;
  bool isDark = false;
  AppTheme appTheme = AppTheme.themes[0];
  LocalStorageProvider localStorageProvider = LocalStorageProvider();
  ThemeProvider themeProvider = ThemeProvider();

  void initVariables() async {
    await this.getUser();
    this.getDarkMode();
    this.getTheme();
  }

  @override
  void initState() {
    initVariables();
    super.initState();
  }

  Future<void> getUser() async {
    Users user = await this.localStorageProvider.getUser();
    setState(() {
      this.user = user;
    });
  }

  void getTheme() {
    setState(() {
      this.appTheme = this.themeProvider.getCurrentAppTheme(this.user);
    });
  }

  void getDarkMode() {
    setState(() {
      this.isDark = this.user == null ? false : this.user.isDark;
    });
  }

  Future<void> load() async {
    navigateToAuthScreen(this.user);
  }

  void navigateToAuthScreen(Users user) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) {
        return AuthScreen(user: user);
      },
    ));
  }
}
