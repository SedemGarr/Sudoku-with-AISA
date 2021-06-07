import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sudoku/src/components/aisa_avatar.dart';
import 'package:sudoku/src/components/loading_widget.dart';
import 'package:sudoku/src/components/title_widget.dart';
import 'package:sudoku/src/models/theme.dart';
import 'package:sudoku/src/screens/home_screen/home_screen.dart';
import 'auth_screen.dart';

class AuthScreenView extends AuthScreenState {
  Widget buildCopyrightText() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            packageInfo == null ? '' : 'version ${packageInfo.version}',
            style: GoogleFonts.lato(color: appTheme.themeColor),
          ),
          Text(
            'copyright © ${DateTime.now().year} half-full games. all rights reserved',
            style: GoogleFonts.lato(color: appTheme.themeColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget buildSignInButton() {
    return Container(
      child: OutlinedButton.icon(
        onPressed: () {
          signIn();
        },
        icon: Icon(
          FontAwesomeIcons.google,
          color: appTheme.themeColor,
        ),
        style: ButtonStyle(
          shape: MaterialStateProperty.all(StadiumBorder()),
          side: MaterialStateProperty.all(BorderSide(color: AppTheme.getLightOrDarkModeTheme(isDark))),
          padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
        ),
        label: Text(
          'sign in with google',
          style: GoogleFonts.lato(color: appTheme.themeColor, fontSize: 20),
        ),
      ),
    );
  }

  Widget buildSignInView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(color: AppTheme.getLightOrDarkModeTheme(isDark)),
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 500),
        opacity: widgetOpacity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),
            TitleWidget(
              color: appTheme.themeColor,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 1 / 7),
              child: AISAAvatar(color: appTheme.themeColor),
            ),
            Spacer(),
            isLoading ? LoadingWidget(appTheme: appTheme, isDark: isDark) : buildSignInButton(),
            Spacer(),
            buildCopyrightText()
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: scaffoldKey,
        body: widget.user == null
            ? buildSignInView()
            : HomeScreen(
                user: widget.user,
                fromAuthScreen: true,
              ),
      ),
    );
  }
}
