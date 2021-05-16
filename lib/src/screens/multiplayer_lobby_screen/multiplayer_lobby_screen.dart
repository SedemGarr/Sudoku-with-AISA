import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sudoku/src/models/difficulty.dart';
import 'package:sudoku/src/models/multiplayer.dart';
import 'package:sudoku/src/models/theme.dart';
import 'package:sudoku/src/models/user.dart';
import 'package:sudoku/src/providers/multiplayer_provider.dart';
import 'package:sudoku/src/providers/theme_provider.dart';
import 'package:sudoku/src/providers/user_state_update_provider.dart';
import 'package:sudoku/src/screens/friends_screen/friends_screen.dart';
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
    if (currentGame.players.length > 1) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        this.goToMultiplayerGameScreen(context);
      });
    }
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

  void submitAndJoinGame(BuildContext context) {
    if (formKey.currentState.validate()) {
      joinGameWithCode(context);
    }
  }

  joinGameWithCode(BuildContext context) async {
    this.toggleLoading();
    if (await this
        .multiplayerProvider
        .checkIfGameExists(this.joiningGameId, this.user)) {
      this.currentGame = await this
          .multiplayerProvider
          .joinGame(this.joiningGameId, this.user);
      this.goToMultiplayerGameScreen(context);
    } else {
      // game with that id does not exist
      this.toggleLoading();
      this.showNoSuchGameSnackBar();
    }
  }

  joinGameFromList(MultiplayerGame game) async {
    this.toggleLoading();
    if (await this.multiplayerProvider.checkIfGameExists(game.id, this.user)) {
      this.currentGame =
          await this.multiplayerProvider.joinGame(game.id, this.user);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        this.goToMultiplayerGameScreen(context);
      });
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
            'game id copied to clipbaord',
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

  void goToMultiplayerGameScreen(BuildContext contexts) async {
    disableWakeLock();
    Navigator.of(contexts).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) {
        return MultiplayerGameScreenScreen(
          currentGame: this.currentGame,
          user: this.user,
          isSavedGame: this.currentGame.elapsedTime != null,
        );
      },
    ));
  }

  void gotoFriendsScreen() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) {
        return FriendsScreen(
          user: this.user,
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

  void share() {
    Share.share(
        'Hi! use this code to join to my game on Sudoku with AISA: \n\n${this.currentGame.id}');
  }

  showJoiningGameFromListDialog(MultiplayerGame game, BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            title: Text(
                game.players.indexWhere((element) => element.id != user.id) ==
                        -1
                    ? 'rejoing this game?'
                    : 'rejoin this game with ' +
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

  showDeleteGameDialog(MultiplayerGame game, BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            title: Text(
                game.players.indexWhere((element) => element.id != user.id) ==
                        -1
                    ? 'end game?'
                    : 'end this game with ' +
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

  showLeaveGameDialog(MultiplayerGame game, BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            title: Text(
                'leave this game with ' +
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
                      this.multiplayerProvider.leaveGame(game, this.user);
                    },
                    child: Text(
                      'yes, I want to leave',
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
