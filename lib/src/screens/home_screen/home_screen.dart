import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:sudoku/src/models/level.dart';
import 'package:sudoku/src/models/theme.dart';
import 'package:sudoku/src/models/user.dart';
import 'package:sudoku/src/models/game.dart';
import 'package:sudoku/src/models/difficulty.dart';
import 'package:sudoku/src/providers/connectivity_provider.dart';
import 'package:sudoku/src/screens/free_play_screen/free_play_screen.dart';
import 'package:sudoku/src/screens/multiplayer_lobby_screen/multiplayer_lobby_screen.dart';
import 'package:sudoku/src/screens/settings_screen/settings_screen.dart';
import 'package:sudoku/src/screens/introduction_screen/introduction_screen.dart';
import 'package:sudoku/src/providers/authentication_provider.dart';
import 'package:sudoku/src/providers/database_provider.dart';
import 'package:sudoku/src/providers/local_storage_provider.dart';
import 'package:sudoku/src/providers/theme_provider.dart';
import 'package:sudoku/src/screens/single_player_game_screen/single_player_game_screen.dart';
import 'package:sudoku/src/screens/splash_screen/splash_screen.dart';
import 'home_screen_ui.dart';

class HomeScreen extends StatefulWidget {
  final Users user;
  final bool fromAuthScreen;

  HomeScreen({@required this.user, this.fromAuthScreen});

  @override
  HomeScreenView createState() => HomeScreenView();
}

