import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:sudoku/src/models/aisa.dart';
import 'package:sudoku/src/models/difficulty.dart';
import 'package:sudoku/src/models/level.dart';
import 'package:sudoku/src/models/stats.dart';
import 'package:sudoku/src/models/theme.dart';
import 'package:sudoku/src/models/user.dart';
import 'package:sudoku/src/providers/theme_provider.dart';
import 'package:sudoku/src/providers/user_state_update_provider.dart';
import 'package:sudoku/src/screens/home_screen/home_screen.dart';
import 'package:wakelock/wakelock.dart';
import 'free_play_screen_ui.dart';

class FreePlayScreen extends StatefulWidget {
  final Users user;
  final bool isDark;
  final bool isSavedGame;
  final AppTheme appTheme;
  final Level level;

  FreePlayScreen({@required this.user, @required this.isDark, @required this.appTheme, @required this.level, @required this.isSavedGame});

  @override
  FreePlayScreenView createState() => FreePlayScreenView();
}

abstract class FreePlayScreenState extends State<FreePlayScreen> with TickerProviderStateMixin {
  int selectedIndex;
  int elapsedTime;

  Users user;
  bool isSavedGame;
  AppTheme appTheme;
  Level level;
  List filledCells = [];

  UserStateUpdateProvider userStateUpdateProvider = UserStateUpdateProvider();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ThemeProvider themeProvider = ThemeProvider();

  final stopWatchTimer = StopWatchTimer();
  FlutterTts flutterTts = FlutterTts();
  final random = Random();

  void initVariables() {
    this.user = widget.user;
    this.isSavedGame = widget.isSavedGame;
    this.appTheme = widget.appTheme;
    this.level = widget.level;
    this.elapsedTime = 0;
  }

  @override
  void initState() {
    this.initVariables();
    this.loadSavedGame();
    this.startStopWatchTimer();
    this.enableWakeLock();
    this.findAlreadyFilledCells();
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
    await stopWatchTimer.dispose();
  }

  int generateRandomInt(int min, int max) {
    return min + random.nextInt(max - min);
  }

