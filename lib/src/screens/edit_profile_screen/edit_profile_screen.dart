import 'package:flutter/material.dart';
import 'package:sudoku/src/models/theme.dart';
import 'package:sudoku/src/models/user.dart';
import 'package:sudoku/src/providers/theme_provider.dart';
import 'package:sudoku/src/screens/settings_screen/settings_screen.dart';
import 'edit_profile_screen_ui.dart';

class EditProfileScreen extends StatefulWidget {
  final Users user;

  EditProfileScreen({@required this.user});

  @override
  EditProfileScreenView createState() => EditProfileScreenView();
}

abstract class EditProfileScreenState extends State<EditProfileScreen>
    with TickerProviderStateMixin {
  Users user;
  bool isDark;

  AppTheme appTheme;
  ThemeProvider themeProvider = ThemeProvider();

  void initVariables() {
    this.user = widget.user;
    this.isDark = widget.user.isDark;
    this.appTheme = this.themeProvider.getCurrentAppTheme(this.user);
  }

  @override
  void initState() {
    initVariables();
    super.initState();
  }

  void goToSettingsScreen() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) {
        return SettingsScreen(
          appTheme: this.appTheme,
          isDark: this.isDark,
          user: this.user,
        );
      },
    ));
  }
}