abstract class HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  bool isDark = false;
  bool isLeaderboardExpanded = false;

  Users user;
  AppTheme appTheme;
  List<Difficulty> game = [];
  List<Users> leaderboard = [];
  Difficulty currentDifficulty;

  LocalStorageProvider localStorageProvider = LocalStorageProvider();
  DatabaseProvider databaseProvider = DatabaseProvider();
  ThemeProvider themeProvider = ThemeProvider();
  AutoScrollController autoScrollController = AutoScrollController();
  ConnectivityProvider connectivityProvider = ConnectivityProvider();

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  initVariables() async {
    this.getDarkMode();
    this.user = widget.user;
    this.game = this.generateGame();
    await this.initializeGameLevels();
    this.currentDifficulty = Difficulty.getDifficulty(user.difficultyLevel);
    this.appTheme = this.themeProvider.getCurrentAppTheme(this.user);
    this.getTheme();
    this.autoScrollToUserIndex();
    this.showGreeting();
  }

  @override
  void initState() {
    initVariables();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    this.getDarkMode();
    this.getTheme();
    super.didChangeDependencies();
  }

  String parseLevelTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> getDarkMode() async {
    setState(() {
      this.isDark = this.user == null ? false : this.user.isDark;
    });
  }

  void getTheme() {
    AppTheme appTheme = this.themeProvider.getCurrentAppTheme(this.user);
    setState(() {
      this.appTheme = appTheme;
    });
  }

  List<Difficulty> generateGame() {
    return Game.generateGame();
  }

  Future<void> initializeGameLevels() async {
    for (int i = 0; i < 7; i++) {
      this.game[i].levels = await Difficulty.generateLevels(i);
    }
  }

  void processLeaderboardStreamData(AsyncSnapshot snapshot) {
    this.leaderboard = [];
    snapshot.data.docs.forEach((user) {
      this.leaderboard.add(Users(
          freePlayDifficulty: user['freePlayDifficulty'],
          preferedPattern: user['preferedPattern'],
          audioEnabled: user['audioEnabled'],
          profileUrl: user['profileUrl'],
          backupBoard: user['backupBoard'],
          elapsedTime: user['elapsedTime'],
          hasCompletedGame: user['hasCompletedGame'],
          profilePath: user['profilePath'],
          hasCompletedIntro: user['hasCompletedIntro'],
          isDark: user['isDark'],
          fontSize: user['fontSize'],
          enableWakelock: user['enableWakelock'],
          isFriendly: user['isFriendly'],
          selectedTheme: user['selectedTheme'],
          difficultyLevel: user['difficultyLevel'],
          hasTrainingWheels: user['hasTrainingWheels'],
          id: user['id'],
          level: user['level'],
          savedBoard: user['savedBoard'],
          savedSolvedBoard: user['savedSolvedBoard'],
          score: user['score'],
          stats: user['stats'],
          username: user['username']));
    });
  }

  bool isMe(String userId) {
    return userId == this.user.id ? true : false;
  }

  bool isFirst(int index) {
    return index == 0 ? true : false;
  }

  void toggleLeaderboardExpansion() {
    setState(() {
      this.isLeaderboardExpanded = !this.isLeaderboardExpanded;
    });
  }

  bool isUnlocked(int difficultyLevel, int index) {
    return difficultyLevel >= index ? true : false;
  }

  void findMe() {
    if (this.leaderboard.indexWhere((user) => user.id == this.user.id) != -1) {
      this.autoScrollController.scrollToIndex(
          this.leaderboard.indexWhere((user) => user.id == this.user.id),
          preferPosition: AutoScrollPosition.begin);
    }
  }

  void autoScrollToUserIndex() {
    if (this.leaderboard.indexWhere((user) => user.id == this.user.id) != -1) {
      Future.delayed(Duration(seconds: 2), () {
        this.autoScrollController.scrollToIndex(
            this.leaderboard.indexWhere((user) => user.id == this.user.id),
            preferPosition: AutoScrollPosition.begin);
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

  showNoInternetSnackBar() {
    scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: appTheme.themeColor,
        content: Text(
          'it\'s better if you\'re connected to the internet for this. trust us',
          style: GoogleFonts.lato(
              color: this.isDark ? Colors.grey[900] : Colors.white),
          textAlign: TextAlign.start,
        )));
  }

  void showGreeting() {
    if (widget.fromAuthScreen != null && widget.fromAuthScreen) {
      Future.delayed(Duration(seconds: 1), () {
        Scaffold.of(context).showSnackBar(SnackBar(
            backgroundColor: appTheme.themeColor,
            content: Text(
              'welcome back, ' + this.user.username,
              style: GoogleFonts.lato(
                  color: this.isDark ? Colors.grey[900] : Colors.white),
              textAlign: TextAlign.center,
            )));
      });
    }
  }

  void goToMultiplayerLobbyScreen() async {
    if (await this.connectivityProvider.isConnected()) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) {
          return MultiplayerLobbyScreen(user: this.user);
        },
      ));
    } else {
      this.showNoInternetSnackBar();
    }
  }

  void goToSettingsScreen() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) {
        return SettingsScreen(
          appTheme: this.appTheme,
          isDark: this.isDark,
          user: this.user,
        );
      },
    ));
  }

  void startGame() {
    if (this.user.hasCompletedIntro) {
      if (this.user.hasCompletedGame) {
        this.goToFreePlayGameScreen();
      } else {
        this.goToSinglePlayerGameScreen();
      }
    } else {
      this.goToIntroductionScreen();
    }
  }

  void goToIntroductionScreen() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) {
        return IntroductionScreen(
          isDark: this.isDark,
          user: this.user,
          appTheme: this.appTheme,
          game: this.game,
        );
      },
    ));
  }

  void goToSinglePlayerGameScreen() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) {
        return SinglePlayerGameScreen(
          isDark: this.isDark,
          user: this.user,
          appTheme: this.appTheme,
          game: this.game,
          isSavedGame: this.user.elapsedTime != null ? true : false,
        );
      },
    ));
  }

  void goToFreePlayGameScreen() async {
    Level freePlayLevel = await Difficulty.regenerateLevel(
        this.user.freePlayDifficulty, 300, this.user.preferedPattern);

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) {
        return FreePlayScreen(
          isDark: this.isDark,
          user: this.user,
          appTheme: this.appTheme,
          level: freePlayLevel,
          isSavedGame: this.user.elapsedTime != null ? true : false,
        );
      },
    ));
  }

  showSignOutDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            title: Text('leaving so soon?',
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
                      this.signOut();
                    },
                    child: Text(
                      'yeah, I\'ve got to do a thing',
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

  void signOut() async {
    AuthenticationProvider auth = AuthenticationProvider();
    await auth.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) {
        return SplashScreen();
      },
    ));
  }

  showExitDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            title: Text('did we do something wrong?',
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
                      child: Text('sorry, it\'s that pesky back button again',
                          textAlign: TextAlign.end,
                          style: GoogleFonts.lato(
                              color:
                                  isDark ? Colors.white : Colors.grey[900]))),
                  FlatButton(
                    onPressed: () {
                      this.exitApp();
                    },
                    child: Text(
                      'that\'s enough sudoku for today',
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

  void exitApp() {
    SystemNavigator.pop();
  }
}
