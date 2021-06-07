import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sudoku/src/models/theme.dart';
import 'credits_screen.dart';

class CreditsScreenView extends CreditsScreenState {
  @override
  Widget build(BuildContext context) {
    loadInWidgets();
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          color: AppTheme.getLightOrDarkModeTheme(isDark),
          child: SafeArea(
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: widgetOpacity,
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
                        style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: appTheme.themeColor),
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
