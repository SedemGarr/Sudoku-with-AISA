import 'package:flutter/material.dart';
import 'package:sudoku/src/models/multiplayer.dart';
import 'package:sudoku/src/models/theme.dart';
import 'package:sudoku/src/models/user.dart';
import 'package:sudoku/src/providers/multiplayer_provider.dart';
import 'package:sudoku/src/providers/theme_provider.dart';
import 'multiplayer_game_screen_ui.dart';

class MultiplayerGameScreenScreen extends StatefulWidget {
  final Users user;
  final MultiplayerGame currentGame;

  MultiplayerGameScreenScreen(
      {@required this.user, @required this.currentGame});

  @override
  MultiplayerGameScreenScreenView createState() =>
      MultiplayerGameScreenScreenView();
}

abstract class MultiplayerGameScreenScreenState
    extends State<MultiplayerGameScreenScreen> with TickerProviderStateMixin {
  Users user;
  MultiplayerGame currentGame;

  bool isDark;
  bool isHost;
  AppTheme appTheme;

  ThemeProvider themeProvider = ThemeProvider();
  MultiplayerProvider multiplayerProvider = MultiplayerProvider();

  initVariables() {
    this.user = widget.user;
    this.currentGame = widget.currentGame;
    this.isDark = this.user.isDark;
    this.isHost = this.user.id == this.currentGame.hostId;
    this.getTheme();
    this.startGameIfHostOnInit();
  }

  @override
  void initState() {
    initVariables();
    super.initState();
  }

  void getTheme() {
    setState(() {
      this.appTheme = this.themeProvider.getCurrentAppTheme(this.user);
    });
  }

  void startGameIfHostOnInit() async {
    if (this.isHost) {
      this.multiplayerProvider.startGameOnInit(this.currentGame);
    }
  }

  void processMultiplayerGameStreamData(AsyncSnapshot snapshot) {
    this.currentGame = MultiplayerGame.fromJson(snapshot.data.docs[0].data());
    // check if game has been won
    // check is player has left
  }
}
