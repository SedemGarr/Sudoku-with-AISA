import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:sudoku/src/components/loading_widget.dart';
import 'multiplayer_lobby_screen.dart';

class MultiplayerLobbyScreenView extends MultiplayerLobbyScreenState {
  Widget buildTopNavBar() {
    return Container(
        child: Row(
      children: [
        Expanded(
            child: GestureDetector(
          onTap: () {
            join();
          },
          child: Container(
            color: isJoining ? appTheme.themeColor : null,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'join',
                  style: GoogleFonts.lato(
                      color: isJoining
                          ? isDark
                              ? Colors.grey[900]
                              : Colors.white
                          : appTheme.themeColor,
                      fontWeight:
                          isJoining ? FontWeight.bold : FontWeight.normal),
                ),
              ),
            ),
          ),
        )),
        Expanded(
            child: GestureDetector(
          onTap: () {
            host();
          },
          child: Container(
            color: isHosting ? appTheme.themeColor : null,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'start',
                  style: GoogleFonts.lato(
                      color: isHosting
                          ? isDark
                              ? Colors.grey[900]
                              : Colors.white
                          : appTheme.themeColor,
                      fontWeight:
                          isHosting ? FontWeight.bold : FontWeight.normal),
                ),
              ),
            ),
          ),
        ))
      ],
    ));
  }

  Widget buildContents() {
    return Container(
      child: isJoining ? buildJoining() : buildHosting(),
    );
  }

  Widget buildJoinGameForm() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
          key: formKey,
          child: Row(
            children: [
              Expanded(
                  child: TextFormField(
                cursorColor: appTheme.themeColor,
                keyboardType: TextInputType.text,
                style: GoogleFonts.lato(color: appTheme.themeColor),
                decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: appTheme.themeColor)),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: appTheme.themeColor)),
                    hintText: 'enter a game id',
                    hintStyle: GoogleFonts.lato(color: appTheme.themeColor)),
                onChanged: (value) {
                  joiningGameId = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please a valid game id';
                  }
                  return null;
                },
              )),
              IconButton(
                  icon: Icon(
                    LineIcons.arrowRight,
                    color: appTheme.themeColor,
                  ),
                  onPressed: () {
                    submitAndJoinGame();
                  })
            ],
          )),
    );
  }

  Widget buildNoGames() {
    return Center(
        child: Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.25),
      child: Text(
        'no games',
        style: GoogleFonts.lato(
          color: appTheme.themeColor,
        ),
      ),
    ));
  }

  Widget buildJoining() {
    return isLoading
        ? LoadingWidget(appTheme: appTheme, isDark: user.isDark)
        : Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                buildJoinGameForm(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    onGoingGames.length != 0 ? 'currently running games' : '',
                    style: GoogleFonts.lato(
                        color: appTheme.themeColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Flexible(
                  child: StreamBuilder(
                    stream: multiplayerProvider.getOngoingGames(this.user.id),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data == null) {
                        return Container();
                      }
                      processOngoingGamesStreamData(snapshot);
                      if (onGoingGames.length == 0) {
                        buildNoGames();
                      }
                      return Container(
                        child: ListTile(),
                        // add end game to the trailing if user is the host
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }

  Widget buildHosting() {
    return Container(
      child: isLoading
          ? Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.25),
              child: LoadingWidget(appTheme: appTheme, isDark: user.isDark),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SelectableText(
                            currentGame.id,
                            style: GoogleFonts.lato(
                                color: appTheme.themeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 25),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'this is your game id. your friend will use it to join your game. the game will start as soon as your friend joins',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                              color: appTheme.themeColor,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Flexible(
                    child: StreamBuilder(
                        stream: multiplayerProvider.getStartingGame(gameId),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (!snapshot.hasData || snapshot.data == null) {
                            return Container();
                          }
                          processStartingGameStreamData(snapshot);
                          return Column(
                            children: [
                              // build options
                              ListTile(),
                            ],
                          );
                        }))
              ],
            ),
    );
  }

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
              children: [buildTopNavBar(), buildContents()],
            ),
          ),
        ),
      ),
    );
  }
}
