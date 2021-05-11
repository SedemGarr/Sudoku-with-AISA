import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sudoku/src/components/aisa_avatar.dart';
import 'package:sudoku/src/components/loading_widget.dart';
import 'package:sudoku/src/components/title_widget.dart';
import 'package:sudoku/src/screens/home_screen/home_screen.dart';
import 'auth_screen.dart';

class AuthScreenView extends AuthScreenState {
  Widget buildSignInButton() {
    return Container(
      child: OutlineButton.icon(
        onPressed: () {
          signIn();
        },
        icon: Icon(
          FontAwesomeIcons.google,
          color: appTheme.themeColor,
        ),
        shape: StadiumBorder(),
        borderSide: BorderSide(color: appTheme.themeColor),
        padding: const EdgeInsets.all(10),
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
      decoration:
          BoxDecoration(color: isDark ? Colors.grey[900] : Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(),
          TitleWidget(
            color: appTheme.themeColor,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 1 / 7),
            child: AISAAvatar(color: appTheme.themeColor),
          ),
          Spacer(),
          isLoading
              ? LoadingWidget(appTheme: appTheme, isDark: isDark)
              : buildSignInButton(),
          Spacer(),
        ],
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
