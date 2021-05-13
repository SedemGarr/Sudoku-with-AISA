import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sudoku/src/models/difficulty.dart';
import 'package:sudoku/src/models/multiplayer.dart';
import 'package:sudoku/src/models/theme.dart';
import 'package:sudoku/src/models/user.dart';
import 'package:sudoku/src/providers/multiplayer_provider.dart';
import 'package:sudoku/src/providers/theme_provider.dart';
import 'package:sudoku/src/providers/user_state_update_provider.dart';
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
  String joiningGameId;
  String preferedPattern;

  List<MultiplayerGame> onGoingGames = [];

  MultiplayerGame currentGame;

  AppTheme appTheme;

  ThemeProvider themeProvider = ThemeProvider();
  final formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  MultiplayerProvider multiplayerProvider = MultiplayerProvider();
  UserStateUpdateProvider userStateUpdateProvider = UserStateUpdateProvider();

  void initVariables() {
    this.user = widget.user;
    this.isDark = widget.user.isDark;
    this.preferedPattern = this.user.preferedPattern;
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
      this.multiplayerProvider.deleteGame(this.currentGame.id);
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
    FlutterClipboard.copy(this.currentGame.id)
        .then((value) => this.showCopiedSnackBar());
  }

  void processOngoingGamesStreamData(AsyncSnapshot snapshot) {
    this.onGoingGames = [];
    snapshot.data.docs.forEach((game) {
      this.onGoingGames.add(MultiplayerGame.fromJson(game.data()));
    });
  }

  void processStartingGameStreamData(AsyncSnapshot snapshot) {
    this.currentGame = MultiplayerGame.fromJson(snapshot.data.docs[0].data());
    this.hasGameStarted(currentGame);
  }

  void hasGameStarted(MultiplayerGame currentGame) {
    if (currentGame.players.length == 2) {
      // show dialog where user cannot go back
      // launch in some seconds
    }
  }

  void submitAndJoinGame() {
    if (formKey.currentState.validate()) {}
  }

  void setCompetitiveSetting(bool value) async {
    if (value) {
      setState(() {
        this.currentGame.isCompetitive = true;
        this.currentGame.isCooperative = false;
      });
      this.multiplayerProvider.updateGameSettings(this.currentGame);
    } else {
      setState(() {
        this.currentGame.isCompetitive = false;
        this.currentGame.isCooperative = true;
      });
      this.multiplayerProvider.updateGameSettings(this.currentGame);
    }
  }

  Future<void> setBoardPatterns(String pattern) async {
    switch (pattern) {
      case 'Random':
        setState(() {
          this.preferedPattern = 'Random';
        });
        this.currentGame.level = await Difficulty.regenerateLevel(
            currentGame.difficulty, 400, preferedPattern);
        await this.multiplayerProvider.updateGameSettings(this.currentGame);
        break;
      case 'spring':
        setState(() {
          this.preferedPattern = 'spring';
        });
        this.currentGame.level = await Difficulty.regenerateLevel(
            currentGame.difficulty, 400, preferedPattern);
        await this.multiplayerProvider.updateGameSettings(this.currentGame);
        break;
      case 'summer':
        setState(() {
          this.preferedPattern = 'summer';
        });
        this.currentGame.level = await Difficulty.regenerateLevel(
            currentGame.difficulty, 400, preferedPattern);
        await this.multiplayerProvider.updateGameSettings(this.currentGame);
        break;
      case 'fall':
        setState(() {
          this.preferedPattern = 'fall';
        });
        this.currentGame.level = await Difficulty.regenerateLevel(
            currentGame.difficulty, 400, preferedPattern);
        await this.multiplayerProvider.updateGameSettings(this.currentGame);
        break;
      case 'winter':
        setState(() {
          this.preferedPattern = 'winter';
        });
        this.currentGame.level = await Difficulty.regenerateLevel(
            currentGame.difficulty, 400, preferedPattern);
        await this.multiplayerProvider.updateGameSettings(this.currentGame);
        break;
    }
  }

  showCopiedSnackBar() {
    scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: appTheme.themeColor,
        content: Text(
          '${this.currentGame.id} copied to clipbaord',
          style: GoogleFonts.lato(
              color: this.isDark ? Colors.grey[900] : Colors.white),
          textAlign: TextAlign.start,
        )));
  }

  void goToHomeScreen() async {
    this.toggleLoading();
    if (this.isHosting) {
      await this.multiplayerProvider.deleteGame(this.currentGame.id);
    }

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) {
        return HomeScreen(user: this.user);
      },
    ));
  }
}
