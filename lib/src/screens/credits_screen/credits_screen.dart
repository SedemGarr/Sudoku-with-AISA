import 'package:flutter/material.dart';
import 'package:sudoku/src/models/theme.dart';
import 'package:sudoku/src/models/user.dart';
import 'package:sudoku/src/providers/theme_provider.dart';
import 'credits_screen_ui.dart';

class CreditsScreen extends StatefulWidget {
  final bool isDark;
  final AppTheme appTheme;
  final Users user;

  CreditsScreen(
      {@required this.isDark, @required this.appTheme, @required this.user});

  @override
  CreditsScreenView createState() => CreditsScreenView();
}

abstract class CreditsScreenState extends State<CreditsScreen>
    with TickerProviderStateMixin {
  bool isDark;
  AppTheme appTheme;
  Users user;

  ThemeProvider themeProvider = ThemeProvider();

  initVariables() {
    this.isDark = widget.isDark;
    this.user = widget.user;
    this.getTheme();
  }

  @override
  void initState() {
    this.initVariables();
    super.initState();
  }

  void getTheme() {
    setState(() {
      this.appTheme = this.themeProvider.getCurrentAppTheme(this.user);
    });
  }
}
