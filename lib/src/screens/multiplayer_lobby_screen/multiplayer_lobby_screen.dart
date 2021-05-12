import 'package:flutter/material.dart';
import 'package:sudoku/src/models/multiplayer.dart';
import 'package:sudoku/src/models/theme.dart';
import 'package:sudoku/src/models/user.dart';
import 'package:sudoku/src/providers/multiplayer_provider.dart';
import 'package:sudoku/src/providers/theme_provider.dart';
import 'package:sudoku/src/screens/home_screen/home_screen.dart';
import 'multiplayer_lobby_screen_ui.dart';

class MultiplayerLobbyScreen extends StatefulWidget {
  final Users user;

  MultiplayerLobbyScreen({@required this.user});

  @override
  MultiplayerLobbyScreenView createState() => MultiplayerLobbyScreenView();
}

abstract class MultiplayerLobbyScreenState extends State<MultiplayerLobbyScreen>
    with TickerProviderStateMixin {
  Users user;
  bool isDark;

  bool isLoading = false;
  bool isHosting = false;
  bool isJoining = true;
  String error = '';
  String gameId;
  String joiningGameId;

  List<MultiplayerGame> onGoingGames = [];

  MultiplayerGame currentGame;

  AppTheme appTheme;

  ThemeProvider themeProvider = ThemeProvider();
  final formKey = GlobalKey<FormState>();
  MultiplayerProvider multiplayerProvider = MultiplayerProvider();

  void initVariables() {
    this.user = widget.user;
    this.isDark = widget.user.isDark;
    this.appTheme = this.themeProvider.getCurrentAppTheme(this.user);
  }

  @override
  void initState() {
    initVariables();
    super.initState();
  }

  void toggleLoading() {
    setState(() {
      this.isLoading = !isLoading;
    });
  }

  void host() {
    if (!isHosting) {
      setState(() {
        isHosting = !isHosting;
        isJoining = !isJoining;
      });

      this.createGame();
    }
  }

  void join() {
    if (!isJoining) {
      multiplayerProvider.deleteGame(this.currentGame.id);
      this.currentGame = null;

      setState(() {
        isJoining = !isJoining;
        isHosting = !isHosting;
      });
    }
  }

  Future<void> createGame() async {
    this.toggleLoading();

    this.currentGame = await multiplayerProvider.createGame(this.user);

    this.toggleLoading();
  }

  void processOngoingGamesStreamData(AsyncSnapshot snapshot) {
    this.onGoingGames = [];

    snapshot.data.docs.forEach((game) {
      this.onGoingGames.add(MultiplayerGame.fromJson(game));
    });
  }

  void processStartingGameStreamData(AsyncSnapshot snapshot) {
    this.currentGame = MultiplayerGame.fromJson(snapshot.data.docs[0].data());
    this.hasGameStarted(currentGame);
  }

  void hasGameStarted(MultiplayerGame currentGame) {
    if (currentGame.players.length == 2) {
      // go to game screen
    }
  }

  void submitAndJoinGame() {
    if (formKey.currentState.validate()) {}
  }

  void goToHomeScreen() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) {
        return HomeScreen(user: this.user);
      },
    ));
  }
}
