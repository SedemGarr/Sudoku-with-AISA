import 'package:circular_profile_avatar/circular_profile_avatar.dart';
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

  Widget buildContents(BuildContext context) {
    return Container(
      child: isJoining ? buildJoining(context) : buildHosting(),
    );
  }

  Widget buildJoinGameForm(BuildContext context) {
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
                    submitAndJoinGame(context);
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

  Widget buildJoining(BuildContext context) {
    return isLoading
        ? Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.25),
                child: LoadingWidget(appTheme: appTheme, isDark: user.isDark),
              ),
            ],
          )
        : Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                buildJoinGameForm(context),
                Flexible(
                  child: StreamBuilder(
                    stream: multiplayerProvider.getOngoingGames(user),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data == null) {
                        return Container();
                      }
                      processOngoingGamesStreamData(snapshot);
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              onGoingGames.length != 0
                                  ? 'currently running games'
                                  : '',
                              style: GoogleFonts.lato(
                                  color: appTheme.themeColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                              child: onGoingGames.length == 0
                                  ? buildNoGames()
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: onGoingGames.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ListTile(
                                            onTap: () {
                                              showJoiningGameFromListDialog(
                                                  onGoingGames[index], context);
                                            },
                                            dense: true,
                                            tileColor: appTheme.themeColor,
                                            leading: CircularProfileAvatar(
                                              onGoingGames[index]
                                                          .players
                                                          .indexWhere(
                                                              (element) =>
                                                                  element
                                                                      .id !=
                                                                  user.id) ==
                                                      -1
                                                  ? user.profileUrl
                                                  : onGoingGames[index]
                                                      .players[
                                                          onGoingGames[index]
                                                              .players
                                                              .indexWhere(
                                                                  (element) =>
                                                                      element
                                                                          .id !=
                                                                      user.id)]
                                                      .profileUrl,
                                              radius: 20,
                                              backgroundColor: isDark
                                                  ? Colors.grey[900]
                                                  : Colors.white,
                                              initialsText: Text(
                                                getInitials(onGoingGames[index]
                                                            .players
                                                            .indexWhere(
                                                                (element) =>
                                                                    element
                                                                        .id !=
                                                                    user.id) ==
                                                        -1
                                                    ? user.username
                                                    : onGoingGames[index]
                                                        .players[onGoingGames[
                                                                index]
                                                            .players
                                                            .indexWhere(
                                                                (element) =>
                                                                    element
                                                                        .id !=
                                                                    user.id)]
                                                        .username),
                                                style: GoogleFonts.lato(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: appTheme.themeColor,
                                                ),
                                              ),
                                              borderColor: Colors.transparent,
                                              elevation: 0.0,
                                              foregroundColor:
                                                  Colors.transparent,
                                              cacheImage: true,
                                              showInitialTextAbovePicture:
                                                  false,
                                            ),
                                            title: onGoingGames[index]
                                                        .players
                                                        .indexWhere((element) =>
                                                            element.id !=
                                                            user.id) ==
                                                    -1
                                                ? Text(
                                                    'only you',
                                                    style: GoogleFonts.lato(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: isDark
                                                            ? Colors.grey[900]
                                                            : Colors.white),
                                                  )
                                                : Text(
                                                    onGoingGames[index]
                                                            .players[onGoingGames[
                                                                    index]
                                                                .players
                                                                .indexWhere(
                                                                    (element) =>
                                                                        element
                                                                            .id !=
                                                                        user.id)]
                                                            .username +
                                                        ' and you',
                                                    style: GoogleFonts.lato(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: isDark
                                                            ? Colors.grey[900]
                                                            : Colors.white),
                                                  ),
                                            subtitle: Text(
                                              formatDateTime(onGoingGames[index]
                                                  .lastPlayedOn),
                                              style: GoogleFonts.lato(
                                                  color: isDark
                                                      ? Colors.grey[900]
                                                      : Colors.white),
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                    icon: Icon(
                                                        onGoingGames[index]
                                                                .isCooperative
                                                            ? LineIcons
                                                                .handshake
                                                            : LineIcons
                                                                .helpingHands,
                                                        color: isDark
                                                            ? Colors.grey[900]
                                                            : Colors.white),
                                                    onPressed: () {}),
                                                onGoingGames[index].hostId ==
                                                        user.id
                                                    ? IconButton(
                                                        icon: Icon(
                                                            LineIcons.trash,
                                                            color: isDark
                                                                ? Colors
                                                                    .grey[900]
                                                                : Colors.white),
                                                        onPressed: () {
                                                          showDeleteGameDialog(
                                                              onGoingGames[
                                                                  index],
                                                              context);
                                                        })
                                                    : IconButton(
                                                        icon: Icon(
                                                            LineIcons.unlink,
                                                            color: isDark
                                                                ? Colors
                                                                    .grey[900]
                                                                : Colors.white),
                                                        onPressed: () {
                                                          showLeaveGameDialog(
                                                              onGoingGames[
                                                                  index],
                                                              context);
                                                        }),
                                              ],
                                            ),
                                          ),
                                        );
                                      })
                              // add end game to the trailing if user is the host
                              ),
                        ],
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
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: FlatButton.icon(
                                  onPressed: () {
                                    share();
                                  },
                                  icon: Icon(
                                    LineIcons.share,
                                    color: appTheme.themeColor,
                                  ),
                                  label: Text(
                                    'share game id',
                                    style: GoogleFonts.lato(
                                        color: appTheme.themeColor),
                                  )),
                            ),
                            !hasInvited
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: FlatButton.icon(
                                        onPressed: () {
                                          showInviteFriendsDialog(context);
                                        },
                                        icon: Icon(
                                          LineIcons.userPlus,
                                          color: appTheme.themeColor,
                                        ),
                                        label: Text(
                                          'invite friend',
                                          style: GoogleFonts.lato(
                                              color: appTheme.themeColor),
                                        )),
                                  )
                                : Container()
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: StreamBuilder(
                      stream:
                          multiplayerProvider.getStartingGame(currentGame.id),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData || snapshot.data == null) {
                          return Container();
                        }
                        processStartingGameStreamData(snapshot, context);
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: LinearProgressIndicator(
                                backgroundColor:
                                    isDark ? Colors.grey[900] : Colors.white,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    appTheme.themeColor),
                                minHeight: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'game options',
                                style: GoogleFonts.lato(
                                    color: appTheme.themeColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    'cooperative',
                                    style: GoogleFonts.lato(
                                        color: appTheme.themeColor,
                                        fontSize:
                                            currentGame.isCooperative ? 16 : 14,
                                        fontWeight: currentGame.isCooperative
                                            ? FontWeight.bold
                                            : FontWeight.normal),
                                  ),
                                  Switch(
                                    value: currentGame.isCompetitive,
                                    onChanged: (value) {
                                      setCompetitiveSetting(value);
                                    },
                                    activeTrackColor: appTheme.themeColor[300],
                                    activeColor: appTheme.themeColor,
                                    inactiveThumbColor: appTheme.themeColor,
                                    inactiveTrackColor:
                                        appTheme.themeColor[300],
                                  ),
                                  Text(
                                    'competitive',
                                    style: GoogleFonts.lato(
                                        color: appTheme.themeColor,
                                        fontSize:
                                            currentGame.isCompetitive ? 16 : 14,
                                        fontWeight: currentGame.isCompetitive
                                            ? FontWeight.bold
                                            : FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Wrap(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: ChoiceChip(
                                      avatar: Icon(
                                        LineIcons.dice,
                                        color: isDark
                                            ? Colors.grey[900]
                                            : Colors.white,
                                      ),
                                      label: Text('random'),
                                      labelStyle: GoogleFonts.lato(
                                          color: isDark
                                              ? Colors.grey[900]
                                              : Colors.white,
                                          fontWeight: FontWeight.bold),
                                      backgroundColor: appTheme.themeColor,
                                      selected: preferedPattern == 'Random',
                                      selectedColor: appTheme.themeColor[900],
                                      elevation: 0,
                                      disabledColor: appTheme.themeColor,
                                      onSelected: (value) {
                                        if (preferedPattern != 'Random') {
                                          setBoardPatterns('Random');
                                        }
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: ChoiceChip(
                                      avatar: Icon(
                                        LineIcons.seedling,
                                        color: isDark
                                            ? Colors.grey[900]
                                            : Colors.white,
                                      ),
                                      label: Text('spring'),
                                      labelStyle: GoogleFonts.lato(
                                          color: isDark
                                              ? Colors.grey[900]
                                              : Colors.white,
                                          fontWeight: FontWeight.bold),
                                      backgroundColor: appTheme.themeColor,
                                      selected: preferedPattern == 'spring',
                                      selectedColor: appTheme.themeColor[900],
                                      elevation: 0,
                                      disabledColor: appTheme.themeColor,
                                      onSelected: (value) {
                                        if (preferedPattern != 'spring') {
                                          setBoardPatterns('spring');
                                        }
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: ChoiceChip(
                                      avatar: Icon(
                                        LineIcons.sunAlt,
                                        color: isDark
                                            ? Colors.grey[900]
                                            : Colors.white,
                                      ),
                                      label: Text('summer'),
                                      labelStyle: GoogleFonts.lato(
                                          color: isDark
                                              ? Colors.grey[900]
                                              : Colors.white,
                                          fontWeight: FontWeight.bold),
                                      backgroundColor: appTheme.themeColor,
                                      selected: preferedPattern == 'summer',
                                      selectedColor: appTheme.themeColor[900],
                                      elevation: 0,
                                      disabledColor: appTheme.themeColor,
                                      onSelected: (value) {
                                        if (preferedPattern != 'summer') {
                                          setBoardPatterns('summer');
                                        }
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: ChoiceChip(
                                      avatar: Icon(
                                        LineIcons.leaf,
                                        color: isDark
                                            ? Colors.grey[900]
                                            : Colors.white,
                                      ),
                                      label: Text('fall'),
                                      labelStyle: GoogleFonts.lato(
                                          color: isDark
                                              ? Colors.grey[900]
                                              : Colors.white,
                                          fontWeight: FontWeight.bold),
                                      backgroundColor: appTheme.themeColor,
                                      selected: preferedPattern == 'fall',
                                      selectedColor: appTheme.themeColor[900],
                                      elevation: 0,
                                      disabledColor: appTheme.themeColor,
                                      onSelected: (value) {
                                        if (preferedPattern != 'fall') {
                                          setBoardPatterns('fall');
                                        }
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: ChoiceChip(
                                      avatar: Icon(
                                        LineIcons.snowflake,
                                        color: isDark
                                            ? Colors.grey[900]
                                            : Colors.white,
                                      ),
                                      label: Text('winter'),
                                      labelStyle: GoogleFonts.lato(
                                          color: isDark
                                              ? Colors.grey[900]
                                              : Colors.white,
                                          fontWeight: FontWeight.bold),
                                      backgroundColor: appTheme.themeColor,
                                      selected: preferedPattern == 'winter',
                                      selectedColor: appTheme.themeColor[900],
                                      elevation: 0,
                                      disabledColor: appTheme.themeColor,
                                      onSelected: (value) {
                                        if (preferedPattern != 'winter') {
                                          setBoardPatterns('winter');
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                ),
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
          actions: [
            isHosting
                ? Container()
                : IconButton(
                    icon: Icon(
                      LineIcons.userFriends,
                      color: appTheme.themeColor,
                    ),
                    onPressed: () {
                      gotoFriendsScreen();
                    })
          ],
        ),
        body: Container(
          color: isDark ? Colors.grey[900] : Colors.white,
          child: SafeArea(
            child: Column(
              children: [
                buildTopNavBar(),
                buildContents(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
