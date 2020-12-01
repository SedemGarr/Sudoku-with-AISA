import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_sudoku/aisa.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sudoku_api/sudoku_api.dart';

var board1;
List board2 = List.generate(9, (i) => List(9), growable: false);
List board = List.generate(9, (i) => List(9), growable: false);
List solvedboard = List.generate(9, (i) => List(9), growable: false);
List usedNames = [];
int difficultyLevel = 20;
int level = 0;
int score = 0;
int totalScore = 0;
String times;
int saveTime;
int loadTime;
int loadTime1;
int useless = 0;
int tempindex;
String difficulty = "Easy";
Color themecolor = Colors.red;
Color textcolor;
Color selectedcolor;
Color themecolorbackground;
Color themecolorbackground1;
Color bordercolor;
Color highlightcolor;
Color wrongcolor;
bool selected = false;
// bool done = false;
bool isComplete = false;
bool introComplete = false;
bool hasAudio = true;
//bool saved = true;
bool cheat = false;
int worked;
int count = 0;
List loaded = [];
List loadedsolved = [];
int cheatCounter = 0;
String feedback = "";
String error = "";
String userName;
String completedText = "COMPLETE";
List userScores = [];
List colors = [
  Colors.red,
  Colors.blue,
  Colors.yellow,
  Colors.cyan,
  Colors.orange,
  Colors.purple,
  Colors.brown
];
int colorindex = 0;

final CollectionReference scoresCollection =
    FirebaseFirestore.instance.collection('Users');

class UserScore {
  String userUserName;
  int userScore;

  UserScore(int userscore, String userUserName);
}

levelSelector() {
  if (level == null) {
    level = 0;

    stringIndex = 0;
    isComplete = false;

    landingAudioIndex = 0;
  }
  if (level <= 8) {
    themecolor = Colors.blue;
    bordercolor = Colors.blue[100];
    textcolor = Colors.black;
    selectedcolor = Colors.green;
    themecolorbackground = Colors.blue[50];
    themecolorbackground1 = Colors.green[100];
    wrongcolor = Colors.green[900];
    difficulty = "Easy";
    difficultyLevel = 1;
    feedback = "Noob";
    score = 10;
    landingAudioIndex = 0;
    highlightcolor = Colors.green;
  }
  if (level >= 9 && level <= 17) {
    themecolor = Colors.orange;
    bordercolor = Colors.orange[100];
    textcolor = Colors.black;
    selectedcolor = Colors.green;
    themecolorbackground = Colors.orange[50];
    themecolorbackground1 = Colors.purple[100];
    wrongcolor = Colors.purple[900];
    difficulty = "Medium";
    difficultyLevel = 1;
    feedback = "Do you even Sudoku, bro?";
    score = 20;
    landingAudioIndex = 1;
    highlightcolor = Colors.purple;
  }
  if (level >= 18 && level <= 27) {
    themecolor = Colors.cyan;
    bordercolor = Colors.cyan[100];
    textcolor = Colors.black;
    selectedcolor = Colors.green;
    themecolorbackground = Colors.cyan[50];
    themecolorbackground1 = Colors.red[100];
    wrongcolor = Colors.red[900];
    difficulty = "Hard";
    difficultyLevel = 2;
    feedback = "It seems you\'re not that bad";
    score = 30;
    landingAudioIndex = 2;
    highlightcolor = Colors.red;
  }
  if (level >= 28 && level <= 36) {
    themecolor = Colors.red;
    bordercolor = Colors.red[100];
    textcolor = Colors.white;
    selectedcolor = Colors.green;
    themecolorbackground = Colors.red[50];
    themecolorbackground1 = Colors.yellow[100];
    wrongcolor = Colors.yellow[900];
    difficulty = "Very Hard";
    difficultyLevel = 2;
    feedback = "Do you need to do this?";
    score = 40;
    landingAudioIndex = 3;
    highlightcolor = Colors.yellow;
  }
  if (level >= 37 && level <= 44) {
    themecolor = Colors.purple;
    bordercolor = Colors.purple[100];
    textcolor = Colors.white;
    selectedcolor = Colors.green;
    themecolorbackground = Colors.purple[50];
    themecolorbackground1 = Colors.orange[100];
    wrongcolor = Colors.orange[900];
    difficulty = "Insane";
    difficultyLevel = 2;
    feedback = "It\'s not worth it. Really";
    score = 50;
    landingAudioIndex = 4;
    highlightcolor = Colors.orange;
  }
  if (level >= 45 && level <= 53) {
    themecolor = Colors.black;
    bordercolor = Colors.brown[100];
    textcolor = Colors.white;
    selectedcolor = Colors.green;
    themecolorbackground = Colors.brown[200];
    themecolorbackground1 = Colors.yellow[100];
    wrongcolor = Colors.yellow[900];
    difficulty = "Inhuman";
    difficultyLevel = 3;
    feedback =
        "Fun fact: Every human that has eaten cake has died or will die.";
    score = 60;
    landingAudioIndex = 5;
    highlightcolor = Colors.yellow;
  }
  if (level == 54) {
    themecolor = Colors.yellow;
    bordercolor = Colors.yellow[100];
    textcolor = Colors.black;
    selectedcolor = Colors.green;
    themecolorbackground = Colors.yellow[100];
    themecolorbackground1 = Colors.blue[100];
    wrongcolor = Colors.blue[900];
    difficulty = "Boss Level";
    difficultyLevel = 3;
    feedback = "Why do you have to be like this? :/";
    score = 70;
    landingAudioIndex = 6;
    highlightcolor = Colors.blue;
  }
  if (level == 55) {
    difficulty = "Complete";
    isComplete = true;
    feedback = "I hope you're happy, monster";
    landingAudioIndex = 7;
    themecolor = Colors.yellow;
    textcolor = Colors.black;
    selectedcolor = Colors.green;
    bordercolor = Colors.yellow[100];
    themecolorbackground = Colors.yellow[100];
  }
}

