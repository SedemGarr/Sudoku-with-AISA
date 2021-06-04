import 'package:flutter/material.dart';
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sudoku/src/components/choice_dialog.dart';
import 'package:sudoku/src/components/image_cropper.dart';
import 'package:sudoku/src/components/photo_viewer.dart';
import 'package:sudoku/src/providers/authentication_provider.dart';
import 'package:sudoku/src/providers/connectivity_provider.dart';
import 'package:sudoku/src/providers/local_storage_provider.dart';
import 'package:sudoku/src/providers/multiplayer_provider.dart';
import 'package:sudoku/src/providers/theme_provider.dart';
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

  SettingsScreen({@required this.isDark, @required this.appTheme, @required this.user});

  @override
  SettingsScreenView createState() => SettingsScreenView();
}

abstract class SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
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
  bool isChoosingCustomColor;

  List<String> helpDialogs = [
    'creature of the night?\n\ntoggle this to switch between light and dark modes. we really don\'t know why you\'d want to use a light theme though. but hey, you do you',
    'blind as a bat?\n\ntoggle this to alternate between a smaller (and better) font and a larger(and much, much worse) font',
    'not a purple person?\n\nselect the theme you prefer. it will be applied across and the app and persist across restarts',
    'need help?\n\nenable this to get extra help solving puzzles. any cells in the same row or column with the same value as the cell you just filled will be highlighted',
    'breezing through the game?\n\nenable this setting to keep your screen on as you solve puzzles. please turn this off if you have a habit of falling asleep with your phone in you hand. we can\'t be held responsible for burnt in pixels',
    'too easy? too hard?\n\nselect a difficulty level for free-play and multiplayer games. you can randomize the difficulty if you like to live on the wild side',
    'we\'re really just flexing at this point\n\ncheck out cool patterns for your sudoku puzzles',
    'shut AISA up?\n\n does what it says on the tin',
    'introverted?\n\nturn this off if you want only your friends to invite you to multiplayer games',
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
  ThemeProvider themeProvider = ThemeProvider();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  CircleColorPickerController circleColorPickerThemeColorController;
  CircleColorPickerController circleColorPickerPartnerColorController;

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
    this.isChoosingCustomColor = this.user.hasCustomColor;
  }

  @override
  void initState() {
    initVariables();
    super.initState();
  }

  void getTheme() {
    setState(() {
      this.appTheme = this.themeProvider.getCurrentAppTheme(this.user);
    });
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: appTheme.themeColor,
          content: Text(
            'username changed',
            style: GoogleFonts.lato(color: AppTheme.getLightOrDarkModeTheme(isDark)),
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
      if (this.user.freePlayDifficulty != 6) {
        this.freePlayDifficulty = 6;
        this.user.freePlayDifficulty = 6;
      } else {
        this.freePlayDifficulty = 0;
        this.user.freePlayDifficulty = 0;
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
    this.user.selectedTheme = AppTheme.themes.indexWhere((element) => element.themeColor == theme.themeColor);
    this.user.hasCustomColor = false;
    this.user.customPartnerColor = null;
    this.user.customThemeColor = null;
    this.userStateUpdateProvider.updateUser(this.user);
  }

  void setCustomThemeColor(Color colors) async {
    setState(() {
      appTheme.themeColor = this.themeProvider.processColor(colors);
    });
    // update user
    this.user.hasCustomColor = true;
    this.user.customThemeColor = int.parse(colors.toString().replaceAll('Color', '').replaceAll('(', '').replaceAll(')', ''));
    this.userStateUpdateProvider.updateUser(this.user);
  }

  void setCustomPartnerColor(Color colors) async {
    setState(() {
      appTheme.partnerColor = this.themeProvider.processColor(colors);
    });
    // update user
    this.user.hasCustomColor = true;
    this.user.customPartnerColor = int.parse(colors.toString().replaceAll('Color', '').replaceAll('(', '').replaceAll(')', ''));
    this.userStateUpdateProvider.updateUser(this.user);
  }

  void toggleCustomTheme() {
    setState(() {
      isChoosingCustomColor = !isChoosingCustomColor;
      if (!isChoosingCustomColor) {
        this.getTheme();
      } else {
        this.circleColorPickerThemeColorController = CircleColorPickerController(initialColor: appTheme.themeColor);
        this.circleColorPickerPartnerColorController = CircleColorPickerController(initialColor: appTheme.partnerColor);
      }
    });
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
    return showChoiceDialog(
        context: context,
        title: 'are you sure?',
        contentMessage: '',
        yesMessage: 'yep, I love the pain',
        noMessage: 'oops!',
        isDark: this.isDark,
        appTheme: appTheme,
        onYes: () {
          this.resetProgress();
        },
        onNo: () {
          Navigator.pop(context);
        });
  }

  void resetProgress() async {
    this.toggleLoader();
    await this.databaseProvider.resetGame(this.user);
    this.goToSplashScreen();
  }

  showDeleteAccountDialog(BuildContext context) {
    return showChoiceDialog(
        context: context,
        title: 'are you sure?',
        contentMessage: '',
        yesMessage: 'my mind is made up',
        noMessage: 'oops!',
        isDark: this.isDark,
        appTheme: appTheme,
        onYes: () {
          this.deleteAccount();
        },
        onNo: () {
          Navigator.pop(context);
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

  showAvatarchangedSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: appTheme.themeColor,
        content: Text(
          'your profile picture has been $text',
          style: GoogleFonts.lato(color: AppTheme.getLightOrDarkModeTheme(isDark)),
          textAlign: TextAlign.start,
        )));
  }

  showHelpSnackBar(int index) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 15),
        backgroundColor: appTheme.themeColor,
        action: SnackBarAction(
          label: 'ok',
          textColor: AppTheme.getLightOrDarkModeTheme(isDark),
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
        content: Text(
          helpDialogs[index],
          style: GoogleFonts.lato(color: AppTheme.getLightOrDarkModeTheme(isDark)),
          textAlign: TextAlign.start,
        )));
  }

  showRestartSnackBar(int index) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: appTheme.themeColor,
        content: Text(
          'success! you game is as fresh as a new born baby',
          style: GoogleFonts.lato(color: AppTheme.getLightOrDarkModeTheme(isDark)),
          textAlign: TextAlign.start,
        )));
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

  void handlePopupSelection(int value, BuildContext context) {
    switch (value) {
      case 1:
        this.getImageFromCamera();
        break;
      case 2:
        this.getImageFromGallery();
        break;
      case 3:
        this.openPhoto(
          context,
          this.user.profileUrl,
        );
        break;
      case 4:
        this.removeProfilePhoto();
        break;
    }
  }

  void openPhoto(BuildContext context, String profileUrl) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) {
        return ViewPhotoWidget(
          photoUrl: profileUrl,
          user: this.user,
          appTheme: this.appTheme,
          username: this.user.username,
        );
      },
    ));
  }

  Future getImageFromCamera() async {
    if (await this.connectivityProvider.isConnected()) {
      this.toggleLoader();
      final pickedFile = await picker.getImage(source: ImageSource.camera);

      if (pickedFile != null) {
        this.image = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ImageCropper(
                      image: File(pickedFile.path),
                      appTheme: this.appTheme,
                      user: this.user,
                    )));

        this.image = File(pickedFile.path);
        String newProfileUrl = (await this.databaseProvider.updateProfilePhoto(this.user, this.image)).profileUrl;

        setState(() {
          this.user.profileUrl = newProfileUrl;
        });
        this.toggleLoader();
        this.showAvatarchangedSnackBar('changed');
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
        this.image = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageCropper(
                image: File(image.path),
                appTheme: this.appTheme,
                user: this.user,
              ),
            ));

        this.image = File(pickedFile.path);
        String newProfileUrl = (await this.databaseProvider.updateProfilePhoto(this.user, this.image)).profileUrl;

        setState(() {
          this.user.profileUrl = newProfileUrl;
        });
        this.toggleLoader();
        this.showAvatarchangedSnackBar('changed');
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
      this.showAvatarchangedSnackBar('deleted');
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
