import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info/package_info.dart';
import 'package:sudoku/src/models/theme.dart';
import 'package:sudoku/src/models/user.dart';
import 'package:sudoku/src/providers/authentication_provider.dart';
import 'package:sudoku/src/providers/database_provider.dart';
import 'package:sudoku/src/providers/local_storage_provider.dart';
import 'package:sudoku/src/providers/theme_provider.dart';
import 'package:sudoku/src/screens/home_screen/home_screen.dart';
import 'auth_screen_ui.dart';

class AuthScreen extends StatefulWidget {
  final Users user;

  AuthScreen({@required this.user});

  @override
  AuthScreenView createState() => AuthScreenView();
}

abstract class AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  bool isLoading = false;
  bool isDark = false;
  bool isFormValid = false;

  Users user;

  double widgetOpacity = 0;

  AppTheme appTheme;
  PackageInfo packageInfo;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  LocalStorageProvider localStorageProvider = LocalStorageProvider();
  ThemeProvider themeProvider = ThemeProvider();
  DatabaseProvider databaseProvider = DatabaseProvider();
  AuthenticationProvider authenticationProvider = AuthenticationProvider();

  final formKey = GlobalKey<FormState>();

  void initVariables() async {
    this.getTheme();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await this.getDarkMode();
    });
  }

  @override
  void initState() {
    this.initVariables();
    this.getPackageInfo();
    super.initState();
  }

  void loadInWidgets() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        this.widgetOpacity = 1;
      });
    });
  }

  Future<void> getPackageInfo() async {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        this.packageInfo = packageInfo;
      });
    });
  }

  Future<void> getUser() async {
    Users user = await this.localStorageProvider.getUser();
    setState(() {
      this.user = user;
    });
  }

  void getTheme() {
    AppTheme appTheme = this.themeProvider.getCurrentAppTheme(widget.user);
    setState(() {
      this.appTheme = appTheme;
    });
  }

  Future<void> getDarkMode() async {
    var brightness = SchedulerBinding.instance.window.platformBrightness;
    setState(() {
      this.isDark = this.user == null ? brightness == Brightness.dark : this.user.isDark;
    });
  }

  void toggleLoader() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  void signIn() async {
    GoogleSignInAccount googleUser = await this.authenticationProvider.getGoogleUser();

    if (googleUser != null) {
      this.toggleLoader();
      var res = await this.authenticationProvider.signIn(googleUser);
      if (res['user'] != null) {
        this.user = res['user'];
        goToHomeScreen();
      } else {
        // show error snackbar
        this.toggleLoader();
        this.showErrorSnackBar();
      }
    } else {
      // show error snackbar
      this.showNoUserSnackBar();
    }
  }

  void goToHomeScreen() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) {
        return HomeScreen(user: this.user);
      },
    ));
  }

  showErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: appTheme.themeColor,
        content: Text(
          'oops!\n\nsomething has gone catastrophically wrong. it\'s likely your internet connection. if not it could be us but really, how likely is that? it\'s probably you. please retry',
          style: GoogleFonts.lato(color: AppTheme.getLightOrDarkModeTheme(isDark)),
          textAlign: TextAlign.start,
        )));
  }

  showNoUserSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: appTheme.themeColor,
        content: Text(
          'the way the is app is setup is that...\n\nwe know it\'s yet another thing to sign up for but you really do need an account to continue',
          style: GoogleFonts.lato(color: AppTheme.getLightOrDarkModeTheme(isDark)),
          textAlign: TextAlign.start,
        )));
  }
}
