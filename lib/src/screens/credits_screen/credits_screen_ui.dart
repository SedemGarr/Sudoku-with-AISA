import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sudoku/src/models/theme.dart';
import 'credits_screen.dart';

class CreditsScreenView extends CreditsScreenState {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          color: AppTheme.getLightOrDarkModeTheme(isDark),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(),
                ),
                TextButton(
                    onPressed: () {
                      endGame();
                    },
                    child: Text(
                      'home',
                      style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: appTheme.themeColor),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
