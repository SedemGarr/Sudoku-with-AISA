import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TitleWidgets extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 8.0),
      child: Center(
        child: Column(
          children: [
            Container(
              //color: Colors.red,
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.contain,
                child: RichText(
                    text: TextSpan(children: [
                  TextSpan(
                    text: "S",
                    style: GoogleFonts.architectsDaughter(
                      color: Colors.blue,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: "u",
                    style: GoogleFonts.architectsDaughter(
                      color: Colors.orange,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: "d",
                    style: GoogleFonts.architectsDaughter(
                      color: Colors.cyan,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: "o",
                    style: GoogleFonts.architectsDaughter(
                      color: Colors.red,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: "k",
                    style: GoogleFonts.architectsDaughter(
                      color: Colors.purple,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: "u",
                    style: GoogleFonts.architectsDaughter(
                      color: Colors.black,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ])),
              ),
            ),
            Center(
              child: Container(
                child: Text(
                  'with AISA',
                  style: GoogleFonts.architectsDaughter(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