checkProgress() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getInt("level") != null) {
    level = prefs.getInt("level");
    stringIndex = prefs.getInt("stringIndex");
    introComplete = prefs.getBool("isIntroDone");
    totalScore = prefs.getInt("totalScore");
    isComplete = prefs.getBool("isComplete");
  }
  userName = prefs.getString("UserName");
}

saveProgress() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt("level", level);
  prefs.setInt("stringIndex", stringIndex);
  prefs.setInt("totalScore", totalScore);
  prefs.setBool("isComplete", isComplete);
  prefs.setString("UserName", userName);
  saveScore();
}

nextLevel() {
  level++;
  stringIndex++;
  totalScore = totalScore + score;
  saveProgress();
  levelSelector();
}

Future createScore() async {
  error = "";
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("UserName", userName);
  if (userName != null) {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(userName)
        .set({
      "userName": userName,
      "score": totalScore == null ? 0 : totalScore,
      "saveboard": [],
      "solvedsavedboard": [],
      "stats": [],
      "saveTime": 0
    });
  }
}

Future saveScore() async {
  loaded = [];
  loadedsolved = [];
  Map stats = {"level": level, "time": times};
  if (userName != null) {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(userName)
        .update(
      {
        "userName": userName,
        "score": totalScore,
        "saveboard": [],
        "solvedsavedboard": [],
        "stats": FieldValue.arrayUnion([stats]),
        "saveTime": 0
      },
    );
  }
}

reset() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  level = null;
  stringIndex = 0;
  difficulty = "Easy";
  isComplete = false;
  prefs.setInt("level", level);
  prefs.setInt("stringIndex", stringIndex);
  prefs.setBool("isComplete", isComplete);
}

// getSaved() async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   if (prefs.getBool("saved") == null) {
//     saved = true;
//   } else {
//     saved = prefs.getBool("saved");
//   }
// }

// saveSaved() async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   prefs.setBool("saved", saved);
// }

Future resetTimer() async {
  Map stats = {};
  return await FirebaseFirestore.instance
      .collection("Users")
      .doc(userName)
      .update(
    {
      "stats": stats,
    },
  );
}

saveSettings() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('hasAudio', hasAudio);
}

Future getSettings() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getBool("hasAudio") != null) {
    hasAudio = prefs.getBool("hasAudio");
  } else {
    hasAudio = true;
  }
}

Future getSave() async {
  if (userName != null) {
    try {
      return FirebaseFirestore.instance
          .collection("Users")
          .doc(userName)
          .get()
          .then((value) {
        loadTime = value.data()["saveTime"];
        loaded = value.data()["saveboard"];
        loadedsolved = value.data()["solvedsavedboard"];
        worked = 1;
      });
    } catch (e) {
      worked = 0;
    }
  }
}

Future wait() async {
// getSaved();
  //print(saved);

  checkProgress().then((value) {
    getSave();
  });
  levelSelector();

  getHighScores();

  getSettings();
}

Future getHighScores() async {
  List userScores1 = [];
  return FirebaseFirestore.instance
      .collection("Users")
      .orderBy("score")
      .snapshots()
      .listen((result) {
    result.docs.forEach((element) {
      userScores1.add(element);
      usedNames.add(element.data()["userName"].toString());
      print(usedNames[0]);
    });

    userScores = [];
    userScores = userScores1.reversed.toList();
    userScores1 = [];
    levelSelector();
  });
}

sudoku() async {
  // Random random = new Random();
  // String pattern;

  // int randomNumber = random.nextInt(5);

  // switch (randomNumber) {
  //   case 0:
  //     pattern = "spring";
  //     break;
  //   case 1:
  //     pattern = "summer";
  //     break;
  //   case 2:
  //     pattern = "fall";
  //     break;
  //   case 3:
  //     pattern = "winter";
  //     break;
  //   case 4:
  //     pattern = "Random";
  //     break;
  // }

  PuzzleOptions puzzleOptions =
      new PuzzleOptions(patternName: "Random", difficulty: difficultyLevel);
  Puzzle puzzle = new Puzzle(puzzleOptions);

  puzzle.generate().then((_) {
    if (loaded.isEmpty || loadedsolved.isEmpty) {
      // printGrid(puzzle.board());
      board1 = puzzle.board();
      for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
          board[i][j] =
              puzzle.board().cellAt(Position(row: i, column: j)).getValue();
          //print(board[i][j]);
        }
      }

      //printGrid(puzzle.solvedBoard());
      for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
          solvedboard[i][j] = puzzle
              .solvedBoard()
              .cellAt(Position(row: i, column: j))
              .getValue();
          //print(solvedboard[i][j]);
        }
      }

      printGrid(puzzle.solvedBoard());

      for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
          board2[i][j] =
              puzzle.board().cellAt(Position(row: i, column: j)).getValue();
          //print(board[i][j]);
        }
      }

      // setState(() {
      //   done = true;
      // });
    }

    if (loaded.length > 50 && loadedsolved.length > 50) {
      loadTime1 = loadTime;
      print(loaded);
      print(loadedsolved);

      for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
          board[i][j] = int.parse(loaded[count]);
          solvedboard[i][j] = int.parse(loadedsolved[count]);
          board2[i][j] = int.parse(loaded[count]);
          count++;
        }
      }
// show toast
      // Toast.show("loaded your previous saved game", context,
      //     duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
    // setState(() {
    //   // done = true;
    // });
  });
}
