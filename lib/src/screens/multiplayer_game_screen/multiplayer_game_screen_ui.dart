import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sudoku/src/components/loading_widget.dart';
import 'multiplayer_game_screen.dart';

class MultiplayerGameScreenScreenView extends MultiplayerGameScreenScreenState {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          color: isDark ? Colors.grey[900] : Colors.white,
          child: SafeArea(
              child: Column(
            children: [
              StreamBuilder(
                stream: multiplayerProvider.getCurrentGame(currentGame.id),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return Container();
                  }
                  processMultiplayerGameStreamData(snapshot);
                  return this.currentGame.hasStarted
                      ? Container()
                      : Container(
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.45),
                            child: Column(
                              children: [
                                LoadingWidget(
                                  appTheme: appTheme,
                                  isDark: isDark,
                                ),
                                isHost
                                    ? Container()
                                    : Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'waiting for ${currentGame.players[currentGame.players.indexWhere((element) => element.id != user.id)].username}',
                                          style: GoogleFonts.lato(
                                              color: appTheme.themeColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                              ],
                            ),
                          ),
                        );
                },
              ),
            ],
          )),
        ),
      ),
    );
  }
}
