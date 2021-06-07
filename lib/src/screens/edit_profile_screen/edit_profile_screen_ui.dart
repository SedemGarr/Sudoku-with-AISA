import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:sudoku/src/models/theme.dart';
import 'edit_profile_screen.dart';

class EditProfileScreenView extends EditProfileScreenState {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.getLightOrDarkModeTheme(isDark),
          elevation: 0,
          title: Text(
            'edit your profile',
            style: GoogleFonts.roboto(
              color: appTheme.themeColor,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(
                LineIcons.arrowLeft,
                color: appTheme.themeColor,
              ),
              onPressed: () {
                goToSettingsScreen();
              }),
        ),
        body: Container(
          color: AppTheme.getLightOrDarkModeTheme(isDark),
          child: SafeArea(
            child: Column(
              children: [],
            ),
          ),
        ),
      ),
    );
  }
}
