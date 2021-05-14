import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:sudoku/src/components/loading_widget.dart';
import 'multiplayer_game_screen.dart';
import 'dart:math' as math;

class MultiplayerGameScreenScreenView extends MultiplayerGameScreenScreenState {
  Widget buildLoading() {
    return Scaffold(
      body: Container(
        color: isDark ? Colors.grey[900] : Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              Container(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBoard() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          // for thick border
          GridView.builder(
              shrinkWrap: true,
              itemCount: 9,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: appTheme.themeColor)),
                );
              }),
          // eliminate outside border
          GridView.builder(
              shrinkWrap: true,
              itemCount: 1,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
              ),
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                    width: 2,
                    color: user.isDark ? Colors.grey[900] : Colors.white,
                  )),
                );
              }),
          // actual grid
          GridView.builder(
              shrinkWrap: true,
              itemCount: 81,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9,
              ),
              itemBuilder: (BuildContext context, int index) {
                int value = currentGame.level.board[index];
                return GestureDetector(
                  onTap: filledCells.contains(index)
                      ? () {}
                      : () {
                          selectIndex(index);
                        },
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    color: getCellColor(index, value),
                    child: Center(
                      child: Text(
                        isCellEmpty(value) ? '-' : value.toString(),
                        style: GoogleFonts.lato(
                            color: getCellTextColor(index, value),
                            fontSize: getCellFontSize(index),
                            fontStyle: getCellFontStyle(index),
                            fontWeight: getCellFontWeight(index)),
                      ),
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }

  Widget buildStopWatch() {
    return Container(
      child: StreamBuilder<int>(
        stream: stopWatchTimer.rawTime,
        initialData: 0,
        builder: (context, snap) {
          elapsedTime = StopWatchTimer.getRawSecond(snap.data);
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      StopWatchTimer.getDisplayTimeHours(snap.data),
                      style: GoogleFonts.lato(
                          color: appTheme.themeColor,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      ":",
                      style: GoogleFonts.lato(
                          color: appTheme.themeColor,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      StopWatchTimer.getDisplayTimeMinute(snap.data),
                      style: GoogleFonts.lato(
                          color: appTheme.themeColor,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      ":",
                      style: GoogleFonts.lato(
                          color: appTheme.themeColor,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      StopWatchTimer.getDisplayTimeSecond(snap.data),
                      style: GoogleFonts.lato(
                          color: appTheme.themeColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildButtonRow(BuildContext context) {
    List<Widget> listOfButtonWidgets = [
      (isHost)
          ? Transform.rotate(
              angle: -math.pi / 4,
              child: Tooltip(
                message: 'end game',
                decoration: BoxDecoration(color: appTheme.themeColor),
                child: IconButton(
                    icon: Icon(
                      LineIcons.plus,
                      color: appTheme.themeColor,
                    ),
                    onPressed: () {
                      showDeleteGameDialog(currentGame, context);
                    }),
              ),
            )
          : Tooltip(
              message: 'leave game',
              decoration: BoxDecoration(color: appTheme.themeColor),
              child: IconButton(
                  icon: Icon(
                    LineIcons.unlink,
                    color: appTheme.themeColor,
                  ),
                  onPressed: () {
                    showLeaveGameDialog(currentGame, context);
                  }),
            ),
      Tooltip(
        message: 'go home',
        decoration: BoxDecoration(color: appTheme.themeColor),
        child: IconButton(
            icon: Icon(
              LineIcons.home,
              color: appTheme.themeColor,
            ),
            onPressed: () {
              goToHomeScreen();
            }),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: listOfButtonWidgets,
        ),
      ),
    );
  }

  Widget buildNumberPad(BuildContext context) {
    List<Widget> numberPadWidgets = [];

    for (int i = 1; i < 10; i++) {
      numberPadWidgets.add(Expanded(
        child: Container(
          color: appTheme.themeColor,
          child: IconButton(
            icon: Text(
              i.toString(),
              style: GoogleFonts.lato(
                  color: user.isDark ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              setCellValue(i, context);
            },
          ),
        ),
      ));
    }
    return Container(
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: numberPadWidgets),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: StreamBuilder(
        stream: multiplayerProvider.getCurrentGame(currentGame.id),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data.docs.length == 0) {
            return Container(
              child: Scaffold(
                body: Container(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  width: MediaQuery.of(context).size.width,
                  child: SafeArea(
                    child: Column(
                      children: [
                        Container(
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.45),
                            child: Column(
                              children: [
                                isHost
                                    ? Container()
                                    : Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          '$hostName has ended the game',
                                          style: GoogleFonts.lato(
                                              color: appTheme.themeColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                Tooltip(
                                  message: 'go home',
                                  decoration:
                                      BoxDecoration(color: appTheme.themeColor),
                                  child: IconButton(
                                      icon: Icon(
                                        LineIcons.home,
                                        color: appTheme.themeColor,
                                      ),
                                      onPressed: () {
                                        goToHomeScreen();
                                      }),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          processMultiplayerGameStreamData(snapshot);
          return this.currentGame.hasStarted
              ? Scaffold(
                  key: scaffoldKey,
                  appBar: PreferredSize(
                    preferredSize: Size.fromHeight(
                        MediaQuery.of(context).size.height * 0.1),
                    child: AppBar(
                      backgroundColor:
                          user.isDark ? Colors.grey[900] : Colors.white,
                      elevation: 0,
                      leadingWidth: MediaQuery.of(context).size.width * 0.5,
                      leading: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: this.currentGame.players.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                child: CircularProfileAvatar(
                                  currentGame.players[index].profileUrl,
                                  radius: 20,
                                  // MediaQuery.of(context).size.height * 0.1,
                                  backgroundColor: appTheme.themeColor,
                                  initialsText: Text(
                                    getInitials(
                                        currentGame.players[index].username),
                                    style: GoogleFonts.lato(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.grey[900]
                                          : Colors.white,
                                    ),
                                  ),
                                  borderColor: Colors.transparent,
                                  elevation: 0.0,
                                  foregroundColor: Colors.transparent,
                                  cacheImage: true,
                                  showInitialTextAbovePicture: false,
                                ),
                              ),
                            );
                          }),
                      actions: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildStopWatch(),
                          ],
                        )
                      ],
                    ),
                  ),
                  body: GestureDetector(
                    onTap: () {
                      clearSelectedIndex();
                    },
                    child: Container(
                      color: user.isDark ? Colors.grey[900] : Colors.white,
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01,
                            ),
                            buildBoard(),
                            Expanded(
                              child: Container(),
                            ),
                            buildButtonRow(context),
                            buildNumberPad(context)
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : buildLoading();
        },
      ),
    );
  }
}
