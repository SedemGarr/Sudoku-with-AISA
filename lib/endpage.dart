import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_sudoku/aisa.dart';
import 'package:flutter_sudoku/globalvariables.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EndPage extends StatefulWidget {
  @override
  _EndPageState createState() => _EndPageState();
}

class _EndPageState extends State<EndPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
            padding: EdgeInsets.all(20),
            child: ListView(
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Hello player,',
                  style: GoogleFonts.lato(
                      fontSize: 30, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 30,
                ),
                Text('You’ve found me, the man behind the curtain.'),
                SizedBox(
                  height: 10,
                ),

                SizedBox(
                  height: 10,
                ),
                Text('WILL ADD MORE TEXT HERE'),
                Divider(),
                SizedBox(
                  height: 40,
                ),
                Image(image: AssetImage('images/cake.jpg')),
                SizedBox(
                  height: 10,
                ),
                Center(
                    child: Text(
                        'And oh, here’s your cake. AISA will email it you. Check your spam folder :)')),
                // SizedBox(
                //   height: 10,
                // ),
                // Divider(),
                SizedBox(
                  height: 30,
                ),
                Container(
                    child: Column(
                  children: <Widget>[
                    FlatButton(
                      onPressed: () async {
                        print(level);
                        isComplete = true;
                        difficulty = "Complete";
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setInt("level", level);
                        prefs.setInt("stringIndex", stringIndex);
                        prefs.setInt("totalScore", totalScore);
                        prefs.setBool("isComplete", isComplete);
                        prefs.setString("UserName", userName);
                        Phoenix.rebirth(context);
                      },
                      child: Text(
                        'Goodbye, player',
                        style: GoogleFonts.architectsDaughter(),
                      ),
                      color: colors[colorindex],
                    ),
                  ],
                )),
                SizedBox(height: 30),
                Divider(),
                Center(
                    child: FlatButton(
                  child: Text(
                    'Built with Flutter',
                    style: GoogleFonts.architectsDaughter(),
                  ),
                  onPressed: () {
                    showAboutDialog(context: context);
                  },
                ))
              ],
            )),
      ),
    );
  }
}
