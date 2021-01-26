import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sudoku/globalvariables.dart';
import 'package:flutter_sudoku/home.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audio_cache.dart';

import 'sudoku.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final audioCache = AudioCache();
  AudioPlayer player;

  playAudio() async {
    // final player = AudioCache();
    // player.play('intro.wav', style: GoogleFonts.lato() );
    if (hasAudio) {
      player = await audioCache.play(
        'intro.wav',
      );
    }
  }

  stop() {
    if (hasAudio) {
      player?.stop();
    }
  }

  saveProgessData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool('isIntroDone', introComplete);
    });
  }

  @override
  void initState() {
    playAudio();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            //color: textcolor,
          ),
          onPressed: () {
            stop();
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        title: Text('Before you start...', style: GoogleFonts.lato()),
        centerTitle: true,
        backgroundColor: themecolor,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView(children: [
          SizedBox(
            height: 10,
          ),
          Lottie.network(
              'https://assets5.lottiefiles.com/temp/lf20_VUFNS8.json'),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Hi',
                style:
                    GoogleFonts.lato(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Text(
              'I’m Artificially Intelligent Sudoku Agent version 291.7. You can call me AISA.',
              style: GoogleFonts.lato()),
          SizedBox(
            height: 10,
          ),
          Text(
              'I was designed to provide encouragement and helpful advice to users partaking in this programme. I am here to guide you through the experience, which involves solving Sudoku puzzles. Your solutions will help us fine tune our puzzle generation algorithms.',
              style: GoogleFonts.lato()),
          SizedBox(
            height: 10,
          ),
          Text(
              'Sudoku is a simple game where you fill a nine by nine grid with digits so that each column, row, and three by three subgrid contains each number from 1 to 9.',
              style: GoogleFonts.lato()),
          SizedBox(
            height: 10,
          ),
          Text('Here is an example.', style: GoogleFonts.lato()),
          SizedBox(
            height: 10,
          ),
          Image(
            image: AssetImage(
              'images/puzzle.png',
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
              'Hit the “check” button when you are done with a puzzle. If you’d like to take a break, tap the emoji icon in the centre of the app bar.',
              style: GoogleFonts.lato()),
          SizedBox(
            height: 10,
          ),
          Text(
              'Solve all fifty-four puzzles and you’ll have cake at the end. We promise :)',
              style: GoogleFonts.lato()),
          SizedBox(
            height: 40,
          ),
          Divider(),
          SizedBox(
            height: 5,
          ),
          Text(
            'By continuing you agree to our terms and policies. All your personal data will most definitely be tracked and logged, including but not limited to: the number of times you pick your nose daily, your MoMo pin, and the diameter of your right, small toe. We reserve the right to exchange your data for Sister Mansa’s kelewele. If this disturbs you, try to imagine your life without any Google services. Yep, it’s way too late to start caring about your privacy. If you still feel disturbed, please speak to someone who cares about you. If no one loves you, pay a therapist to care. For more information on our terms and conditions, fly over to our headquarters and ask to speak to a customer care agent, who will certainly not hide behind a tall, potted plant and pretend not to notice you. Should you complete all puzzles, your cake will be sent to the email address you specify. Should you not receive it, please refresh your spam folder an infinite number of times.',
            style: GoogleFonts.lato(color: Colors.grey[500]),
          ),
          SizedBox(
            height: 10,
          ),
          Divider(),
          SizedBox(
            height: 10,
          ),
          Container(
            child: Column(
              children: <Widget>[
                RaisedButton(
                  elevation: 0,
                  onPressed: () async {
                    generateSudoku();
                    introComplete = true;
                    saveProgessData();
                    stop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Home(),
                        ));
                  },
                  child: Text('Begin',
                      style:
                          GoogleFonts.architectsDaughter(color: Colors.white)),
                  color: themecolor,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
          ),
        ]),
      ),
    );
  }
}
