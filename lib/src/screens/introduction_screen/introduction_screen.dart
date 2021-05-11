import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
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

  IntroductionScreen(
      {@required this.user,
      @required this.isDark,
      @required this.appTheme,
      @required this.game});

  @override
  IntroductionScreenView createState() => IntroductionScreenView();
}

abstract class IntroductionScreenState extends State<IntroductionScreen>
    with TickerProviderStateMixin {
  Users user;
  bool isDark;
  AppTheme appTheme;
  List<Difficulty> game;

  UserStateUpdateProvider userStateUpdateProvider = UserStateUpdateProvider();

  FlutterTts flutterTts = FlutterTts();

  initVariables() {
    this.user = widget.user;
    this.isDark = widget.isDark;
    this.appTheme = widget.appTheme;
    this.game = widget.game;
  }

  @override
  void initState() {
    initVariables();
    aisaSpeak();
    super.initState();
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
    this.user.hasCompletedIntro = true;
    // save user
    await this.userStateUpdateProvider.updateUser(this.user);
    // go to game
    goToSinglePlayerGameScreen();
  }

  Future aisaSpeak() async {
    if (this.user.audioEnabled) {
      await flutterTts.speak(AISA.introductionDialog[0] +
          AISA.introductionDialog[1] +
          AISA.introductionDialog[2]);
    }
  }

  Future aisaStop() async {
    if (this.user.audioEnabled) {
      await flutterTts.stop();
    }
  }
}
