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
import 'package:sudoku/src/screens/credits_screen/credits_screen.dart';
import 'package:wakelock/wakelock.dart';
import 'single_player_game_screen_ui.dart';
import 'package:sudoku/src/screens/home_screen/home_screen.dart';

class SinglePlayerGameScreen extends StatefulWidget {
  final Users user;
  final bool isDark;
  final bool isSavedGame;
  final AppTheme appTheme;
  final List<Difficulty> game;

  SinglePlayerGameScreen({@required this.user, @required this.isDark, @required this.appTheme, @required this.game, @required this.isSavedGame});

  @override
  SinglePlayerGameScreenView createState() => SinglePlayerGameScreenView();
}

abstract class SinglePlayerGameScreenState extends State<SinglePlayerGameScreen> with TickerProviderStateMixin {
  int selectedIndex;
  int elapsedTime;

  Users user;
  bool isDark;
  AppTheme appTheme;
  List<Difficulty> game;
  List filledCells = [];

  double widgetOpacity = 0;

  UserStateUpdateProvider userStateUpdateProvider = UserStateUpdateProvider();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ThemeProvider themeProvider = ThemeProvider();

  final stopWatchTimer = StopWatchTimer();
  FlutterTts flutterTts = FlutterTts();

  initVariables() {
    this.user = widget.user;
    this.isDark = widget.isDark;
    this.appTheme = widget.appTheme;
    this.game = widget.game;
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

  void loadInWidgets() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        this.widgetOpacity = 1;
      });
    });
  }

  void findAlreadyFilledCells() {
    this.filledCells = [];
    for (int i = 0; i < this.game[this.user.difficultyLevel].levels[this.user.level].board.length; i++) {
      if (this.game[this.user.difficultyLevel].levels[this.user.level].board[i] != 0) {
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

  Widget getCurrentLevelForAppBar() {
    int adjustedLevel = this.getAdjustedLevel(this.user.level);
    return Text(
      adjustedLevel.toString(),
      style: GoogleFonts.quicksand(color: this.appTheme.themeColor, fontWeight: FontWeight.bold),
    );
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
      this.game[this.user.difficultyLevel].levels[this.user.level].board = [...this.user.savedBoard];
      this.game[this.user.difficultyLevel].levels[this.user.level].solvedBoard = [...this.user.savedSolvedBoard];
      this.game[this.user.difficultyLevel].levels[this.user.level].backupBoard = [...this.user.backupBoard];
      // set time
      stopWatchTimer.setPresetSecondTime(this.user.elapsedTime);
      // show snackbar
      Future.delayed(Duration(milliseconds: 500), () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: appTheme.themeColor,
            content: Text(
              'a previous game was loaded',
              style: GoogleFonts.quicksand(color: AppTheme.getLightOrDarkModeTheme(isDark)),
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
        if (this.game[this.user.difficultyLevel].levels[this.user.level].board[this.selectedIndex] == value && this.selectedIndex != index) {
          return Difficulty.isConflicting(this.selectedIndex, index, this.user.hasTrainingWheels) ? this.appTheme.partnerColor : this.appTheme.themeColor[100];
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
          : this.isDark
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
      if (this.game[this.user.difficultyLevel].levels[this.user.level].board[this.selectedIndex] != value) {
        setState(() {
          this.game[this.user.difficultyLevel].levels[this.user.level].board[this.selectedIndex] = value;
        });
      } else {
        setState(() {
          this.game[this.user.difficultyLevel].levels[this.user.level].board[this.selectedIndex] = 0;
        });
      }

      // check if board is solved
      if (this.isPuzzleSolved()) {
        this.user.elapsedTime = this.elapsedTime;
        this.stopStopWatchTimer();
        this.disableWakeLock();
        this.aisaSpeak(AISA.gameDialog[this.getAdjustedLevel(this.user.level) - 1]);
        this.showPuzzleCompleteDialog(context, this.user.difficultyLevel, this.user.level);
      } else {
        // save game state
        this.updateUserStateDuringGame();
      }
    }
  }

  void updateUserStateDuringGame() async {
    this.user.savedBoard = [...this.game[this.user.difficultyLevel].levels[this.user.level].board];
    this.user.savedSolvedBoard = [...this.game[this.user.difficultyLevel].levels[this.user.level].solvedBoard];
    this.user.backupBoard = [...this.game[this.user.difficultyLevel].levels[this.user.level].backupBoard];

    this.user.elapsedTime = this.elapsedTime;
    await this.userStateUpdateProvider.updateUser(this.user);
  }

  bool isPuzzleSolved() {
    bool isPuzzleComplete = true;
    bool isPuzzleCorrect = true;

    // check if puzzle is completed
    for (int i = 0; i < 81; i++) {
      if (this.game[this.user.difficultyLevel].levels[this.user.level].board[i] == 0) {
        isPuzzleComplete = false;
      }
    }

    // if it is completed, check if it correct
    if (isPuzzleComplete) {
      for (int i = 0; i < 81; i++) {
        if (this.game[this.user.difficultyLevel].levels[this.user.level].board[i] != this.game[this.user.difficultyLevel].levels[this.user.level].solvedBoard[i]) {
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
      this.game[this.user.difficultyLevel].levels[this.user.level].board = [...this.game[this.user.difficultyLevel].levels[this.user.level].backupBoard];
    });
  }

  void regenerateBoard(int difficultyLevel, int levelNumber) async {
    Level level = await Difficulty.regenerateLevel(difficultyLevel, levelNumber, 'Random');

    // reset timers
    this.stopStopWatchTimer();
    this.resetStopWatchTimer();
    this.startStopWatchTimer();

    setState(() {
      this.game[this.user.difficultyLevel].levels[this.user.level] = level;
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

  void incrementLevel(int difficultyLevel, int level) {
    if (this.getAdjustedLevel(level) != 100) {
      if (++level < this.game[this.user.difficultyLevel].levels.length) {
        setState(() {
          this.user.score += 1;
          this.user.level += 1;
          this.selectedIndex = null;
          this.findAlreadyFilledCells();
        });
      } else {
        if (++difficultyLevel < (this.game.length - 1)) {
          setState(() {
            this.user.level = 0;
            this.user.score += 1;
            this.user.difficultyLevel += 1;
            this.selectedIndex = null;
            this.findAlreadyFilledCells();
          });
          this.getTheme();
        } else {
          // complete game
          this.updateUserAfterFinalGame();
          // this.getTheme();
          this.goToCreditsScreen();
        }
      }
      // update user
      this.updateUserAfterGame();
      this.resetStopWatchTimer();
      this.startStopWatchTimer();
      this.enableWakeLock();
    } else {
      // complete game
      this.updateUserAfterFinalGame();
      // this.getTheme();
      this.goToCreditsScreen();
    }
  }

  void updateUserAfterFinalGame() async {
    // create new stat
    this.user.stats.add(Stats(
        isCompetitive: false,
        isCoop: false,
        isMultiplayer: false,
        isSinglePlayer: true,
        gameId: '54',
        level: 54,
        timeTaken: this.elapsedTime,
        wonGame: true,
        difficulty: this.user.difficultyLevel));
    // update user fields
    this.user.hasCompletedGame = true;
    this.user.level = 0;
    this.user.difficultyLevel = 6;
    this.user.elapsedTime = null;
    this.user.backupBoard = [];
    this.user.savedBoard = [];
    this.user.savedSolvedBoard = [];
    // update user
    await this.userStateUpdateProvider.updateUser(this.user);
  }

  void updateUserAfterGame() async {
    // create new stat
    if (this.user.stats.where((element) => element.isSinglePlayer).toList().length < 54) {
      this.user.stats.add(Stats(
          isCompetitive: false,
          isCoop: false,
          isMultiplayer: false,
          gameId: this.getAdjustedLevel(this.user.level) == 100 ? '54' : (this.getAdjustedLevel(this.user.level) - 1).toString(),
          isSinglePlayer: true,
          level: this.getAdjustedLevel(this.user.level) == 100 ? 54 : this.getAdjustedLevel(this.user.level) - 1,
          timeTaken: this.elapsedTime,
          wonGame: true,
          difficulty: this.user.difficultyLevel));
    }
    // update user fields
    this.user.elapsedTime = null;
    this.user.backupBoard = [];
    this.user.savedBoard = [];
    this.user.savedSolvedBoard = [];
    // update user
    await this.userStateUpdateProvider.updateUser(this.user);
  }

  showPuzzleCompleteDialog(BuildContext context, int difficultyLevel, int level) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
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
                      color: AppTheme.getLightOrDarkModeTheme(isDark),
                      size: MediaQuery.of(context).size.width * 0.55,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Text(AISA.gameDialog[this.getAdjustedLevel(this.user.level) - 1], style: GoogleFonts.roboto(color: AppTheme.getLightOrDarkModeTheme(isDark))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () {
                      this.aisaStop();
                      Navigator.pop(context);
                      incrementLevel(difficultyLevel, level);
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

  void goToCreditsScreen() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) {
        return CreditsScreen(
          appTheme: this.appTheme,
          isDark: this.isDark,
          user: this.user,
        );
      },
    ));
  }
}
