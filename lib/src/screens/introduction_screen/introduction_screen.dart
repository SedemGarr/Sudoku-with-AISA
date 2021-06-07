import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sudoku/src/models/aisa.dart';
import 'package:sudoku/src/models/difficulty.dart';
import 'package:sudoku/src/models/theme.dart';
import 'package:sudoku/src/models/user.dart';
import 'package:sudoku/src/providers/user_state_update_provider.dart';
import 'package:sudoku/src/screens/single_player_game_screen/single_player_game_screen.dart';
import 'introduction_screen_ui.dart';

class IntroductionScreen extends StatefulWidget {
  final Users user;
  final bool isDark;
  final AppTheme appTheme;
  final List<Difficulty> game;

  IntroductionScreen({@required this.user, @required this.isDark, @required this.appTheme, @required this.game});

  @override
  IntroductionScreenView createState() => IntroductionScreenView();
}

abstract class IntroductionScreenState extends State<IntroductionScreen> with TickerProviderStateMixin {
  Users user;
  bool isDark;
  AppTheme appTheme;
  List<Difficulty> game;
  List<int> sampleBoard = [];

  double widgetOpacity = 0;

  UserStateUpdateProvider userStateUpdateProvider = UserStateUpdateProvider();

  FlutterTts flutterTts = FlutterTts();

  initVariables() {
    this.user = widget.user;
    this.isDark = widget.isDark;
    this.appTheme = widget.appTheme;
    this.game = widget.game;
    this.prepareSampleBoard();
    this.setAISASpeechRate(1.0);
  }

  @override
  void initState() {
    initVariables();
    this.setAISASpeechRate(1.2);
    aisaSpeak('Hi! ' + AISA.introductionDialog[0] + AISA.introductionDialog[1]);
    super.initState();
  }

  @override
  void dispose() {
    this.flutterTts.stop();
    super.dispose();
  }

  void loadInWidgets() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        this.widgetOpacity = 1;
      });
    });
  }

  void prepareSampleBoard() {
    for (int i = 0; i < 81; i++) {
      this.sampleBoard.add(this.generateRandomNumber());
    }
  }

  int generateRandomNumber() {
    Random random = Random();
    int randomNumber = random.nextInt(10);
    if (randomNumber == 0) {
      return this.generateRandomNumber();
    } else {
      return randomNumber;
    }
  }

  void goToSinglePlayerGameScreen() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) {
        return SinglePlayerGameScreen(
          isDark: this.isDark,
          user: this.user,
          appTheme: this.appTheme,
          game: this.game,
          isSavedGame: false,
        );
      },
    ));
  }

  void startGame() async {
    this.aisaStop();
    this.setAISASpeechRate(1.2);
    this.user.hasCompletedIntro = true;
    // save user
    await this.userStateUpdateProvider.updateUser(this.user);
    // go to game
    goToSinglePlayerGameScreen();
  }

  showTermsDialog() async {
    this.aisaStop();
    this.setAISASpeechRate(2.0);
    this.aisaSpeak(AISA.introductionDialog[2]);

    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            backgroundColor: this.appTheme.themeColor,
            title: Text('terms and policies', textAlign: TextAlign.center, style: GoogleFonts.quicksand(color: AppTheme.getLightOrDarkModeTheme(isDark))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Text(AISA.introductionDialog[2], style: GoogleFonts.roboto(color: AppTheme.getLightOrDarkModeTheme(isDark))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () {
                      this.startGame();
                    },
                    child: Text(
                      'proceed',
                      textAlign: TextAlign.end,
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: AppTheme.getLightOrDarkModeTheme(isDark)),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void setAISASpeechRate(double value) async {
    await flutterTts.setSpeechRate(value);
  }

  Future aisaSpeak(String text) async {
    if (this.user.audioEnabled) {
      await flutterTts.speak(text);
    }
  }

  Future aisaStop() async {
    if (this.user.audioEnabled) {
      await flutterTts.stop();
    }
  }
}
