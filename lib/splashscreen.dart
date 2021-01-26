import 'package:flutter/material.dart';
import 'package:flutter_sudoku/landingpage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'globalvariables.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class Splashcreen extends StatefulWidget {
  @override
  _SplashcreenState createState() => _SplashcreenState();
}

class _SplashcreenState extends State<Splashcreen> {
//  bool _visible = false;

  Color _colour = Colors.white;

  updateColour() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _colour = themecolor;
      });
    });
  }

  @override
  void initState() {
    updateColour();
    checkProgress();
    setState(() {
      wait();
    });
    Future.delayed(const Duration(milliseconds: 7000), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LandingPage(),
          ));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        color: themecolor,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: AnimatedContainer(
                        color: _colour,
                        duration: Duration(seconds: 5),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: themecolor,
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: SizedBox(
                  child: TextLiquidFill(
                    loadDuration: Duration(seconds: 7),
                    waveDuration: Duration(seconds: 2),
                    text: 'half-full games',
                    waveColor: themecolor,
                    boxBackgroundColor: themecolor,
                    textAlign: TextAlign.center,
                    textStyle: GoogleFonts.chilanka(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.15,
                      fontWeight: FontWeight.bold,
                    ),
                    boxWidth: MediaQuery.of(context).size.width,
                    boxHeight: MediaQuery.of(context).size.height * 0.33,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