  void findAlreadyFilledCells() {
    this.filledCells = [];
    for (int i = 0; i < this.level.board.length; i++) {
      if (this.level.board[i] != 0) {
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

  void getTheme() {
    AppTheme appTheme = this.themeProvider.getCurrentAppTheme(this.user);
    setState(() {
      this.appTheme = appTheme;
    });
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
      this.level.board = [...this.user.savedBoard];
      this.level.solvedBoard = [...this.user.savedSolvedBoard];
      this.level.backupBoard = [...this.user.backupBoard];
      // set time
      stopWatchTimer.setPresetSecondTime(this.user.elapsedTime);
      // show snackbar
      Future.delayed(Duration(milliseconds: 500), () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: appTheme.themeColor,
            content: Text(
              'a previous game was loaded',
              style: GoogleFonts.lato(color: AppTheme.getLightOrDarkModeTheme(this.user.isDark)),
              textAlign: TextAlign.center,
            )));
      });
    }
  }

  Color getCellColor(int index, int value) {
    if (this.selectedIndex != null) {
      // if cell is not empty
      if (!this.isCellEmpty(value)) {
        // if cell is not selected but has same value
        // as selected cell
        if (this.level.board[this.selectedIndex] == value && this.selectedIndex != index) {
          return Difficulty.isConflicting(this.selectedIndex, index, this.user.hasTrainingWheels) ? this.appTheme.themeColor[900] : this.appTheme.themeColor[100];
        }
        // if cell is selected
        if (this.selectedIndex == index) {
          return this.appTheme.themeColor;
        } else {
          return Colors.transparent;
        }
      }
      return this.selectedIndex == index ? this.appTheme.themeColor : Colors.transparent;
    }
    return Colors.transparent;
  }

  Color getCellTextColor(int index, int value) {
    if (this.selectedIndex == index) {
      return this.isCellEmpty(value)
          ? this.appTheme.themeColor
          : this.user.isDark
              ? Colors.grey[900]
              : Colors.white;
    } else {
      return this.appTheme.themeColor;
    }
  }

  bool isCellEmpty(int value) {
    return value == 0 ? true : false;
  }

  void selectIndex(int index) {
    setState(() {
      this.selectedIndex = index;
    });
  }

  void setCellValue(int value, BuildContext context) {
    if (this.selectedIndex != null) {
      if (this.level.board[this.selectedIndex] != value) {
        setState(() {
          this.level.board[this.selectedIndex] = value;
        });
      } else {
        setState(() {
          this.level.board[this.selectedIndex] = 0;
        });
      }

      // check if board is solved
      if (this.isPuzzleSolved()) {
        this.user.elapsedTime = this.elapsedTime;
        this.stopStopWatchTimer();
        this.disableWakeLock();
        this.aisaSpeak(AISA.freeDialog[this.generateRandomInt(0, AISA.freeDialog.length)]);
        this.showPuzzleCompleteDialog(context);
      } else {
        // save game state
        this.updateUserStateDuringGame();
      }
    }
  }

  void updateUserStateDuringGame() async {
    this.user.savedBoard = [...this.level.board];
    this.user.savedSolvedBoard = [...this.level.solvedBoard];
    this.user.backupBoard = [...this.level.backupBoard];

    this.user.elapsedTime = this.elapsedTime;
    await this.userStateUpdateProvider.updateUser(this.user);
  }

  bool isPuzzleSolved() {
    bool isPuzzleComplete = true;
    bool isPuzzleCorrect = true;

    // check if puzzle is completed
    for (int i = 0; i < 81; i++) {
      if (this.level.board[i] == 0) {
        isPuzzleComplete = false;
      }
    }

    // if it is completed, check if it correct
    if (isPuzzleComplete) {
      for (int i = 0; i < 81; i++) {
        if (this.level.board[i] != this.level.solvedBoard[i]) {
          isPuzzleCorrect = false;
        }
      }
    }

    if (isPuzzleComplete && !isPuzzleCorrect) {
      // taunt()
    }

    return isPuzzleComplete && isPuzzleCorrect;
  }

  void clearSelectedIndex() {
    setState(() {
      selectedIndex = null;
    });
  }

  void revertBoard() {
    setState(() {
      this.level.board = [...this.level.backupBoard];
    });
  }

  void regenerateBoard() async {
    Level level = await Difficulty.regenerateLevel(this.user.freePlayDifficulty, 300, this.user.preferedPattern);

    // reset timers
    this.stopStopWatchTimer();
    this.resetStopWatchTimer();
    this.startStopWatchTimer();

    setState(() {
      this.level = level;
      this.selectedIndex = null;
    });

    this.findAlreadyFilledCells();
  }

  void goToHomeScreen() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) {
        return HomeScreen(user: this.user);
      },
    ));
  }

  void incrementLevel() {
    this.selectedIndex = null;
    this.updateUserAfterGame();
    this.regenerateBoard();
    this.resetStopWatchTimer();
    this.startStopWatchTimer();
    this.enableWakeLock();
  }

  void updateUserAfterGame() async {
    List<Stats> fpStats = this.user.stats.where((element) => element.level == 300).toList();

    if (fpStats.length < 100) {
      this
          .user
          .stats
          .add(Stats(isCompetitive: false, isCoop: false, gameId: '300', isMultiplayer: false, isSinglePlayer: false, level: 300, timeTaken: this.elapsedTime, wonGame: true));
    } else {
      fpStats.removeAt(0);
      fpStats.add(Stats(isCompetitive: false, isCoop: false, gameId: '300', isMultiplayer: false, isSinglePlayer: false, level: 300, timeTaken: this.elapsedTime, wonGame: true));
      this.user.stats = [...fpStats];
    }

    // update user fields
    this.user.score += 1;
    this.user.elapsedTime = null;
    this.user.backupBoard = [];
    this.user.savedBoard = [];
    this.user.savedSolvedBoard = [];
    // update user
    await this.userStateUpdateProvider.updateUser(this.user);
  }

  showPuzzleCompleteDialog(BuildContext context) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: this.appTheme.themeColor,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 1 / 3,
                    child: Icon(
                      LineIcons.robot,
                      color: AppTheme.getLightOrDarkModeTheme(this.user.isDark),
                      size: MediaQuery.of(context).size.width * 0.55,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Text(AISA.freeDialog[this.generateRandomInt(0, AISA.freeDialog.length)],
                        style: GoogleFonts.lato(color: this.user.isDark ? Colors.grey[900] : Colors.white)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () {
                      this.aisaStop();
                      Navigator.pop(context);
                      incrementLevel();
                    },
                    child: Text(
                      'proceed',
                      textAlign: TextAlign.end,
                      style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: this.user.isDark ? Colors.grey[900] : Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
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
