import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:sudoku/src/components/loading_widget.dart';
import 'package:sudoku/src/models/theme.dart';
import 'multiplayer_game_screen.dart';
import 'dart:math' as math;

class MultiplayerGameScreenScreenView extends MultiplayerGameScreenScreenState {
  Widget buildLoading() {
    return Scaffold(
      body: Container(
        color: AppTheme.getLightOrDarkModeTheme(isDark),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                child: Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.45),
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
                                style: GoogleFonts.lato(color: appTheme.themeColor, fontWeight: FontWeight.bold),
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
                    color: AppTheme.getLightOrDarkModeTheme(user.isDark),
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
                int value = currentGame.isCompetitive
                    ? currentCompetitiveGame == null
                        ? currentGame.level.board[index]
                        : currentCompetitiveGame.level.board[index]
                    : currentGame.level.board[index];
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
                            color: getCellTextColor(index, value), fontSize: getCellFontSize(index), fontStyle: getCellFontStyle(index), fontWeight: getCellFontWeight(index)),
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
                      style: GoogleFonts.lato(color: appTheme.themeColor, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      ":",
                      style: GoogleFonts.lato(color: appTheme.themeColor, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      StopWatchTimer.getDisplayTimeMinute(snap.data),
                      style: GoogleFonts.lato(color: appTheme.themeColor, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      ":",
                      style: GoogleFonts.lato(color: appTheme.themeColor, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      StopWatchTimer.getDisplayTimeSecond(snap.data),
                      style: GoogleFonts.lato(color: appTheme.themeColor, fontWeight: FontWeight.bold),
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

    if (isHost) {
      listOfButtonWidgets.add(
        Tooltip(
          message: 'copy game id',
          decoration: BoxDecoration(color: appTheme.themeColor),
          child: IconButton(
              icon: Icon(
                LineIcons.copy,
                color: appTheme.themeColor,
              ),
              onPressed: () {
                showCopiedSnackBar();
              }),
        ),
      );
    }

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
              style: GoogleFonts.lato(color: user.isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
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

  Widget buildHasCompleted() {
    return Scaffold(
      body: Container(
        color: AppTheme.getLightOrDarkModeTheme(isDark),
        width: MediaQuery.of(context).size.width,
        child: SafeArea(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isCompetitiveGame
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(competitiveGameWonBy == user.id ? 'congratulations!' : 'oops!',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: appTheme.themeColor,
                              )),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('congratulations!',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: appTheme.themeColor,
                              )),
                        ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      parseLevelTime(Duration(seconds: elapsedTime)).toUpperCase(),
                      style: GoogleFonts.lato(color: appTheme.themeColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  isCompetitiveGame
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: isHost ? MediaQuery.of(context).size.height * 1 / 6 : MediaQuery.of(context).size.height * 1 / 3,
                            child: Icon(
                              competitiveGameWonBy == user.id ? LineIcons.grinningFaceWithSmilingEyes : LineIcons.loudlyCryingFaceAlt,
                              color: appTheme.themeColor,
                              size: isHost ? MediaQuery.of(context).size.width * 0.25 : MediaQuery.of(context).size.width * 0.55,
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: isHost ? MediaQuery.of(context).size.height * 1 / 6 : MediaQuery.of(context).size.height * 1 / 3,
                            child: Icon(
                              LineIcons.checkCircle,
                              color: appTheme.themeColor,
                              size: isHost ? MediaQuery.of(context).size.width * 0.25 : MediaQuery.of(context).size.width * 0.55,
                            ),
                          ),
                        ),
                  isHost ? Container() : Padding(padding: const EdgeInsets.all(8.0), child: CircularProgressIndicator()),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      !isHost ? 'waiting for ${currentGame.players[currentGame.players.indexWhere((element) => element.id != user.id)].username} to restart the game' : '',
                      style: GoogleFonts.lato(color: appTheme.themeColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  isHost
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            isHost
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextButton(
                                      child: Text('play again', style: GoogleFonts.lato(fontSize: 16, color: appTheme.themeColor, fontWeight: FontWeight.bold)),
                                      onPressed: () {
                                        replay();
                                      },
                                    ),
                                  )
                                : Container(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'or',
                                style: GoogleFonts.lato(color: appTheme.themeColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextButton(
                                child: Text('end game', style: GoogleFonts.lato(fontSize: 16, color: appTheme.themeColor, fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  multiplayerProvider.deleteGame(currentGame.id);
                                  goToHomeScreen();
                                },
                              ),
                            )
                          ],
                        )
                      : Container(),
                  !isHost
                      ? TextButton(
                          child: Text('leave game', style: GoogleFonts.lato(fontSize: 16, color: appTheme.themeColor, fontWeight: FontWeight.bold)),
                          onPressed: () {
                            multiplayerProvider.leaveGame(currentGame, user);
                            goToHomeScreen();
                          },
                        )
                      : Container(),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'your score: ${user.score}',
                      style: GoogleFonts.lato(color: appTheme.themeColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  isHost
                      ? Divider(
                          color: appTheme.themeColor,
                        )
                      : Container(),
                  isHost
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'game options',
                            style: GoogleFonts.lato(color: appTheme.themeColor, fontWeight: FontWeight.bold),
                          ),
                        )
                      : Container(),
                  isHost
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    'cooperative',
                                    style: GoogleFonts.lato(
                                        color: appTheme.themeColor,
                                        fontSize: currentGame.isCooperative ? 16 : 14,
                                        fontWeight: currentGame.isCooperative ? FontWeight.bold : FontWeight.normal),
                                  ),
                                  Switch(
                                    value: currentGame.isCompetitive,
                                    onChanged: (value) {
                                      setCompetitiveSetting(value);
                                    },
                                    activeTrackColor: appTheme.themeColor[300],
                                    activeColor: appTheme.themeColor,
                                    inactiveThumbColor: appTheme.themeColor,
                                    inactiveTrackColor: appTheme.themeColor[300],
                                  ),
                                  Text(
                                    'competitive',
                                    style: GoogleFonts.lato(
                                        color: appTheme.themeColor,
                                        fontSize: currentGame.isCompetitive ? 16 : 14,
                                        fontWeight: currentGame.isCompetitive ? FontWeight.bold : FontWeight.normal),
                                  ),
                                ],
                              ),
                              Wrap(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    child: ChoiceChip(
                                      avatar: Icon(
                                        LineIcons.dice,
                                        color: isDark ? Colors.grey[900] : Colors.white,
                                      ),
                                      label: Text('random'),
                                      labelStyle: GoogleFonts.lato(color: isDark ? Colors.grey[900] : Colors.white, fontWeight: FontWeight.bold),
                                      backgroundColor: appTheme.themeColor,
                                      selected: currentGame.preferedPattern == 'Random',
                                      selectedColor: appTheme.themeColor[900],
                                      elevation: 0,
                                      disabledColor: appTheme.themeColor,
                                      onSelected: (value) {
                                        if (currentGame.preferedPattern != 'Random') {
                                          setBoardPatterns('Random');
                                        }
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    child: ChoiceChip(
                                      avatar: Icon(
                                        LineIcons.seedling,
                                        color: isDark ? Colors.grey[900] : Colors.white,
                                      ),
                                      label: Text('spring'),
                                      labelStyle: GoogleFonts.lato(color: isDark ? Colors.grey[900] : Colors.white, fontWeight: FontWeight.bold),
                                      backgroundColor: appTheme.themeColor,
                                      selected: currentGame.preferedPattern == 'spring',
                                      selectedColor: appTheme.themeColor[900],
                                      elevation: 0,
                                      disabledColor: appTheme.themeColor,
                                      onSelected: (value) {
                                        if (currentGame.preferedPattern != 'spring') {
                                          setBoardPatterns('spring');
                                        }
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    child: ChoiceChip(
                                      avatar: Icon(
                                        LineIcons.sunAlt,
                                        color: isDark ? Colors.grey[900] : Colors.white,
                                      ),
                                      label: Text('summer'),
                                      labelStyle: GoogleFonts.lato(color: isDark ? Colors.grey[900] : Colors.white, fontWeight: FontWeight.bold),
                                      backgroundColor: appTheme.themeColor,
                                      selected: currentGame.preferedPattern == 'summer',
                                      selectedColor: appTheme.themeColor[900],
                                      elevation: 0,
                                      disabledColor: appTheme.themeColor,
                                      onSelected: (value) {
                                        if (currentGame.preferedPattern != 'summer') {
                                          setBoardPatterns('summer');
                                        }
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    child: ChoiceChip(
                                      avatar: Icon(
                                        LineIcons.leaf,
                                        color: isDark ? Colors.grey[900] : Colors.white,
                                      ),
                                      label: Text('fall'),
                                      labelStyle: GoogleFonts.lato(color: isDark ? Colors.grey[900] : Colors.white, fontWeight: FontWeight.bold),
                                      backgroundColor: appTheme.themeColor,
                                      selected: currentGame.preferedPattern == 'fall',
                                      selectedColor: appTheme.themeColor[900],
                                      elevation: 0,
                                      disabledColor: appTheme.themeColor,
                                      onSelected: (value) {
                                        if (currentGame.preferedPattern != 'fall') {
                                          setBoardPatterns('fall');
                                        }
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    child: ChoiceChip(
                                      avatar: Icon(
                                        LineIcons.snowflake,
                                        color: isDark ? Colors.grey[900] : Colors.white,
                                      ),
                                      label: Text('winter'),
                                      labelStyle: GoogleFonts.lato(color: isDark ? Colors.grey[900] : Colors.white, fontWeight: FontWeight.bold),
                                      backgroundColor: appTheme.themeColor,
                                      selected: currentGame.preferedPattern == 'winter',
                                      selectedColor: appTheme.themeColor[900],
                                      elevation: 0,
                                      disabledColor: appTheme.themeColor,
                                      onSelected: (value) {
                                        if (currentGame.preferedPattern != 'winter') {
                                          setBoardPatterns('winter');
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Slider(
                                          label: currentGame.difficulty.toString(),
                                          value: currentGame.difficulty == 10 ? 0.0 : currentGame.difficulty.toDouble(),
                                          min: 0,
                                          max: 5,
                                          divisions: 5,
                                          activeColor: appTheme.themeColor,
                                          inactiveColor: appTheme.themeColor[200],
                                          onChanged: user.freePlayDifficulty == 10
                                              ? null
                                              : (value) {
                                                  setFreePlaydifficulty(value);
                                                }),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            'random?',
                                            style: GoogleFonts.lato(
                                              color: appTheme.themeColor,
                                            ),
                                          ),
                                          Checkbox(
                                            focusColor: appTheme.themeColor,
                                            hoverColor: appTheme.themeColor,
                                            value: currentGame.difficulty == 10,
                                            onChanged: (value) {
                                              setFreePlaydifficultyToRandom();
                                            },
                                            activeColor: appTheme.themeColor,
                                            checkColor: isDark ? Colors.grey[900] : Colors.white,
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: StreamBuilder(
        stream: multiplayerProvider.getCurrentGame(currentGame.id),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData || snapshot.data == null || snapshot.data.docs.length == 0) {
            return Container(
              child: Scaffold(
                body: Container(
                  color: AppTheme.getLightOrDarkModeTheme(isDark),
                  width: MediaQuery.of(context).size.width,
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Column(
                            children: [
                              isHost
                                  ? Container()
                                  : Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '$hostName has ended the game',
                                        style: GoogleFonts.lato(color: appTheme.themeColor, fontWeight: FontWeight.bold),
                                      ),
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
                            ],
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
              ? this.currentGame.hasFinished
                  ? buildHasCompleted()
                  : Scaffold(
                      key: scaffoldKey,
                      appBar: PreferredSize(
                        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.1),
                        child: AppBar(
                          backgroundColor: AppTheme.getLightOrDarkModeTheme(user.isDark),
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
                                        getInitials(currentGame.players[index].username),
                                        style: GoogleFonts.lato(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: isDark ? Colors.grey[900] : Colors.white,
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
                          title: Icon(
                            currentGame.isCooperative ? LineIcons.handshake : LineIcons.helpingHands,
                            color: appTheme.themeColor,
                          ),
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
                      ),
                      body: GestureDetector(
                        onTap: () {
                          clearSelectedIndex();
                        },
                        child: Container(
                          color: AppTheme.getLightOrDarkModeTheme(user.isDark),
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
