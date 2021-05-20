import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sudoku/src/models/aisa.dart';
import 'introduction_screen.dart';

class IntroductionScreenView extends IntroductionScreenState {
  Widget buildAISAAvatar() {
    return AISA.aisaAvatar(appTheme.themeColor);
  }

  Widget buildIntroductionMessage() {
    return Container(
      child: Expanded(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Hi!',
                    style: GoogleFonts.lato(
                        color: appTheme.themeColor, fontSize: 30),
                  ),
                ),
              ),
              Center(
                child: Text(
                  AISA.introductionDialog[0],
                  style: GoogleFonts.lato(color: appTheme.themeColor),
                ),
              ),
              Center(
                child: Text('image here'),
              ),
              Center(
                child: Text(
                  AISA.introductionDialog[1],
                  style: GoogleFonts.lato(color: appTheme.themeColor),
                ),
              ),
              Divider(
                color: appTheme.themeColor,
              ),
              Center(
                child: Text(
                  AISA.introductionDialog[2],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                      color: appTheme.themeColor,
                      fontWeight: FontWeight.w100,
                      fontSize: 13),
                ),
              ),
              Divider(
                color: appTheme.themeColor,
              ),
              buildContinueButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget buildContinueButton() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FlatButton(
          child: Text(
            'start',
            style: GoogleFonts.lato(color: appTheme.themeColor),
          ),
          onPressed: () {
            showTermsDialog();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          color: widget.isDark ? Colors.grey[900] : Colors.white,
          child: SafeArea(
            child: Column(
              children: [
                buildAISAAvatar(),
                buildIntroductionMessage(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
