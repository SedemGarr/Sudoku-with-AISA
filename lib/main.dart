import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sudoku/src/models/theme.dart';
import 'package:sudoku/src/models/user.dart';
import 'package:sudoku/src/providers/local_storage_provider.dart';
import 'src/screens/splash_screen/splash_screen.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Users user;
  bool hasLoaded = false;

  LocalStorageProvider localStorageProvider = LocalStorageProvider();

  Future<void> getUser() async {
    Users user = await this.localStorageProvider.getUser();
    setState(() {
      this.user = user;
    });
  }

  void delayLoading() {
    Future.delayed(Duration(milliseconds: 500), () {
      this.setState(() {
        this.hasLoaded = true;
      });
    });
  }

  @override
  void initState() {
    delayLoading();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku with AISA',
      theme: ThemeData(
        primarySwatch: this.user == null
            ? AppTheme.themes[0].themeColor
            : AppTheme.themes[this.user.difficultyLevel].themeColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: hasLoaded ? SplashScreen() : Container(),
    );
  }
}
