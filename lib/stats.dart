import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'globalvariables.dart';

class Stats extends StatefulWidget {
  @override
  _StatsState createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themecolorbackground,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Stats for " + userScores[tempindex].data()["userName"].toString(),
          style: GoogleFonts.lato(color: Colors.black),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Text(userScores[tempindex].data()["score"].toString(),
                  style: GoogleFonts.lato(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [themecolor, themecolor, bordercolor, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            color: themecolorbackground,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "level",
                        style: GoogleFonts.lato(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      Column(
                        children: [
                          Text(
                            "Time",
                            style: GoogleFonts.lato(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text("HH:MM:SS.MS",
                              style: GoogleFonts.lato(
                                  color: Colors.black, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Divider(
                    color: Colors.black,
                    thickness: 2,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: userScores[tempindex].data()["stats"].length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          if (userScores[tempindex].data()["stats"] != []) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          userScores[tempindex]
                                              .data()["stats"][index]["level"]
                                              .toString(),
                                          style: GoogleFonts.lato(
                                              color: Colors.black,
                                              fontSize: 15),
                                        ),
                                        Text(
                                            userScores[tempindex]
                                                .data()["stats"][index]["time"]
                                                .toString(),
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 15)),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Divider(
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            );

                            // Card(
                            //     child: ListTile(
                            //   leading: Text(userScores[tempindex]
                            //       .data()["stats"][index]["level"]
                            //       .toString()),
                            //   title: Text(
                            //     userScores[tempindex]
                            //         .data()["stats"][index]["time"]
                            //         .toString(),
                            //   ),
                            // ));
                          } else {
                            return Container(
                              child: Center(
                                  child: Text("No stats available",
                                      style: GoogleFonts.lato())),
                            );
                          }
                        }),
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
