import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_sudoku/splashscreen.dart';
import 'globalvariables.dart';

Future<void> main() async {
  Random random = new Random();
  colorindex = random.nextInt(7);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/LICENSE.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(Phoenix(child: MyApp()));
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku with AISA',
      theme: ThemeData(
        primarySwatch: colors[colorindex],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Splashcreen(),
    );
  }
}
