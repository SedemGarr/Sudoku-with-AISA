import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:sudoku/src/models/difficulty.dart';
import 'package:sudoku/src/models/level.dart';
import 'package:sudoku/src/models/multiplayer.dart';
import 'package:sudoku/src/models/stats.dart';
import 'package:sudoku/src/models/theme.dart';
import 'package:sudoku/src/models/user.dart';
import 'package:sudoku/src/providers/multiplayer_provider.dart';
import 'package:sudoku/src/providers/theme_provider.dart';
import 'package:sudoku/src/providers/user_state_update_provider.dart';
import 'package:sudoku/src/screens/home_screen/home_screen.dart';
import 'package:sudoku/src/screens/multiplayer_end_screen/multiplayer_end_screen.dart';
import 'package:wakelock/wakelock.dart';
import 'multiplayer_game_screen_ui.dart';

class MultiplayerGameScreenScreen extends StatefulWidget {
  final Users user;
  final MultiplayerGame currentGame;
  final bool isSavedGame;

  MultiplayerGameScreenScreen(
      {@required this.user,
      @required this.currentGame,
      @required this.isSavedGame});

  @override
  MultiplayerGameScreenScreenView createState() =>
      MultiplayerGameScreenScreenView();
}

abstract class MultiplayerGameScreenScreenState
    extends State<MultiplayerGameScreenScreen> with TickerProviderStateMixin {
  Users user;
  MultiplayerGame currentGame;

  String hostName;
  String partnerName;

  bool isDark;
  bool isHost;
  AppTheme appTheme;

  ThemeProvider themeProvider = ThemeProvider();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  MultiplayerProvider multiplayerProvider = MultiplayerProvider();
  UserStateUpdateProvider userStateUpdateProvider = UserStateUpdateProvider();

  int selectedIndex;
  int elapsedTime;
  List filledCells = [];

  final stopWatchTimer = StopWatchTimer();

  initVariables() {
    this.user = widget.user;
    this.currentGame = widget.currentGame;
    this.isDark = this.user.isDark;
    this.isHost = this.user.id == this.currentGame.hostId;
    this.hostName = this
                .currentGame
                .players
                .indexWhere((element) => element.id != this.user.id) ==
            -1
        ? this.user.username
        : this
            .currentGame
            .players[this
                .currentGame
                .players
                .indexWhere((element) => element.id != this.user.id)]
            .username;
    this.partnerName = this
                .currentGame
                .players
                .indexWhere((element) => element.id != this.user.id) ==
            -1
        ? this.user.username
        : this
            .currentGame
            .players[this
                .currentGame
                .players
                .indexWhere((element) => element.id != this.user.id)]
            .username;
    this.getTheme();
    this.startGameIfHostOnInit();
    this.loadSavedGame();
    this.startStopWatchTimer();
    this.enableWakeLock();
    if (!widget.isSavedGame) {
      this.findAlreadyFilledCells();
    }
    this.removeDuplicatePlayers();
  }

  @override
  void initState() {
    initVariables();
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
    await stopWatchTimer.dispose();
  }

  void removeDuplicatePlayers() async {
    if (this.currentGame.players.length > 2) {
      List<Users> tempArray = [];
      for (int i = 0; i < this.currentGame.players.length; i++) {
        if (i > 0) {
          if (this.currentGame.players[i].id !=
              this.currentGame.players[i - 1].id) {
            tempArray.add(this.currentGame.players[i]);
          }
        } else {
          tempArray.add(this.currentGame.players[i]);
        }
      }
      this.currentGame.players = [...tempArray];
      await this.multiplayerProvider.updateGameSettings(this.currentGame);
    }
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
    // check if a player has left the game
    if (this.currentGame.players.length >
        snapshot.data.docs[0].data()['players'].length) {
      // show player left snackbar
      showPlayerLeftSnackbar();
    }

    if (snapshot.data.docs.length > 0) {
      this.currentGame = MultiplayerGame.fromJson(snapshot.data.docs[0].data());
      // check if board is solved
      if (this.isPuzzleSolved()) {
        this.currentGame.elapsedTime = this.elapsedTime;
        if (!this.currentGame.hasFinished) {
          this.updateUserAfterGame();
        }
        this.stopStopWatchTimer();
        this.currentGame.hasFinished = true;
      } else {
        if (this.currentGame.elapsedTime == null) {
          this.stopStopWatchTimer();
          this.resetStopWatchTimer();
          this.startStopWatchTimer();
          this.findAlreadyFilledCells();
        }
      }
    }
  }

  void clearSelectedIndex() {
    if (this.selectedIndex != null) {
      setState(() {
        selectedIndex = null;
      });

      if (isHost) {
        this.currentGame.hostSelectedIndex = null;
      } else {
        this.currentGame.participantSelectedIndex = null;
      }
      this.currentGame.lastPlayedOn = DateTime.now().toString();
      this.currentGame.lastPlayer = this.user.id;
      this.currentGame.level.board = [
        ...this.currentGame.level.solvedBoard
      ]; // don't forget to clear this after testing
      this.multiplayerProvider.updateGameSettings(this.currentGame);
    }
  }

  void findAlreadyFilledCells() {
    this.filledCells = [];
    for (int i = 0; i < this.currentGame.level.board.length; i++) {
      if (this.currentGame.level.board[i] != 0) {
        this.filledCells.add(i);
      }
    }
  }

  int getAdjustedLevel(int level) {
    int adjustedLevel = level + 1;
    switch (this.user.difficultyLevel) {
      case 0:
        return adjustedLevel += 0;
        break;
      case 1:
        return adjustedLevel += 9;
        break;
      case 2:
        return adjustedLevel += 18;
        break;
      case 3:
        return adjustedLevel += 27;
        break;
      case 4:
        return adjustedLevel += 36;
        break;
      case 5:
        return adjustedLevel += 45;
        break;
      default:
        return 100;
    }
  }

  void enableWakeLock() {
    if (this.user.enableWakelock) {
      Wakelock.enable();
    }
  }

  void disableWakeLock() {
    if (this.user.enableWakelock) {
      Wakelock.disable();
    }
  }

  void startStopWatchTimer() {
    this.stopWatchTimer.onExecute.add(StopWatchExecute.start);
  }

  void stopStopWatchTimer() {
    stopWatchTimer.onExecute.add(StopWatchExecute.stop);
  }

  void resetStopWatchTimer() {
    stopWatchTimer.setPresetSecondTime(0);
    stopWatchTimer.onExecute.add(StopWatchExecute.reset);
  }

  void loadSavedGame() {
    if (widget.isSavedGame) {
      stopWatchTimer.setPresetSecondTime(this.currentGame.elapsedTime);
      // show snackbar
      Future.delayed(Duration(milliseconds: 500), () {
        scaffoldKey.currentState.showSnackBar(SnackBar(
            backgroundColor: appTheme.themeColor,
            content: Text(
              'continuing your previously saved game',
              style: GoogleFonts.lato(
                  color: this.user.isDark ? Colors.grey[900] : Colors.white),
              textAlign: TextAlign.center,
            )));
      });
    }
  }

  void showPlayerLeftSnackbar() {
    Future.delayed(Duration(milliseconds: 500), () {
      scaffoldKey.currentState.showSnackBar(SnackBar(
          backgroundColor: appTheme.themeColor,
          content: Text(
            '$partnerName has left the game',
            style: GoogleFonts.lato(
                color: this.user.isDark ? Colors.grey[900] : Colors.white),
            textAlign: TextAlign.center,
          )));
    });
  }

  Color getCellColor(int index, int value) {
    if (this.selectedIndex != null) {
      // if cell is not empty
      if (!this.isCellEmpty(value)) {
        // if cell is not selected but has same value
        // as selected cell
        if (this.currentGame.level.board[this.selectedIndex] == value &&
            this.selectedIndex != index) {
          return Difficulty.isConflicting(
                  this.selectedIndex, index, user.hasTrainingWheels)
              ? this.appTheme.partnerColor
              : this.appTheme.themeColor[100];
        }
        // if cell is selected
        if (this.selectedIndex == index) {
          return this.appTheme.themeColor;
        } else {
          return Colors.transparent;
        }
      }
      return this.selectedIndex == index
          ? this.appTheme.themeColor
          : Colors.transparent;
    }
    return Colors.transparent;
  }

  Color getCellTextColor(int index, int value) {
    if (this.selectedIndex == index) {
      return this.isCellEmpty(value)
          ? isSelectedByOther(index)
              ? this.appTheme.partnerColor
              : this.appTheme.themeColor
          : isSelectedByOther(index)
              ? this.appTheme.partnerColor
              : this.user.isDark
                  ? Colors.grey[900]
                  : Colors.white;
    } else {
      if (this.selectedIndex != null) {
        return isSelectedByOther(index)
            ? Difficulty.isConflicting(
                    this.selectedIndex, index, this.user.hasTrainingWheels)
                ? this.appTheme.themeColor
                : this.appTheme.partnerColor
            : this.appTheme.themeColor;
      } else {
        return isSelectedByOther(index)
            ? this.appTheme.partnerColor
            : this.appTheme.themeColor;
      }
    }
  }

  isSelectedByOther(int index) {
    if (isHost) {
      return this.currentGame.participantSelectedIndex == index;
    } else {
      return this.currentGame.hostSelectedIndex == index;
    }
  }

  double getCellFontSize(int index) {
    if (this.isHost) {
      return this.currentGame.participantSelectedIndex == index ? 20 : 14;
    } else {
      return this.currentGame.hostSelectedIndex == index ? 20 : 14;
    }
  }

  FontStyle getCellFontStyle(index) {
    if (this.isHost) {
      return this.currentGame.participantSelectedIndex == index
          ? FontStyle.italic
          : FontStyle.normal;
    } else {
      return this.currentGame.hostSelectedIndex == index
          ? FontStyle.italic
          : FontStyle.normal;
    }
  }

  FontWeight getCellFontWeight(index) {
    if (this.isHost) {
      return this.currentGame.participantSelectedIndex == index
          ? FontWeight.bold
          : FontWeight.bold;
    } else {
      return this.currentGame.hostSelectedIndex == index
          ? FontWeight.bold
          : FontWeight.bold;
    }
  }

  bool isCellEmpty(int value) {
    return value == 0 ? true : false;
  }

  void selectIndex(int index) async {
    setState(() {
      this.selectedIndex = index;
    });

    if (this.currentGame.isCooperative) {
      if (isHost) {
        this.currentGame.hostSelectedIndex = index;
      } else {
        this.currentGame.participantSelectedIndex = index;
      }
      this.currentGame.lastPlayedOn = DateTime.now().toString();
      this.currentGame.lastPlayer = this.user.id;
      this.currentGame.elapsedTime = this.elapsedTime;
      this.multiplayerProvider.updateGameSettings(this.currentGame);
    }
  }

  void setCellValue(int value, BuildContext context) {
    if (this.selectedIndex != null) {
      if (this.currentGame.level.board[this.selectedIndex] != value) {
        setState(() {
          this.currentGame.level.board[this.selectedIndex] = value;
        });
      } else {
        setState(() {
          this.currentGame.level.board[this.selectedIndex] = 0;
        });
      }

      // save game state
      this.updateUserStateDuringGame();
    }
  }

  void updateUserStateDuringGame() async {
    if (this.currentGame.isCooperative) {
      this.currentGame.elapsedTime = this.elapsedTime;
      this.currentGame.lastPlayedOn = DateTime.now().toString();
      this.currentGame.lastPlayer = this.user.id;
      this.multiplayerProvider.updateGameSettings(this.currentGame);
    }
  }

  bool isPuzzleSolved() {
    bool isPuzzleComplete = true;
    bool isPuzzleCorrect = true;

    // check if puzzle is completed
    for (int i = 0; i < 81; i++) {
      if (this.currentGame.level.board[i] == 0) {
        isPuzzleComplete = false;
      }
    }

    // if it is completed, check if it correct
    if (isPuzzleComplete) {
      for (int i = 0; i < 81; i++) {
        if (this.currentGame.level.board[i] !=
            this.currentGame.level.solvedBoard[i]) {
          isPuzzleCorrect = false;
        }
      }
    }

    if (isPuzzleComplete && isPuzzleCorrect) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> regenerateBoard() async {
    Level level = await Difficulty.regenerateLevel(
        this.currentGame.difficulty, 400, this.currentGame.preferedPattern);

    // reset timers
    this.stopStopWatchTimer();
    this.resetStopWatchTimer();
    this.startStopWatchTimer();

    setState(() {
      this.selectedIndex = null;
      this.currentGame.level = level;
      this.currentGame.hostSelectedIndex = null;
      this.currentGame.participantSelectedIndex = null;
      this.currentGame.elapsedTime = null;
      this.currentGame.hasFinished = false;
      this.currentGame.hasStarted = true;
      this.currentGame.lastPlayedOn = DateTime.now().toString();
    });

    await this.multiplayerProvider.updateGameSettings(this.currentGame);
  }

  void goToHomeScreen() {
    this.disableWakeLock();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) {
        return HomeScreen(user: this.user);
      },
    ));
  }

  void goToMultiplayerEndScreen() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) {
        return MultiplayerEndScreen();
      },
    ));
  }

  void replay() async {
    await this.regenerateBoard();
    this.resetStopWatchTimer();
    this.startStopWatchTimer();
    this.enableWakeLock();
    this.findAlreadyFilledCells();
  }

  void updateUserAfterGame() async {
    List<Stats> mpStats = this
        .user
        .stats
        .where((element) => element.isCompetitive || element.isCoop)
        .toList();

    if (mpStats.length < 100) {
      this.user.stats.add(Stats(
          isCompetitive: this.currentGame.isCompetitive,
          isCoop: this.currentGame.isCompetitive,
          isMultiplayer: true,
          isSinglePlayer: false,
          level: 400,
          timeTaken: this.elapsedTime,
          wonGame: true));
    } else {
      mpStats.removeAt(0);
      mpStats.add(Stats(
          isCompetitive: this.currentGame.isCompetitive,
          isCoop: this.currentGame.isCompetitive,
          isMultiplayer: true,
          isSinglePlayer: false,
          level: 400,
          timeTaken: this.elapsedTime,
          wonGame: true));
      this.user.stats = [...mpStats];
    }

    // update user fields
    this.user.score += 1;
    // update user
    await this.userStateUpdateProvider.updateUser(this.user);
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
                      this.goToHomeScreen();
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
                      this.goToHomeScreen();
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
          this.currentGame.preferedPattern = 'Random';
        });

        break;
      case 'spring':
        setState(() {
          this.currentGame.preferedPattern = 'spring';
        });

        break;
      case 'summer':
        setState(() {
          this.currentGame.preferedPattern = 'summer';
        });

        break;
      case 'fall':
        setState(() {
          this.currentGame.preferedPattern = 'fall';
        });

        break;
      case 'winter':
        setState(() {
          this.currentGame.preferedPattern = 'winter';
        });
        break;
    }
    this.multiplayerProvider.updateGameSettings(this.currentGame);
  }

  String parseLevelTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
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
}
