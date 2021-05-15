import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sudoku/src/providers/authentication_provider.dart';
import 'package:sudoku/src/providers/connectivity_provider.dart';
import 'package:sudoku/src/providers/local_storage_provider.dart';
import 'package:sudoku/src/providers/multiplayer_provider.dart';
import 'package:sudoku/src/providers/user_state_update_provider.dart';
import 'package:sudoku/src/providers/database_provider.dart';
import 'package:sudoku/src/screens/splash_screen/splash_screen.dart';
import 'settings_screen_ui.dart';
import 'package:sudoku/src/models/theme.dart';
import 'package:sudoku/src/models/user.dart';
import 'package:sudoku/src/screens/home_screen/home_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  final bool isDark;
  final AppTheme appTheme;
  final Users user;

  SettingsScreen(
      {@required this.isDark, @required this.appTheme, @required this.user});

  @override
  SettingsScreenView createState() => SettingsScreenView();
}

abstract class SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  String temporaryUsername;
  String preferedPattern;

  int freePlayDifficulty;

  bool isDark;
  bool enableWakelock;
  bool audioEnabled;
  bool isFriendly;
  bool hasTrainingWheels;
  bool usesLargeFont;
  bool isEditing;
  bool isLoading;

  List<String> helpDialogs = [
    'creature of the night?\n\ntoggle this to switch between light and dark modes. we really don\'t know why you\'d want to use a light theme though. but hey, you do you',
    'blind as a bat?\n\ntoggle this to alternate between a smaller (and better) font and a larger(and much, much worse) font',
    'not a purple person?\n\nselect the theme you prefer. it will be applied across and the app and persist across restarts',
    'need help?\n\nenable this to get extra help solving puzzles. any cells in the same row or column with the same value as the cell you just filled will be highlighted',
    'breezing through the game?\n\nenable this setting to keep your screen on as you solve puzzles. please turn this off if you have a habit of falling asleep with your phone in you hand. we can\'t be held responsible for burnt in pixels',
    'too easy? too hard?\n\nselect a difficulty level for free-play and multiplayer games. you can randomize the difficulty if you like to live on the wild side',
    'we\'re really just flexing at this point\n\ncheck out cool patterns for your sudoku puzzles',
    'shut AISA up?\n\n does what it says on the tin',
    'introverted?\n\nturn this off if you don\'t want to appear in searches for multiplayer game invites',
    'enjoying the torture?\n\nthis will reset your single-player progress. your overall score and free-play statistics will persist though',
    '🥺\n\nwe can change, we promise',
  ];

  Users user;
  AppTheme appTheme;

  File image;
  final picker = ImagePicker();

  final formKey = GlobalKey<FormState>();
  LocalStorageProvider localStorageProvider = LocalStorageProvider();
  ConnectivityProvider connectivityProvider = ConnectivityProvider();
  MultiplayerProvider multiplayerProvider = MultiplayerProvider();
  AuthenticationProvider authenticationProvider = AuthenticationProvider();
  UserStateUpdateProvider userStateUpdateProvider = UserStateUpdateProvider();
  DatabaseProvider databaseProvider = DatabaseProvider();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  initVariables() {
    this.user = widget.user;
    this.isDark = widget.isDark;
    this.appTheme = widget.appTheme;
    this.enableWakelock = this.user.enableWakelock;
    this.audioEnabled = this.user.audioEnabled;
    this.isFriendly = this.user.isFriendly;
    this.hasTrainingWheels = this.user.hasTrainingWheels;
    this.isEditing = false;
    this.preferedPattern = this.user.preferedPattern;
    this.freePlayDifficulty = this.user.freePlayDifficulty;
    this.isLoading = false;
  }

  @override
  void initState() {
    initVariables();
    super.initState();
  }

  // profile
  void setUsername() async {
    setState(() {
      this.user.username = temporaryUsername;
    });
    // save
    this.userStateUpdateProvider.updateUser(this.user);
    // update any ongoing multiplayer games
    MultiplayerProvider multiplayerProvider = MultiplayerProvider();
    await multiplayerProvider.updateOngoingGames(user);
    // disable editing
    this.disableEditing();
    // show snackbar
    Future.delayed(Duration(seconds: 1), () {
      scaffoldKey.currentState.showSnackBar(SnackBar(
          backgroundColor: appTheme.themeColor,
          content: Text(
            'username changed',
            style: GoogleFonts.lato(
                color: this.isDark ? Colors.grey[900] : Colors.white),
            textAlign: TextAlign.center,
          )));
    });
  }

  // appearance
  void setDarkMode(bool value) async {
    setState(() {
      this.isDark = value;
    });
    this.user.isDark = value;
    this.userStateUpdateProvider.updateUser(this.user);
  }

  // gameplay
  void setTrainingwheels(bool value) async {
    setState(() {
      this.hasTrainingWheels = value;
    });
    this.user.hasTrainingWheels = value;
    this.userStateUpdateProvider.updateUser(this.user);
  }

  void setWakelock(bool value) async {
    setState(() {
      this.enableWakelock = value;
    });
    this.user.enableWakelock = value;
    this.userStateUpdateProvider.updateUser(this.user);
  }

  void setFreePlaydifficulty(double value) async {
    setState(() {
      this.freePlayDifficulty = value.toInt();
    });
    this.user.freePlayDifficulty = value.toInt();
    this.userStateUpdateProvider.updateUser(this.user);
  }

  void setFreePlaydifficultyToRandom() async {
    setState(() {
      if (user.freePlayDifficulty != 10) {
        freePlayDifficulty = 10;
        user.freePlayDifficulty = 10;
      } else {
        freePlayDifficulty = 0;
        user.freePlayDifficulty = 0;
      }
    });
    this.userStateUpdateProvider.updateUser(this.user);
  }

  // audio
  void setAudio(bool value) async {
    setState(() {
      this.audioEnabled = value;
    });
    this.user.audioEnabled = value;
    this.userStateUpdateProvider.updateUser(this.user);
  }

  // social
  void setFriendly(bool value) async {
    setState(() {
      this.isFriendly = value;
    });
    this.user.isFriendly = value;
    this.userStateUpdateProvider.updateUser(this.user);
  }

  // unlocked on completion
  void setTheme(AppTheme theme) async {
    setState(() {
      this.appTheme = theme;
    });
    this.user.selectedTheme = AppTheme.themes
        .indexWhere((element) => element.themeColor == theme.themeColor);
    this.userStateUpdateProvider.updateUser(this.user);
  }

  Future<void> setBoardPatterns(String pattern) async {
    switch (pattern) {
      case 'Random':
        setState(() {
          preferedPattern = 'Random';
          this.user.preferedPattern = 'Random';
        });
        await this.userStateUpdateProvider.updateUser(this.user);
        break;
      case 'spring':
        setState(() {
          preferedPattern = 'spring';
          this.user.preferedPattern = 'spring';
        });
        await this.userStateUpdateProvider.updateUser(this.user);
        break;
      case 'summer':
        setState(() {
          preferedPattern = 'summer';
          this.user.preferedPattern = 'summer';
        });
        await this.userStateUpdateProvider.updateUser(this.user);
        break;
      case 'fall':
        setState(() {
          preferedPattern = 'fall';
          this.user.preferedPattern = 'fall';
        });
        await this.userStateUpdateProvider.updateUser(this.user);
        break;
      case 'winter':
        setState(() {
          preferedPattern = 'winter';
          this.user.preferedPattern = 'winter';
        });
        await this.userStateUpdateProvider.updateUser(this.user);
        break;
    }
  }

  showRestartGameDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            title: Text('are you sure?',
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
                      this.resetProgress();
                    },
                    child: Text(
                      'yep, I love the pain',
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

  void resetProgress() async {
    this.toggleLoader();
    await this.databaseProvider.resetGame(this.user);
    this.goToSplashScreen();
  }

  showDeleteAccountDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            title: Text('are you sure?',
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
                      this.deleteAccount();
                    },
                    child: Text(
                      'my mind is made up',
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

  void deleteAccount() async {
    this.toggleLoader();
    await this.authenticationProvider.deleteAccount(this.user);
    this.goToSplashScreen();
  }

  void enableEditing() {
    setState(() {
      this.isEditing = true;
    });
  }

  void disableEditing() {
    setState(() {
      this.isEditing = false;
    });
  }

  showHelpSnackBar(int index) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(seconds: 15),
        backgroundColor: appTheme.themeColor,
        action: SnackBarAction(
          label: 'ok',
          textColor: this.isDark ? Colors.grey[900] : Colors.white,
          onPressed: () {
            scaffoldKey.currentState.hideCurrentSnackBar();
          },
        ),
        content: Text(
          helpDialogs[index],
          style: GoogleFonts.lato(
              color: this.isDark ? Colors.grey[900] : Colors.white),
          textAlign: TextAlign.start,
        )));
  }

  showRestartSnackBar(int index) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: appTheme.themeColor,
        content: Text(
          'success! you game is as fresh as a new born baby',
          style: GoogleFonts.lato(
              color: this.isDark ? Colors.grey[900] : Colors.white),
          textAlign: TextAlign.start,
        )));
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

  void handlePopupSelection(int value) {
    switch (value) {
      case 1:
        this.getImageFromCamera();
        break;
      case 2:
        this.getImageFromGallery();
        break;
      case 3:
        this.removeProfilePhoto();
        break;
    }
  }

  Future getImageFromCamera() async {
    if (await this.connectivityProvider.isConnected()) {
      this.toggleLoader();
      final pickedFile = await picker.getImage(source: ImageSource.camera);

      if (pickedFile != null) {
        this.image = File(pickedFile.path);
        String newProfileUrl = (await this
                .databaseProvider
                .updateProfilePhoto(this.user, this.image))
            .profileUrl;

        setState(() {
          this.user.profileUrl = newProfileUrl;
        });
        this.toggleLoader();
      } else {
        this.toggleLoader();
        print('No image selected.');
      }
    } else
      this.showNoInternetSnackBar();
  }

  Future getImageFromGallery() async {
    if (await this.connectivityProvider.isConnected()) {
      this.toggleLoader();
      final pickedFile = await picker.getImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        this.image = File(pickedFile.path);
        String newProfileUrl = (await this
                .databaseProvider
                .updateProfilePhoto(this.user, this.image))
            .profileUrl;

        setState(() {
          this.user.profileUrl = newProfileUrl;
        });
        this.toggleLoader();
      } else {
        this.toggleLoader();
        print('No image selected.');
      }
    } else
      this.showNoInternetSnackBar();
  }

  Future<void> removeProfilePhoto() async {
    if (await this.connectivityProvider.isConnected()) {
      this.toggleLoader();
      setState(() {
        this.user.profileUrl = '';
      });

      await this.databaseProvider.deleteProfilePhoto(this.user);
      this.toggleLoader();
    } else
      this.showNoInternetSnackBar();
  }

  Future<void> retrieveLostData() async {
    final LostData response = await picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        if (response.type == RetrieveType.video) {
          //  _handleVideo(response.file);
        } else {
          //  _handleImage(response.file);
        }
      });
    } else {
      // _handleError(response.exception);
    }
  }

  void toggleLoader() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  // void goToEditProfileScreen() {
  //   Navigator.of(context).pushReplacement(MaterialPageRoute(
  //     builder: (BuildContext context) {
  //       return EditProfileScreen(
  //         user: this.user,
  //       );
  //     },
  //   ));
  // }

  void goToSplashScreen() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) {
        return SplashScreen();
      },
    ));
  }

  void goToHomeScreen() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) {
        return HomeScreen(user: this.user);
      },
    ));
  }
}
