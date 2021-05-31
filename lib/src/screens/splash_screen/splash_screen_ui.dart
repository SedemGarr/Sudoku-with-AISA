import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sudoku/src/models/theme.dart';
import 'splash_screen.dart';
import 'package:flutter/material.dart';

class SplashScreenView extends SplashScreenState {
  Widget buildSplashScreenAnimation() {
    return Container(
      decoration: BoxDecoration(color: AppTheme.getLightOrDarkModeTheme(isDark)),
      child: Center(
        child: DefaultTextStyle(
          style: GoogleFonts.caveat(
            fontWeight: FontWeight.bold,
            fontSize: 55,
            color: appTheme.themeColor,
          ),
          child: AnimatedTextKit(
            onFinished: load,
            repeatForever: false,
            isRepeatingAnimation: false,
            animatedTexts: [
              FadeAnimatedText('half-full games',
                  textStyle: GoogleFonts.caveat(
                    fontWeight: FontWeight.bold,
                    fontSize: 55,
                    color: appTheme.themeColor,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          body: FutureBuilder(
              future: initVariables(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (appTheme == null) {
                  return Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: AppTheme.getLightOrDarkModeTheme(isDark),
                  );
                }
                return buildSplashScreenAnimation();
              })),
    );
  }
}
