import 'package:flutter/material.dart';
import 'package:flutter_sudoku/landingpage.dart';
import 'package:splashscreen/splashscreen.dart';
import 'globalvariables.dart';

class Splashcreen extends StatefulWidget {
  @override
  _SplashcreenState createState() => _SplashcreenState();
}

class _SplashcreenState extends State<Splashcreen> {
//  bool _visible = false;

  @override
  void initState() {
    setState(() {
      wait();
      // Future.delayed(const Duration(seconds: 2), () {
      //   setState(() {
      //     _visible = true;
      //   });
      // });
      // Future.delayed(
      //     const Duration(seconds: 6),
      //     () => Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //           builder: (context) => LandingPage(),
      //         )));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return
        //Container(
        //     color: colors[colorindex],
        //     child: Center(
        //       child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        //         AnimatedOpacity(
        //           // If the widget is visible, animate to 0.0 (invisible).
        //           // If the widget is hidden, animate to 1.0 (fully visible).
        //           opacity: _visible ? 1.0 : 0.0,
        //           duration: Duration(milliseconds: 2500),
        //           // The green box must be a child of the AnimatedOpacity widget.
        //           child: CircularProgressIndicator(
        //             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        //             backgroundColor: colors[colorindex],
        //           ),
        //         )
        //       ]),
        //     ));

        SplashScreen(
            seconds: 10,
            navigateAfterSeconds: LandingPage(),
            // title: new Text(
            //   'Welcome',
            //   style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            // ),
            image: new Image.asset('images/aisa.png'),
            backgroundColor: Colors.white,
            //  styleTextUnderTheLoader: new TextStyle(),
            photoSize: 100.0,
            // onClick: () => print("Flutter Egypt"),
            loaderColor: colors[colorindex]);
  }
}
