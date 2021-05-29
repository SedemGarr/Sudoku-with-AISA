import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sudoku/src/models/aisa.dart';
import 'package:sudoku/src/models/theme.dart';
import 'introduction_screen.dart';

class IntroductionScreenView extends IntroductionScreenState {
  Widget buildAISAAvatar() {
    return AISA.aisaAvatar(appTheme.themeColor);
  }

  Widget buildBoard() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          // for thick border
          GridView.builder(
              shrinkWrap: true,
              itemCount: 9,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  decoration: BoxDecoration(border: Border.all(color: appTheme.themeColor)),
                );
              }),
          // eliminate outside border
          GridView.builder(
              shrinkWrap: true,
              itemCount: 1,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
              ),
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                    width: 2,
                    color: AppTheme.getLightOrDarkModeTheme(isDark),
                  )),
                );
              }),
          // actual grid
          GridView.builder(
              shrinkWrap: true,
              itemCount: 81,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9,
              ),
              itemBuilder: (BuildContext context, int index) {
                int value = sampleBoard[index];
                return Container(
                  margin: const EdgeInsets.all(2),
                  color: Colors.transparent,
                  child: Center(
                    child: Text(
                      value == 0 ? '-' : value.toString(),
                      style: GoogleFonts.lato(color: appTheme.themeColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }

  Widget buildIntroductionMessage() {
    return Container(
      child: Expanded(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              buildAISAAvatar(),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Hi!',
                    style: GoogleFonts.lato(color: appTheme.themeColor, fontSize: 30),
                  ),
                ),
              ),
              Center(
                child: Text(
                  AISA.introductionDialog[0],
                  style: GoogleFonts.lato(color: appTheme.themeColor),
                ),
              ),
              buildBoard(),
              Center(
                child: Text(
                  AISA.introductionDialog[1],
                  style: GoogleFonts.lato(color: appTheme.themeColor),
                ),
              ),
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
        child: TextButton(
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
          color: AppTheme.getLightOrDarkModeTheme(widget.isDark),
          child: SafeArea(
            child: Column(
              children: [buildIntroductionMessage(), buildContinueButton()],
            ),
          ),
        ),
      ),
    );
  }
}
