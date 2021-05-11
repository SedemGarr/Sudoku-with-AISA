import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'multiplayer_lobby_screen.dart';

class MultiplayerLobbyScreenView extends MultiplayerLobbyScreenState {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          elevation: 0,
          title: Text(
            'multiplayer',
            style: GoogleFonts.lato(
              color: appTheme.themeColor,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(
                LineIcons.arrowLeft,
                color: appTheme.themeColor,
              ),
              onPressed: () {
                goToHomeScreen();
              }),
        ),
        body: Container(
          color: isDark ? Colors.grey[900] : Colors.white,
          child: SafeArea(
            child: Column(
              children: [],
            ),
          ),
        ),
      ),
    );
  }
}
