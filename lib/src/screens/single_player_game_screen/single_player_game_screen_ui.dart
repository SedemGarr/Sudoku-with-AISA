import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:sudoku/src/models/theme.dart';
import 'package:sudoku/src/screens/single_player_game_screen/single_player_game_screen.dart';

class SinglePlayerGameScreenView extends SinglePlayerGameScreenState {
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
                  decoration: BoxDecoration(border: Border.all(color: appTheme.themeColor)),
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
                    color: AppTheme.getLightOrDarkModeTheme(isDark),
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
                int value = game[user.difficultyLevel].levels[user.level].board[index];
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
                        style: GoogleFonts.roboto(color: getCellTextColor(index, value), fontWeight: FontWeight.bold),
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
                      style: GoogleFonts.quicksand(color: appTheme.themeColor, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      ":",
                      style: GoogleFonts.quicksand(color: appTheme.themeColor, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      StopWatchTimer.getDisplayTimeMinute(snap.data),
                      style: GoogleFonts.quicksand(color: appTheme.themeColor, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      ":",
                      style: GoogleFonts.quicksand(color: appTheme.themeColor, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      StopWatchTimer.getDisplayTimeSecond(snap.data),
                      style: GoogleFonts.quicksand(color: appTheme.themeColor, fontWeight: FontWeight.bold),
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

  Widget buildButtonRow() {
    List<Widget> listOfButtonWidgets = [
      Tooltip(
        message: 'undo all changes',
        decoration: BoxDecoration(color: appTheme.themeColor),
        child: IconButton(
            icon: Icon(
              LineIcons.undo,
              color: appTheme.themeColor,
            ),
            onPressed: () {
              revertBoard();
            }),
      ),
      Tooltip(
        message: 'get a new board',
        decoration: BoxDecoration(color: appTheme.themeColor),
        child: IconButton(
            icon: Icon(
              LineIcons.alternateRedo,
              color: appTheme.themeColor,
            ),
            onPressed: () {
              regenerateBoard(this.user.difficultyLevel, this.user.level);
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
              style: GoogleFonts.quicksand(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              setCellValue(i, context);
            },
          ),
        ),
      ));
    }
    return Container(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: numberPadWidgets),
    );
  }

  @override
  Widget build(BuildContext context) {
    loadInWidgets();
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: AppTheme.getLightOrDarkModeTheme(isDark),
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              LineIcons.arrowLeft,
              color: appTheme.themeColor,
            ),
            onPressed: () {
              disableWakeLock();
              goToHomeScreen();
            },
          ),
          title: getCurrentLevelForAppBar(),
          centerTitle: true,
          actions: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildStopWatch(),
              ],
            )
          ],
        ),
        body: GestureDetector(
          onTap: () {
            clearSelectedIndex();
          },
          child: Container(
            color: AppTheme.getLightOrDarkModeTheme(isDark),
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: widgetOpacity,
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
                  buildButtonRow(),
                  buildNumberPad(context)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
