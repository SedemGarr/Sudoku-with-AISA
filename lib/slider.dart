import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'globalvariables.dart';
import 'home.dart';
import 'intro.dart';

class SliderWidget extends StatefulWidget {
  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      scrollDirection: Axis.horizontal,
      enableInfiniteScroll: true,
      autoPlay: true,
      items: [
        Container(
          child: ListView(
            children: <Widget>[
              Center(
                  child: Column(
                children: <Widget>[
                  Text('Easy', style: GoogleFonts.lato()),
                  level > 8
                      ? Text(completedText)
                      : Text("", style: GoogleFonts.lato())
                ],
              )),
              IconButton(
                iconSize: MediaQuery.of(context).size.width * 0.30,
                icon: Icon(
                  FontAwesomeIcons.laughSquint,
                  color: level > 8 ? Colors.yellow : Colors.blue,
                ),
                onPressed:
                    level > 8 || difficulty == "Complete" || isComplete == true
                        ? () {}
                        : () {
                            if (introComplete == true) {
                              sudoku();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Home(),
                                  ));
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => IntroPage(),
                                  ));
                            }
                          },
              ),
            ],
          ),
        ),
        Container(
          child: level > 8 || difficulty == "Complete" || isComplete == true
              ? ListView(
                  children: <Widget>[
                    Center(
                        child: Column(
                      children: <Widget>[
                        Text('Medium', style: GoogleFonts.lato()),
                        level > 17
                            ? Text(completedText)
                            : Text("", style: GoogleFonts.lato())
                      ],
                    )),
                    IconButton(
                      iconSize: MediaQuery.of(context).size.width * 0.30,
                      icon: Icon(
                        FontAwesomeIcons.smile,
                        color: level > 17 ? Colors.yellow : Colors.orange,
                      ),
                      onPressed: level > 17 ||
                              difficulty == "Complete" ||
                              isComplete == true
                          ? () {}
                          : () {
                              sudoku();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Home(),
                                  ));
                            },
                    ),
                  ],
                )
              : ListView(
                  children: <Widget>[
                    Center(
                        child: Column(
                      children: <Widget>[
                        Text('Medium', style: GoogleFonts.lato()),
                        Text(
                          'LOCKED',
                          style: GoogleFonts.lato(color: Colors.red),
                        ),
                      ],
                    )),
                    IconButton(
                      iconSize: MediaQuery.of(context).size.width * 0.30,
                      icon: Icon(
                        FontAwesomeIcons.smile,
                        color: Colors.grey,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
        ),
        Container(
          child: level > 17 || difficulty == "Complete" || isComplete == true
              ? ListView(
                  children: <Widget>[
                    Center(
                        child: Column(
                      children: <Widget>[
                        Text('Hard', style: GoogleFonts.lato()),
                        level > 27
                            ? Text(completedText)
                            : Text("", style: GoogleFonts.lato())
                      ],
                    )),
                    IconButton(
                      iconSize: MediaQuery.of(context).size.width * 0.30,
                      icon: Icon(
                        FontAwesomeIcons.meh,
                        color: level > 27 ? Colors.yellow : Colors.cyan,
                      ),
                      onPressed: level > 27 ||
                              difficulty == "Complete" ||
                              isComplete == true
                          ? () {}
                          : () {
                              sudoku();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Home(),
                                  ));
                            },
                    ),
                  ],
                )
              : ListView(
                  children: <Widget>[
                    Center(
                        child: Column(
                      children: <Widget>[
                        Text('Hard', style: GoogleFonts.lato()),
                        Text(
                          'LOCKED',
                          style: GoogleFonts.lato(color: Colors.red),
                        ),
                      ],
                    )),
                    IconButton(
                      iconSize: MediaQuery.of(context).size.width * 0.30,
                      icon: Icon(
                        FontAwesomeIcons.meh,
                        color: Colors.grey,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
        ),
        Container(
          child: level > 27 || difficulty == "Complete" || isComplete == true
              ? ListView(
                  children: <Widget>[
                    Center(
                        child: Column(
                      children: <Widget>[
                        Text('Very Hard', style: GoogleFonts.lato()),
                        level > 36
                            ? Text(completedText)
                            : Text("", style: GoogleFonts.lato())
                      ],
                    )),
                    IconButton(
                      iconSize: MediaQuery.of(context).size.width * 0.30,
                      icon: Icon(
                        FontAwesomeIcons.frownOpen,
                        color: level > 36 ? Colors.yellow : Colors.red,
                      ),
                      onPressed: level > 36 ||
                              difficulty == "Complete" ||
                              isComplete == true
                          ? () {}
                          : () {
                              sudoku();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Home(),
                                  ));
                            },
                    ),
                  ],
                )
              : ListView(
                  children: <Widget>[
                    Center(
                        child: Column(
                      children: <Widget>[
                        Text('Very Hard', style: GoogleFonts.lato()),
                        Text(
                          'LOCKED',
                          style: GoogleFonts.lato(color: Colors.red),
                        ),
                      ],
                    )),
                    IconButton(
                      iconSize: MediaQuery.of(context).size.width * 0.30,
                      icon: Icon(
                        FontAwesomeIcons.frownOpen,
                        color: Colors.grey,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
        ),
        Container(
          child: level > 36 || difficulty == "Complete" || isComplete == true
              ? ListView(
                  children: <Widget>[
                    Center(
                        child: Column(
                      children: <Widget>[
                        Text('Insane', style: GoogleFonts.lato()),
                        level > 44
                            ? Text(completedText)
                            : Text("", style: GoogleFonts.lato())
                      ],
                    )),
                    IconButton(
                      iconSize: MediaQuery.of(context).size.width * 0.30,
                      icon: Icon(
                        FontAwesomeIcons.grimace,
                        color: level > 44 ? Colors.yellow : Colors.purple,
                      ),
                      onPressed: level > 44 ||
                              difficulty == "Complete" ||
                              isComplete == true
                          ? () {}
                          : () {
                              sudoku();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Home(),
                                  ));
                            },
                    ),
                  ],
                )
              : ListView(
                  children: <Widget>[
                    Center(
                        child: Column(
                      children: <Widget>[
                        Text('Insane', style: GoogleFonts.lato()),
                        Text(
                          'LOCKED',
                          style: GoogleFonts.lato(color: Colors.red),
                        ),
                      ],
                    )),
                    IconButton(
                      iconSize: MediaQuery.of(context).size.width * 0.30,
                      icon: Icon(
                        FontAwesomeIcons.grimace,
                        color: Colors.grey,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
        ),
        Container(
          child: level > 44 || difficulty == "Complete" || isComplete == true
              ? ListView(
                  children: <Widget>[
                    Center(
                        child: Column(
                      children: <Widget>[
                        Text('Inhuman', style: GoogleFonts.lato()),
                        level > 54
                            ? Text(completedText)
                            : Text("", style: GoogleFonts.lato())
                      ],
                    )),
                    IconButton(
                      iconSize: MediaQuery.of(context).size.width * 0.30,
                      icon: Icon(
                        FontAwesomeIcons.flushed,
                        color: level > 54 ? Colors.yellow : Colors.black,
                      ),
                      onPressed: level > 54 ||
                              difficulty == "Complete" ||
                              isComplete == true
                          ? () {}
                          : () {
                              sudoku();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Home(),
                                  ));
                            },
                    ),
                  ],
                )
              : ListView(
                  children: <Widget>[
                    Center(
                        child: Column(
                      children: <Widget>[
                        Text('Inhuman', style: GoogleFonts.lato()),
                        Text(
                          'LOCKED',
                          style: GoogleFonts.lato(color: Colors.red),
                        ),
                      ],
                    )),
                    IconButton(
                      iconSize: MediaQuery.of(context).size.width * 0.30,
                      icon: Icon(
                        FontAwesomeIcons.flushed,
                        color: Colors.grey,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
        ),
      ].map((i) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(color: Colors.transparent),
              child: Container(
                child: i,
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
