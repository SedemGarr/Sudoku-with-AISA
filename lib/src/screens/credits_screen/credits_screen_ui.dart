import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'credits_screen.dart';

class CreditsScreenView extends CreditsScreenState {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          color: isDark ? Colors.grey[900] : Colors.white,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(),
                ),
                FlatButton(
                    splashColor: appTheme.themeColor,
                    onPressed: () {},
                    child: Text(
                      'home',
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          color: appTheme.themeColor),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
