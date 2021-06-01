import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:sudoku/src/components/choice_dialog.dart';
import 'package:sudoku/src/models/level.dart';
import 'package:sudoku/src/models/theme.dart';
import 'package:sudoku/src/models/user.dart';
import 'package:sudoku/src/models/game.dart';
import 'package:sudoku/src/models/difficulty.dart';
import 'package:sudoku/src/providers/connectivity_provider.dart';
import 'package:sudoku/src/providers/notification_provider.dart';
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

abstract class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
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
  PushNotificationProvider pushNotificationProvider = PushNotificationProvider();

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  initVariables() async {
    this.getDarkMode();
    this.user = widget.user;
    this.game = this.generateGame();
    await this.initializeGameLevels();
    this.currentDifficulty = Difficulty.getDifficulty(user.difficultyLevel);
    this.appTheme = this.themeProvider.getCurrentAppTheme(this.user);
    this.getTheme();
    this.initNotifications();
    this.autoScrollToUserIndex();
    this.showGreeting();
    this.syncUserData();
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

  void initNotifications() async {
    this.pushNotificationProvider.initialiseFirebaseMessaging();
  }

  void syncUserData() async {
    this.user = await this.databaseProvider.getUser(this.user.id);
    await this.pushNotificationProvider.saveDeviceToken(this.user);
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
      this.leaderboard.add(Users.fromJson(user.data()));
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
      this.autoScrollController.scrollToIndex(this.leaderboard.indexWhere((user) => user.id == this.user.id), preferPosition: AutoScrollPosition.begin);
    }
  }

  void autoScrollToUserIndex() {
    if (this.leaderboard.indexWhere((user) => user.id == this.user.id) != -1) {
      Future.delayed(Duration(seconds: 2), () {
        this.autoScrollController.scrollToIndex(this.leaderboard.indexWhere((user) => user.id == this.user.id), preferPosition: AutoScrollPosition.begin);
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: appTheme.themeColor,
        content: Text(
          'it\'s better if you\'re connected to the internet for this. trust us',
          style: GoogleFonts.lato(color: AppTheme.getLightOrDarkModeTheme(isDark)),
          textAlign: TextAlign.start,
        )));
  }

  void showGreeting() {
    if (widget.fromAuthScreen != null && widget.fromAuthScreen) {
      Future.delayed(Duration(seconds: 1), () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: appTheme.themeColor,
            content: Text(
              'welcome back, ' + this.user.username,
              style: GoogleFonts.lato(color: AppTheme.getLightOrDarkModeTheme(isDark)),
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

  void startGame() async {
    if (await this.connectivityProvider.isConnected()) {
      if (this.user.hasCompletedIntro) {
        if (this.user.hasCompletedGame) {
          this.goToFreePlayGameScreen();
        } else {
          this.goToSinglePlayerGameScreen();
        }
      } else {
        this.goToIntroductionScreen();
      }
    } else {
      this.showNoInternetSnackBar();
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
    Level freePlayLevel = await Difficulty.regenerateLevel(this.user.freePlayDifficulty, 300, this.user.preferedPattern);

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
    return showChoiceDialog(
        context: context,
        title: 'leaving so soon?',
        contentMessage: '',
        yesMessage: 'yeah, I\'ve got to do a thing',
        noMessage: 'oops!',
        isDark: this.isDark,
        appTheme: appTheme,
        onYes: () {
          this.signOut();
        },
        onNo: () {
          Navigator.pop(context);
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
    return showChoiceDialog(
        context: context,
        title: 'did we do something wrong?',
        contentMessage: '',
        yesMessage: 'that\'s enough sudoku for today',
        noMessage: 'sorry, it\'s that pesky back button again',
        isDark: this.isDark,
        appTheme: appTheme,
        onYes: () {
          this.exitApp();
        },
        onNo: () {
          Navigator.pop(context);
        });
  }

  void exitApp() {
    SystemNavigator.pop();
  }
}
