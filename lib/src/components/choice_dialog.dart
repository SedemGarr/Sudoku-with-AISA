import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sudoku/src/models/theme.dart';

showChoiceDialog({
  @required BuildContext context,
  @required String title,
  @required String contentMessage,
  @required String yesMessage,
  @required String noMessage,
  @required bool isDark,
  @required AppTheme appTheme,
  @required VoidCallback onYes,
  @required VoidCallback onNo,
}) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.getLightOrDarkModeTheme(isDark),
          title: Text(title, textAlign: TextAlign.center, style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.grey[900])),
          content: Text(
            contentMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(color: isDark ? Colors.white : Colors.grey[900]),
          ),
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {
                      onNo();
                    },
                    child: Text(noMessage, textAlign: TextAlign.end, style: GoogleFonts.roboto(color: isDark ? Colors.white : Colors.grey[900]))),
                TextButton(
                  onPressed: () {
                    onYes();
                  },
                  child: Text(
                    yesMessage,
                    textAlign: TextAlign.end,
                    style: GoogleFonts.roboto(color: appTheme.themeColor),
                  ),
                ),
              ],
            ),
          ],
        );
      });
}
