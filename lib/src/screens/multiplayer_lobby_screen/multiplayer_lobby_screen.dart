import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:sudoku/src/models/difficulty.dart';
import 'package:sudoku/src/models/multiplayer.dart';
import 'package:sudoku/src/models/theme.dart';
import 'package:sudoku/src/models/user.dart';
import 'package:sudoku/src/providers/multiplayer_provider.dart';
import 'package:sudoku/src/providers/theme_provider.dart';
import 'package:sudoku/src/providers/user_state_update_provider.dart';
import 'package:sudoku/src/screens/home_screen/home_screen.dart';
import 'package:sudoku/src/screens/multiplayer_game_screen/multiplayer_game_screen.dart';
import 'package:wakelock/wakelock.dart';
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
      this.enableWakeLock();
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
    this.disableWakeLock();
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
    List<MultiplayerGame> tempArray = [];
    snapshot.data.docs.forEach((game) {
      tempArray.add(MultiplayerGame.fromJson(game.data()));
      if (tempArray[tempArray.length - 1]
              .players
              .where((element) => element.id == this.user.id)
              .toList()
              .length >
          0) {
        this.onGoingGames.add(tempArray[tempArray.length - 1]);
      }
    });
  }

  void processStartingGameStreamData(
      AsyncSnapshot snapshot, BuildContext context) {
    this.currentGame = MultiplayerGame.fromJson(snapshot.data.docs[0].data());
    this.hasGameStarted(currentGame, context);
  }

  void hasGameStarted(MultiplayerGame currentGame, BuildContext context) {
    Future.delayed(Duration(seconds: 1), () {
      if (currentGame.players.length > 1) {
        // this.showGameStartingDialog(this.currentGame.players[this
        //     .currentGame
        //     .players
        //     .indexWhere((user) => user.id != this.user.id)]);

        // go to game screen
        this.goToMultiplayerGameScreen();
      }
    });
  }

  showGameStartingDialog(Users user) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: this.appTheme.themeColor,
            title: Text('${user.username} has joined your game',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey[900] : Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircularProfileAvatar(
                  user.profileUrl,
                  radius: MediaQuery.of(context).size.width * 0.1,
                  backgroundColor: appTheme.themeColor,
                  initialsText: Text(
                    getInitials(user.username),
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: isDark ? Colors.grey[900] : Colors.white,
                    ),
                  ),
                  borderColor: Colors.transparent,
                  elevation: 0.0,
                  foregroundColor: Colors.transparent,
                  cacheImage: true,
                  showInitialTextAbovePicture: false,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, top: 8.0, bottom: 8.0),
                  child: Text(
                    'the game will start in a few seconds',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                        color: isDark ? Colors.grey[900] : Colors.white),
                  ),
                ),
                LinearProgressIndicator(
                  backgroundColor: this.appTheme.themeColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      this.isDark ? Colors.grey[900] : Colors.white),
                  minHeight: 1,
                )
              ],
            ),
          );
        });
  }

  String getInitials(String username) {
    List<String> names = username.split(" ");
    String initials = "";
    int numWords = names.length;

    if (numWords < names.length) {
      numWords = names.length;
    }
    for (var i = 0; i < numWords; i++) {
      initials += '${names[i][0]}'.toUpperCase();
    }
    return initials;
  }

  void submitAndJoinGame() {
    if (formKey.currentState.validate()) {
      joinGameWithCode();
    }
  }

  joinGameWithCode() async {
    this.toggleLoading();
    if (await this.multiplayerProvider.checkIfGameExists(this.joiningGameId)) {
      this.currentGame = await this
          .multiplayerProvider
          .joinGame(this.joiningGameId, this.user);
      this.goToMultiplayerGameScreen();
    } else {
      // game with that id does not exist
      this.toggleLoading();
      this.showNoSuchGameSnackBar();
    }
  }

  joinGameFromList(MultiplayerGame game) async {
    this.toggleLoading();
    if (await this.multiplayerProvider.checkIfGameExists(game.id)) {
      this.currentGame =
          await this.multiplayerProvider.joinGame(game.id, this.user);
      this.goToMultiplayerGameScreen();
    } else {
      // game with that id does not exist
      this.toggleLoading();
      this.showNoSuchGameSnackBar();
    }
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
    Future.delayed(Duration(seconds: 1), () {
      scaffoldKey.currentState.showSnackBar(SnackBar(
          backgroundColor: appTheme.themeColor,
          content: Text(
            '${this.currentGame.id} copied to clipbaord',
            style: GoogleFonts.lato(
                color: this.isDark ? Colors.grey[900] : Colors.white),
            textAlign: TextAlign.start,
          )));
    });
  }

  showNoSuchGameSnackBar() {
    Future.delayed(Duration(seconds: 1), () {
      scaffoldKey.currentState.showSnackBar(SnackBar(
          backgroundColor: appTheme.themeColor,
          content: Text(
            'a game with that id was not found',
            style: GoogleFonts.lato(
                color: this.isDark ? Colors.grey[900] : Colors.white),
            textAlign: TextAlign.start,
          )));
    });
  }

  void enableWakeLock() {
    Wakelock.enable();
  }

  void disableWakeLock() {
    Wakelock.disable();
  }

  void goToMultiplayerGameScreen() async {
    disableWakeLock();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) {
        return MultiplayerGameScreenScreen(
          currentGame: this.currentGame,
          user: this.user,
          isSavedGame: this.currentGame.elapsedTime != null,
        );
      },
    ));
  }

  void goToHomeScreen() async {
    this.toggleLoading();
    this.disableWakeLock();
    if (this.isHosting) {
      await this.multiplayerProvider.deleteGame(this.currentGame.id);
    }

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) {
        return HomeScreen(user: this.user);
      },
    ));
  }

  String formatDateTime(String datetime) {
    return Jiffy(datetime).fromNow();
  }

  showJoiningGameFromListDialog(MultiplayerGame game) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            title: Text(
                'rejoin this game with ' +
                    game
                        .players[game.players
                            .indexWhere((element) => element.id != user.id)]
                        .username +
                    '?',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                    color: isDark ? Colors.white : Colors.grey[900])),
            actions: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('oops!',
                          textAlign: TextAlign.end,
                          style: GoogleFonts.lato(
                              color:
                                  isDark ? Colors.white : Colors.grey[900]))),
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      this.joinGameFromList(game);
                    },
                    child: Text(
                      'yes please',
                      textAlign: TextAlign.end,
                      style: GoogleFonts.lato(color: appTheme.themeColor),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }

  showDeleteGameDialog(MultiplayerGame game) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            title: Text(
                'end this game with ' +
                    game
                        .players[game.players
                            .indexWhere((element) => element.id != user.id)]
                        .username +
                    '?',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                    color: isDark ? Colors.white : Colors.grey[900])),
            actions: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('oops!',
                          textAlign: TextAlign.end,
                          style: GoogleFonts.lato(
                              color:
                                  isDark ? Colors.white : Colors.grey[900]))),
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      this.multiplayerProvider.deleteGame(game.id);
                    },
                    child: Text(
                      'mmhm, end it',
                      textAlign: TextAlign.end,
                      style: GoogleFonts.lato(color: appTheme.themeColor),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }
}
