import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_sudoku/aisa.dart';
import 'package:flutter_sudoku/stats.dart';
import 'package:flutter_sudoku/title.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toast/toast.dart';
import 'globalvariables.dart';
import 'slider.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  ItemScrollController _scrollController = ItemScrollController();
  int tempindextemp;
  final player = AudioCache();
  final _formKey = GlobalKey<FormState>();

  void _showResetDialog() {
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
                            child: Text(
                                "Want to reset and torture me some more? I expected nothing less from you. Monster.",
                                style: GoogleFonts.lato()),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                              "Your level times will be reset as well. You will keep your score and ranking though.",
                              style: GoogleFonts.lato())
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FlatButton(
                      color: Colors.red,
                      onPressed: () async {
                        reset();

                        Phoenix.rebirth(context);
                      },
                      child: Text("Nope",
                          style: GoogleFonts.architectsDaughter())),
                  SizedBox(
                    width: 20,
                  ),
                  FlatButton(
                      color: Colors.green,
                      onPressed: () async {
                        introComplete = false;
                        reset();
                        resetTimer();
                        Phoenix.rebirth(context);
                      },
                      child: Text("Reset",
                          style: GoogleFonts.architectsDaughter()))
                ],
              ),
            ],
          );
        });
  }

  @override
  initState() {
    getSave();
    Future.delayed(const Duration(milliseconds: 4000), () {
      _scrollController.scrollTo(
          index: tempindextemp, duration: Duration(seconds: 2));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return userName == null
        ? WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
              body: Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors[colorindex], Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                    child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Container(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TitleWidgets(),
                          SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  height: 30,
                                ),
                                Center(
                                    child: Text("Welcome",
                                        style: GoogleFonts.lato())),
                                SizedBox(
                                  height: 60,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.15),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          keyboardType: TextInputType.name,
                                          decoration: InputDecoration(
                                              hintText:
                                                  'Please enter your username'),
                                          validator: (val) => val.isEmpty ||
                                                  usedNames.contains(userName)
                                              ? error =
                                                  'That name is taken. Please choose another'
                                              : null,
                                          onChanged: (val) {
                                            userName = val.trim();
                                          },
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Center(
                                          child: Text(
                                              "The username you choose is what will be displayed on the leaderboard.",
                                              style: GoogleFonts.lato()),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            FlatButton(
                                                color: Colors.green,
                                                onPressed: () async {
                                                  if (_formKey.currentState
                                                      .validate()) {
                                                    setState(() {
                                                      error = "";
                                                      createScore();
                                                    });
                                                    // setState(() {
                                                    // //  saved = false;
                                                    //   // saveSaved();
                                                    // });
                                                  }
                                                  Phoenix.rebirth(context);
                                                },
                                                child: Text("Save",
                                                    style: GoogleFonts
                                                        .architectsDaughter())),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )),
              ),
            ),
          )
        : WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [themecolor, themecolor, bordercolor, Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Card(
                            elevation: 1,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: TitleWidgets(),
                                  ),
                                ),
                                SizedBox(height: 30),
                                FutureBuilder(
                                    future: wait(),
                                    builder: (context, snapshot) {
                                      return SliderWidget();
                                    }),
                                SizedBox(height: 10),
                                isComplete
                                    ? FlatButton(
                                        onPressed: () {
                                          _showResetDialog();
                                          player.play('reset.wav');
                                        },
                                        child: Text("Reset?",
                                            style: GoogleFonts
                                                .architectsDaughter()))
                                    : Container(),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          // Divider(),

                          Text(
                            "Leaderboard",
                            style: GoogleFonts.lato(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          //SizedBox(height: 15),
                          SizedBox(height: 5),
                          Expanded(
                            child: ScrollablePositionedList.builder(
                                itemScrollController: _scrollController,
                                itemCount: userScores.length,
                                itemBuilder: (BuildContext ctxt, int index) {
                                  for (int i = 0; i < userScores.length; i++) {
                                    if (userName ==
                                        userScores[i]
                                            .data()["userName"]
                                            .toString()) {
                                      tempindextemp = i;
                                    }
                                  }

                                  try {
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.12),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)),
                                        ),
                                        child: Card(
                                          elevation: 0,
                                          color: userName ==
                                                  userScores[index]
                                                      .data()["userName"]
                                                      .toString()
                                              ? themecolor
                                              : Colors.white,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20))),
                                          child: ListTile(
                                            onTap: () {
                                              tempindex = index;
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        Stats(),
                                                  ));
                                            },
                                            leading: index == 0
                                                ? Icon(
                                                    FontAwesomeIcons.crown,
                                                    color: highlightcolor,
                                                  )
                                                : Icon(Icons.person,
                                                    color: userName ==
                                                            userScores[index]
                                                                .data()[
                                                                    "userName"]
                                                                .toString()
                                                        ? textcolor
                                                        : Colors.black),
                                            title: Row(
                                              children: [
                                                Text(
                                                  (index + 1).toString(),
                                                  style: GoogleFonts.lato(
                                                      color: userName ==
                                                              userScores[index]
                                                                  .data()[
                                                                      "userName"]
                                                                  .toString()
                                                          ? textcolor
                                                          : Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  userScores[index]
                                                      .data()["userName"]
                                                      .toString(),
                                                  style: GoogleFonts.lato(
                                                    color: userName ==
                                                            userScores[index]
                                                                .data()[
                                                                    "userName"]
                                                                .toString()
                                                        ? textcolor
                                                        : Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            trailing: Text(
                                              userScores[index]
                                                  .data()["score"]
                                                  .toString(),
                                              style: GoogleFonts.lato(
                                                color: userName ==
                                                        userScores[index]
                                                            .data()["userName"]
                                                            .toString()
                                                    ? textcolor
                                                    : Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    return Container(
                                      child: Text("Oops",
                                          style: GoogleFonts.lato()),
                                    );
                                  }
                                }),
                          ),
                          SizedBox(height: 15),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: GestureDetector(
                              child: Text(
                                feedback,
                                style: GoogleFonts.lato(
                                    fontStyle: FontStyle.italic),
                              ),
                              onTap: () {
                                cheatCounter++;
                                if (cheatCounter >= 5) {
                                  setState(() {
                                    cheat = true;
                                  });
                                  Toast.show("cheat mode enabled", context,
                                      duration: Toast.LENGTH_LONG,
                                      gravity: Toast.BOTTOM);
                                }
                                print(level);
                                if (hasAudio) {
                                  player.play(
                                      landingPageAudioList[landingAudioIndex]);
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
