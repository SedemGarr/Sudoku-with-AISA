import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'splash_screen.dart';
import 'package:flutter/material.dart';

class SplashScreenView extends SplashScreenState {
  Widget buildSplashScreenAnimation() {
    return Container(
      decoration:
          BoxDecoration(color: isDark ? Colors.grey[900] : Colors.white),
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
            onTap: () {
              print("Tap Event");
            },
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
        body: hasLoaded ? buildSplashScreenAnimation() : Container(),
      ),
    );
  }
}
