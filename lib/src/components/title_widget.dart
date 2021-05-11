import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TitleWidget extends StatelessWidget {
  final MaterialColor color;

  TitleWidget({this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.90,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Column(
          children: [
            RichText(
                text: TextSpan(children: [
              TextSpan(
                text: "s",
                style: GoogleFonts.architectsDaughter(
                  color: color,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: "u",
                style: GoogleFonts.architectsDaughter(
                  color: color,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: "d",
                style: GoogleFonts.architectsDaughter(
                  color: color,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: "o",
                style: GoogleFonts.architectsDaughter(
                  color: color,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: "k",
                style: GoogleFonts.architectsDaughter(
                  color: color,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: "u",
                style: GoogleFonts.architectsDaughter(
                  color: color,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ])),
            Text(
              'with AISA',
              style: GoogleFonts.lato(fontSize: 3, color: color),
            )
          ],
        ),
      ),
    );
  }
}
