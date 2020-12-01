import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sudoku/endpage.dart';
import 'package:flutter_sudoku/globalvariables.dart';
import 'package:flutter_sudoku/landingpage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'aisa.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:collection/collection.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:toast/toast.dart';
import 'package:wakelock/wakelock.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedindex;
  int x1;
  int y1;

  List highListR = [];
  List highListC = [];

  checkHighlight() {
    print(row);
    print(column);

    List highListR1 = [];
    List highListC1 = [];
    //
    highListR1.add(row);
    highListC1.add(column);
    //
    highListR = highListR1;
    highListC = highListC1;
  }

  final StopWatchTimer _stopWatchTimer = StopWatchTimer();

  playAudio() {
    final player = AudioCache();
    if (hasAudio) {
      player.play(aisaAudioList[stringIndex]);
    }
  }

  playNoAudio() {
    final player = AudioCache();
    Random random = new Random();
    if (hasAudio) {
      player.play(aisaNo[random.nextInt(7)]);
    }
  }

  save() async {
    List<String> saveboard = [];
    List<String> savesolvedboard = [];

    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        saveboard.add(board[i][j].toString());
        savesolvedboard.add(solvedboard[i][j].toString());
      }
    }
    if (userName != null) {
      return await FirebaseFirestore.instance
              .collection("Users")
              .doc(userName)
              .update(
        {
          "saveboard": saveboard,
          "solvedsavedboard": savesolvedboard,
          "saveTime": saveTime
        },
      )
          // .then((value) => Toast.show("saved your game", context,
          //         duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM))
          ;
    }
  }

  int row, column;

  void _showAISADialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: themecolorbackground,
            title: Center(child: Image(image: AssetImage('images/aisa.png'))),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Center(
                            child: Text('Message from AISA 291:',
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: Text(aisa[stringIndex]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              FlatButton(
                  color: Colors.green,
                  onPressed: () async {
                    setState(() {
                      if (stringIndex == (aisa.length - 1)) {
                        Wakelock.disable();
                        print(stringIndex);
                        print(aisa.length);
                        print(level);
                        level++;
                        isComplete = true;
                        difficulty = "Complete";
                        _stopWatchTimer.setPresetSecondTime(0);
                        saveProgress();
                        _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EndPage(),
                            ));
                      } else {
                        Wakelock.enable();
                        error = "";
                        nextLevel();
                        _stopWatchTimer.setPresetSecondTime(0);
                        sudoku();
                        _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
                        _stopWatchTimer.onExecute.add(StopWatchExecute.start);
                        Navigator.pop(context);
                      }
                    });
                  },
                  child: Text("Next", style: GoogleFonts.architectsDaughter()))
            ],
          );
        });
  }

  void _showSettingsDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: themecolorbackground,
              title: Center(
                  child: Text("Settings",
                      style: GoogleFonts.lato(fontWeight: FontWeight.bold))),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Play Sounds?",
                                    style: GoogleFonts.lato(
                                        fontWeight: FontWeight.bold)),
                                Switch(
                                  value: hasAudio,
                                  onChanged: (value) {
                                    setState(() {
                                      hasAudio = value;
                                      print(hasAudio);
                                    });
                                  },
                                  activeTrackColor: bordercolor,
                                  activeColor: themecolor,
                                  inactiveThumbColor: themecolorbackground,
                                  inactiveTrackColor: themecolorbackground,
                                ),
                              ],
                            ),
                            hasAudio
                                ? Text("Sounds are currently ON",
                                    style: GoogleFonts.lato())
                                : Text("Sounds are currently OFF",
                                    style: GoogleFonts.lato())
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                FlatButton(
                    color: highlightcolor,
                    onPressed: () {
                      saveSettings();
                      if (hasAudio) {
                      } else {}
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Save",
                      style: GoogleFonts.architectsDaughter(),
                    ))
              ],
            );
          });
        });
  }

  isCorrect() {
    Function deepEq = const DeepCollectionEquality().equals;
    if (deepEq(board, solvedboard) || cheat == true) {
      _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
      selectedindex = null;
      highListR = [];
      highListC = [];
      print("true");
      _showAISADialog();
      playAudio();
      Wakelock.disable();
    } else {
      setState(() {
        error = "Nope. Try again. Reset the puzzle if you are stuck";
        playNoAudio();
      });
    }
  }

  @override
  void initState() {
    setState(() {
      Wakelock.enable();
      checkProgress();
      levelSelector();
      if (loaded.length > 50 && loadedsolved.length > 50) {
        _stopWatchTimer.setPresetSecondTime(loadTime1);
      } else {
        _stopWatchTimer.setPresetSecondTime(0);
      }
      _stopWatchTimer.onExecute.add(StopWatchExecute.start);
    });
    if (loaded.length > 50 && loadedsolved.length > 50) {
      Toast.show("loaded your previously saved game", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: themecolor,
          centerTitle: true,
          leading: IconButton(
            onPressed: () async {
              _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
              _stopWatchTimer.setPresetSecondTime(0);
              loadTime1 = 0;
              worked = 0;
              setState(() {
                setState(() {
                  selectedindex = null;
                  highListR = [];
                  highListC = [];
                  print(level);
                  error = "";
                  loaded = [];
                  loadedsolved = [];
                });
                sudoku();
                _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
              });

              return await FirebaseFirestore.instance
                  .collection("Users")
                  .doc(userName)
                  .update(
                {"saveboard": [], "solvedsavedboard": [], "saveTime": 0},
              ).then((value) => initState());
            },
            icon: Icon(
              Icons.refresh,
              color: textcolor,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  icon: Icon(
                    FontAwesomeIcons.laughSquint,
                    color: textcolor,
                  ),
                  onPressed: () {
                    Wakelock.disable();
                    loadTime1 = 0;
                    _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
                    _stopWatchTimer.setPresetSecondTime(0);
                    _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
                    selectedindex = null;
                    highListR = [];
                    highListC = [];
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LandingPage(),
                        ));
                  }),
              StreamBuilder<int>(
                stream: _stopWatchTimer.rawTime,
                initialData: 0,
                builder: (context, snap) {
                  final value = snap.data;
                  //  final displayTime = StopWatchTimer.getDisplayTime(value);
                  times = StopWatchTimer.getDisplayTime(value);
                  saveTime = StopWatchTimer.getRawSecond(value);
                  return
                      // Container();

                      Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              StopWatchTimer.getDisplayTimeHours(value),
                              style: GoogleFonts.lato(
                                  color: textcolor,
                                  fontSize: 20,
                                  //  fontFamily: 'Helvetica',
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              ":",
                              style: GoogleFonts.lato(
                                  color: textcolor,
                                  fontSize: 20,
                                  //   fontFamily: 'Helvetica',
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              StopWatchTimer.getDisplayTimeMinute(value),
                              style: GoogleFonts.lato(
                                  color: textcolor,
                                  fontSize: 20,
                                  //       fontFamily: 'Helvetica',
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              ":",
                              style: GoogleFonts.lato(
                                  color: textcolor,
                                  fontSize: 20,
                                  //  fontFamily: 'Helvetica',
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              StopWatchTimer.getDisplayTimeSecond(value),
                              style: GoogleFonts.lato(
                                  color: textcolor,
                                  fontSize: 20,
                                  //      fontFamily: 'Helvetica',
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  isCorrect();
                });
              },
              icon: Icon(
                Icons.check_circle_outline,
                color: cheat ? highlightcolor : textcolor,
              ),
            )
          ],
        ),
        body: Container(
          // height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [themecolor, themecolor, bordercolor, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(error, style: GoogleFonts.lato(color: textcolor)),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          GridView.builder(
                              shrinkWrap: true,
                              itemCount: 81,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 9,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: bordercolor)),
                                );
                              }),
                          GridView.builder(
                              shrinkWrap: true,
                              itemCount: 9,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: themecolor)),
                                );
                              }),
                          GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 9,
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              gridSelector(int x, int y) {
                                int chooser;
                                if (board[x][y] == 0) {
                                  chooser = 0;
                                }
                                if (board[x][y] > 0 && board[x][y] < 10) {
                                  chooser = 1;
                                }
                                // highlight rows and cols
                                switch (chooser) {
                                  case 0:
                                    return GestureDetector(
                                      onTap: () {
                                        print(index);
                                        setState(() {
                                          error = "";
                                          selectedindex = index;
                                          row = x;
                                          column = y;
                                          //  print(x1);
                                          //  print(y1);
                                          checkHighlight();
                                        });
                                      },
                                      child: Card(
                                          elevation: 0,
                                          color: selectedindex == index
                                              ? highlightcolor
                                              : highListR.contains(x) ||
                                                      highListC.contains(y)
                                                  ? board[x][y] ==
                                                              board[row]
                                                                  [column] &&
                                                          board[row][column] !=
                                                              0
                                                      ? wrongcolor
                                                      : themecolorbackground1
                                                  : themecolor,
                                          child: Center(
                                            child: Text("",
                                                style: GoogleFonts.lato()),
                                          )),
                                    );
                                  case 1:
                                    return GestureDetector(
                                      onTap: () {
                                        error = "";
                                        print(index);
                                        setState(() {
                                          selectedindex = index;
                                          row = x;
                                          column = y;
                                          checkHighlight();
                                        });
                                      },
                                      child: Card(
                                        shadowColor: Colors.white,
                                        elevation: 1,
                                        color: selectedindex == index
                                            ? highlightcolor
                                            : highListR.contains(x) ||
                                                    highListC.contains(y)
                                                ? board[x][y] ==
                                                        board[row][column]
                                                    ? wrongcolor
                                                    : themecolorbackground1
                                                : Colors.white,
                                        child: Center(
                                          child: Text(
                                            board[x][y].toString(),
                                            style: GoogleFonts.lato(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    );
                                }
                              }

                              int gridStateLength = 9;
                              int x, y = 0;
                              x = (index / gridStateLength).floor();
                              y = (index % gridStateLength);
                              return gridSelector(x, y);
                            },
                            itemCount: 81,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            error = "";
                            selectedindex = null;
                            highListR = [];
                            highListC = [];
                          });
                        },
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: IconButton(
                          splashColor: highlightcolor,
                          splashRadius: 300,
                          icon: Icon(
                            Icons.undo,
                            color: Colors.black,
                          ),
                          onPressed: () async {
                            setState(() {
                              error = "";
                              _stopWatchTimer.onExecute
                                  .add(StopWatchExecute.stop);
                              _stopWatchTimer.setPresetSecondTime(0);
                              _stopWatchTimer.onExecute
                                  .add(StopWatchExecute.reset);
                              for (int i = 0; i < 9; i++) {
                                for (int j = 0; j < 9; j++) {
                                  board[i][j] = board2[i][j];
                                }
                              }
                              print(board2[0][0]);
                              _stopWatchTimer.onExecute
                                  .add(StopWatchExecute.start);
                              selectedindex = null;
                              highListR = [];
                              highListC = [];
                            });
                          },
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: IconButton(
                          splashColor: highlightcolor,
                          splashRadius: 300,
                          icon: Icon(Icons.delete, color: Colors.black),
                          onPressed: () {
                            setState(() {
                              error = "";
                              board[row][column] = 0;
                            });
                          },
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: IconButton(
                            icon: Icon(Icons.settings),
                            onPressed: () async {
                              error = "";
                              getSettings();
                              _showSettingsDialog();
                            }),
                      )
                    ],
                  ),
                  Divider(
                    thickness: 2,
                    color: themecolor,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      children: [
                        Expanded(
                          child: Card(
                            color: themecolor,
                            child: IconButton(
                              splashColor: Colors.white,
                              splashRadius: 300,
                              icon: Text('1',
                                  style: GoogleFonts.lato(
                                      color: textcolor,
                                      fontWeight: FontWeight.bold)),
                              onPressed: () {
                                if (board[row][column] == 1) {
                                  setState(() {
                                    board[row][column] = 0;
                                    save();
                                    error = "";
                                  });
                                } else {
                                  setState(() {
                                    board[row][column] = 1;
                                    save();
                                    error = "";
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Card(
                            color: themecolor,
                            child: IconButton(
                              splashColor: Colors.white,
                              splashRadius: 300,
                              icon: Text('2',
                                  style: GoogleFonts.lato(
                                      color: textcolor,
                                      fontWeight: FontWeight.bold)),
                              onPressed: () {
                                if (board[row][column] == 2) {
                                  setState(() {
                                    board[row][column] = 0;
                                    save();
                                    error = "";
                                  });
                                } else {
                                  setState(() {
                                    board[row][column] = 2;
                                    save();
                                    error = "";
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Card(
                            color: themecolor,
                            child: IconButton(
                              splashColor: Colors.white,
                              splashRadius: 300,
                              icon: Text('3',
                                  style: GoogleFonts.lato(
                                      color: textcolor,
                                      fontWeight: FontWeight.bold)),
                              onPressed: () {
                                if (board[row][column] == 3) {
                                  setState(() {
                                    board[row][column] = 0;
                                    save();
                                    error = "";
                                  });
                                } else {
                                  setState(() {
                                    board[row][column] = 3;
                                    save();
                                    error = "";
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Card(
                            color: themecolor,
                            child: IconButton(
                              splashColor: Colors.white,
                              splashRadius: 300,
                              icon: Text('4',
                                  style: GoogleFonts.lato(
                                      color: textcolor,
                                      fontWeight: FontWeight.bold)),
                              onPressed: () {
                                if (board[row][column] == 4) {
                                  setState(() {
                                    board[row][column] = 0;
                                    save();
                                    error = "";
                                  });
                                } else {
                                  setState(() {
                                    board[row][column] = 4;
                                    save();
                                    error = "";
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Card(
                            color: themecolor,
                            child: IconButton(
                              splashColor: Colors.white,
                              splashRadius: 300,
                              icon: Text('5',
                                  style: GoogleFonts.lato(
                                      color: textcolor,
                                      fontWeight: FontWeight.bold)),
                              onPressed: () {
                                if (board[row][column] == 5) {
                                  setState(() {
                                    board[row][column] = 0;
                                    save();
                                    error = "";
                                  });
                                } else {
                                  setState(() {
                                    board[row][column] = 5;
                                    save();
                                    error = "";
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Card(
                            color: themecolor,
                            child: IconButton(
                              splashColor: Colors.white,
                              splashRadius: 300,
                              icon: Text('6',
                                  style: GoogleFonts.lato(
                                      color: textcolor,
                                      fontWeight: FontWeight.bold)),
                              onPressed: () {
                                if (board[row][column] == 6) {
                                  setState(() {
                                    board[row][column] = 0;
                                    save();
                                    error = "";
                                  });
                                } else {
                                  setState(() {
                                    board[row][column] = 6;
                                    save();
                                    error = "";
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Card(
                            color: themecolor,
                            child: IconButton(
                              splashColor: Colors.white,
                              splashRadius: 300,
                              icon: Text('7',
                                  style: GoogleFonts.lato(
                                      color: textcolor,
                                      fontWeight: FontWeight.bold)),
                              onPressed: () {
                                if (board[row][column] == 7) {
                                  setState(() {
                                    board[row][column] = 0;
                                    save();
                                    error = "";
                                  });
                                } else {
                                  setState(() {
                                    board[row][column] = 7;
                                    save();
                                    error = "";
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Card(
                            color: themecolor,
                            child: IconButton(
                              splashColor: Colors.white,
                              splashRadius: 300,
                              icon: Text('8',
                                  style: GoogleFonts.lato(
                                      color: textcolor,
                                      fontWeight: FontWeight.bold)),
                              onPressed: () {
                                if (board[row][column] == 8) {
                                  setState(() {
                                    board[row][column] = 0;
                                    save();
                                    error = "";
                                  });
                                } else {
                                  setState(() {
                                    board[row][column] = 8;
                                    save();
                                    error = "";
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Card(
                            color: themecolor,
                            child: IconButton(
                              splashColor: Colors.white,
                              splashRadius: 300,
                              icon: Text(
                                '9',
                                style: GoogleFonts.lato(
                                    color: textcolor,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                if (board[row][column] == 9) {
                                  setState(() {
                                    board[row][column] = 0;
                                    save();
                                    error = "";
                                  });
                                } else {
                                  setState(() {
                                    board[row][column] = 9;
                                    save();
                                    error = "";
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
