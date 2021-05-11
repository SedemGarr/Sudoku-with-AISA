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

abstract class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool isDark = false;
  bool hasLoaded = false;
  Users user;
  AppTheme appTheme;
  LocalStorageProvider localStorageProvider = LocalStorageProvider();
  ThemeProvider themeProvider = ThemeProvider();

  void initVariables() async {
    await this.getUser();
    await this.getDarkMode();
    this.getTheme();
    this.delayLoading();
  }

  @override
  void initState() {
    super.initState();
    initVariables();
  }

  void delayLoading() {
    Future.delayed(Duration(milliseconds: 500), () {
      this.setState(() {
        this.hasLoaded = true;
      });
    });
  }

  Future<void> load() async {
    navigateToAuthScreen(this.user);
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

  Future<void> getDarkMode() async {
    setState(() {
      this.isDark = this.user == null ? false : this.user.isDark;
    });
  }

  void navigateToAuthScreen(Users user) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) {
        return AuthScreen(user: user);
      },
    ));
  }
}
