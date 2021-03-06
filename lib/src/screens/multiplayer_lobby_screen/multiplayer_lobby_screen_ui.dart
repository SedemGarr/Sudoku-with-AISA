import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:sudoku/src/components/loading_widget.dart';
import 'package:sudoku/src/models/theme.dart';
import 'multiplayer_lobby_screen.dart';
import 'dart:math' as math;

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
                  style: GoogleFonts.quicksand(
                      color: isJoining
                          ? isDark
                              ? Colors.grey[900]
                              : Colors.white
                          : appTheme.themeColor,
                      fontWeight: isJoining ? FontWeight.bold : FontWeight.normal),
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
                  style: GoogleFonts.quicksand(
                      color: isHosting
                          ? isDark
                              ? Colors.grey[900]
                              : Colors.white
                          : appTheme.themeColor,
                      fontWeight: isHosting ? FontWeight.bold : FontWeight.normal),
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
                style: GoogleFonts.quicksand(color: appTheme.themeColor),
                decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: appTheme.themeColor)),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: appTheme.themeColor)),
                    hintText: 'enter a game id',
                    hintStyle: GoogleFonts.quicksand(color: appTheme.themeColor)),
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
        style: GoogleFonts.roboto(
          color: appTheme.themeColor,
        ),
      ),
    ));
  }

  Widget buildNoInvitations() {
    return Center(
        child: Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.25),
      child: Text(
        'no invitations',
        style: GoogleFonts.roboto(
          color: appTheme.themeColor,
        ),
      ),
    ));
  }

  Widget buildViewInvitations() {
    return myInvites.length != 0
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: myInvites.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: appTheme.themeColor,
                  child: ListTile(
                    dense: true,
                    tileColor: appTheme.themeColor,
                    leading: GestureDetector(
                      onTap: () {
                        openPhoto(context, myInvites[index].inviter.profileUrl, myInvites[index].inviter.username);
                      },
                      child: CircularProfileAvatar(
                        myInvites[index].inviter.profileUrl,
                        radius: 20,
                        backgroundColor: AppTheme.getLightOrDarkModeTheme(isDark),
                        initialsText: Text(
                          getInitials(myInvites[index].inviter.username),
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: appTheme.themeColor,
                          ),
                        ),
                        borderColor: Colors.transparent,
                        elevation: 0.0,
                        foregroundColor: Colors.transparent,
                        cacheImage: true,
                        showInitialTextAbovePicture: false,
                      ),
                    ),
                    title: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: myInvites[index].inviter.username,
                          style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.getLightOrDarkModeTheme(isDark)),
                        ),
                      ]),
                    ),
                    subtitle: Text(
                      myInvites[index].isCoop ? 'is inviting you to join their cooperative game' : 'is inviting you to join their competitive game',
                      style: GoogleFonts.roboto(color: AppTheme.getLightOrDarkModeTheme(isDark)),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            icon: Icon(
                              LineIcons.check,
                              color: AppTheme.getLightOrDarkModeTheme(isDark),
                            ),
                            onPressed: () {
                              showAcceptInviteDialog(myInvites[index], context);
                            }),
                        Transform.rotate(
                          angle: -math.pi / 4,
                          child: IconButton(
                              icon: Icon(
                                LineIcons.plus,
                                color: AppTheme.getLightOrDarkModeTheme(isDark),
                              ),
                              onPressed: () {
                                showRefuseInviteDialog(myInvites[index], context);
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            })
        : buildNoInvitations();
  }

  Widget buildJoining(BuildContext context) {
    return isLoading
        ? Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.25),
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
                Center(
                  child: TextButton(
                      onPressed: () {
                        toggleIsViewingInvitations();
                      },
                      child: Text(
                        isViewingInvitations ? 'see your ongoing games' : 'see your invitations(${myInvites.length})',
                        style: GoogleFonts.quicksand(color: appTheme.themeColor, fontWeight: FontWeight.bold),
                      )),
                ),
                isViewingInvitations
                    ? Container(
                        child: buildViewInvitations(),
                      )
                    : Flexible(
                        child: StreamBuilder(
                          stream: multiplayerProvider.getOngoingGames(user),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data == null) {
                              return Container();
                            }
                            processOngoingGamesStreamData(snapshot);
                            return Column(
                              children: [
                                Container(
                                    child: onGoingGames.length == 0
                                        ? buildNoGames()
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: onGoingGames.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              return Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Container(
                                                  color: appTheme.themeColor,
                                                  child: ListTile(
                                                    onTap: () {
                                                      if (onGoingGames[index].hasFinished) {
                                                        deleteExpiredGame(onGoingGames[index]);
                                                      } else {
                                                        showJoiningGameFromListDialog(onGoingGames[index], context);
                                                      }
                                                    },
                                                    dense: true,
                                                    tileColor: appTheme.themeColor,
                                                    leading: GestureDetector(
                                                      onTap: () {
                                                        openPhoto(
                                                            context,
                                                            onGoingGames[index].players.indexWhere((element) => element.id != user.id) == -1
                                                                ? user.profileUrl
                                                                : onGoingGames[index]
                                                                    .players[onGoingGames[index].players.indexWhere((element) => element.id != user.id)]
                                                                    .profileUrl,
                                                            onGoingGames[index].players.indexWhere((element) => element.id != user.id) == -1
                                                                ? user.username
                                                                : onGoingGames[index].players[onGoingGames[index].players.indexWhere((element) => element.id != user.id)].username);
                                                      },
                                                      child: CircularProfileAvatar(
                                                        onGoingGames[index].players.indexWhere((element) => element.id != user.id) == -1
                                                            ? user.profileUrl
                                                            : onGoingGames[index].players[onGoingGames[index].players.indexWhere((element) => element.id != user.id)].profileUrl,
                                                        radius: 20,
                                                        backgroundColor: AppTheme.getLightOrDarkModeTheme(isDark),
                                                        initialsText: Text(
                                                          getInitials(onGoingGames[index].players.indexWhere((element) => element.id != user.id) == -1
                                                              ? user.username
                                                              : onGoingGames[index].players[onGoingGames[index].players.indexWhere((element) => element.id != user.id)].username),
                                                          style: GoogleFonts.quicksand(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 14,
                                                            color: appTheme.themeColor,
                                                          ),
                                                        ),
                                                        borderColor: Colors.transparent,
                                                        elevation: 0.0,
                                                        foregroundColor: Colors.transparent,
                                                        cacheImage: true,
                                                        showInitialTextAbovePicture: false,
                                                      ),
                                                    ),
                                                    title: onGoingGames[index].players.indexWhere((element) => element.id != user.id) == -1
                                                        ? Text(
                                                            onGoingGames[index].hasInvited && onGoingGames[index].invitationStatus == 3
                                                                ? 'waiting for ${onGoingGames[index].invitee.username}'
                                                                : onGoingGames[index].hasInvited && onGoingGames[index].invitationStatus == 0
                                                                    ? '${onGoingGames[index].invitee.username} declined your invitation'
                                                                    : 'only you',
                                                            style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.getLightOrDarkModeTheme(isDark)),
                                                          )
                                                        : Text(
                                                            onGoingGames[index].players[onGoingGames[index].players.indexWhere((element) => element.id != user.id)].username +
                                                                ' and you',
                                                            style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.getLightOrDarkModeTheme(isDark)),
                                                          ),
                                                    subtitle: Text(
                                                      formatDateTime(onGoingGames[index].lastPlayedOn),
                                                      style: GoogleFonts.roboto(color: AppTheme.getLightOrDarkModeTheme(isDark)),
                                                    ),
                                                    trailing: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        IconButton(
                                                            icon: Icon(onGoingGames[index].isCooperative ? LineIcons.handshake : LineIcons.helpingHands,
                                                                color: AppTheme.getLightOrDarkModeTheme(isDark)),
                                                            onPressed: () {}),
                                                        onGoingGames[index].hostId == user.id
                                                            ? IconButton(
                                                                icon: Icon(LineIcons.trash, color: AppTheme.getLightOrDarkModeTheme(isDark)),
                                                                onPressed: () {
                                                                  showDeleteGameDialog(onGoingGames[index], context);
                                                                })
                                                            : IconButton(
                                                                icon: Icon(LineIcons.unlink, color: AppTheme.getLightOrDarkModeTheme(isDark)),
                                                                onPressed: () {
                                                                  showLeaveGameDialog(onGoingGames[index], context);
                                                                }),
                                                      ],
                                                    ),
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
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.25),
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
                            style: GoogleFonts.quicksand(color: appTheme.themeColor, fontWeight: FontWeight.bold, fontSize: 25),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'this is your game id. your friend will use it to join your game. the game will start as soon as your friend joins',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(
                              color: appTheme.themeColor,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextButton.icon(
                                  onPressed: () {
                                    share();
                                  },
                                  icon: Icon(
                                    LineIcons.share,
                                    color: appTheme.themeColor,
                                  ),
                                  label: Text(
                                    'share game id',
                                    style: GoogleFonts.quicksand(color: appTheme.themeColor),
                                  )),
                            ),
                            !hasInvited
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: TextButton.icon(
                                        onPressed: () {
                                          showInviteFriendsDialog(context);
                                        },
                                        icon: Icon(
                                          LineIcons.userPlus,
                                          color: appTheme.themeColor,
                                        ),
                                        label: Text(
                                          'invite friend',
                                          style: GoogleFonts.quicksand(color: appTheme.themeColor),
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
                      stream: multiplayerProvider.getStartingGame(currentGame.id),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData || snapshot.data == null) {
                          return Container();
                        }
                        processStartingGameStreamData(snapshot, context);
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: LinearProgressIndicator(
                                backgroundColor: AppTheme.getLightOrDarkModeTheme(isDark),
                                valueColor: AlwaysStoppedAnimation<Color>(appTheme.themeColor),
                                minHeight: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'game options',
                                style: GoogleFonts.roboto(color: appTheme.themeColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    'cooperative',
                                    style: GoogleFonts.quicksand(
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
                                    style: GoogleFonts.quicksand(
                                        color: appTheme.themeColor,
                                        fontSize: currentGame.isCompetitive ? 16 : 14,
                                        fontWeight: currentGame.isCompetitive ? FontWeight.bold : FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Wrap(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    child: ChoiceChip(
                                      avatar: Icon(
                                        LineIcons.dice,
                                        color: AppTheme.getLightOrDarkModeTheme(isDark),
                                      ),
                                      label: Text('random'),
                                      labelStyle: GoogleFonts.roboto(color: AppTheme.getLightOrDarkModeTheme(isDark), fontWeight: FontWeight.bold),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    child: ChoiceChip(
                                      avatar: Icon(
                                        LineIcons.seedling,
                                        color: AppTheme.getLightOrDarkModeTheme(isDark),
                                      ),
                                      label: Text('spring'),
                                      labelStyle: GoogleFonts.quicksand(color: AppTheme.getLightOrDarkModeTheme(isDark), fontWeight: FontWeight.bold),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    child: ChoiceChip(
                                      avatar: Icon(
                                        LineIcons.sunAlt,
                                        color: AppTheme.getLightOrDarkModeTheme(isDark),
                                      ),
                                      label: Text('summer'),
                                      labelStyle: GoogleFonts.quicksand(color: AppTheme.getLightOrDarkModeTheme(isDark), fontWeight: FontWeight.bold),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    child: ChoiceChip(
                                      avatar: Icon(
                                        LineIcons.leaf,
                                        color: AppTheme.getLightOrDarkModeTheme(isDark),
                                      ),
                                      label: Text('fall'),
                                      labelStyle: GoogleFonts.quicksand(color: AppTheme.getLightOrDarkModeTheme(isDark), fontWeight: FontWeight.bold),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    child: ChoiceChip(
                                      avatar: Icon(
                                        LineIcons.snowflake,
                                        color: AppTheme.getLightOrDarkModeTheme(isDark),
                                      ),
                                      label: Text('winter'),
                                      labelStyle: GoogleFonts.quicksand(color: AppTheme.getLightOrDarkModeTheme(isDark), fontWeight: FontWeight.bold),
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
      child: StreamBuilder(
          stream: multiplayerProvider.getInvites(user.id),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: AppTheme.getLightOrDarkModeTheme(isDark),
                child: LoadingWidget(
                  appTheme: appTheme,
                  isDark: isDark,
                ),
              );
            }
            loadInWidgets();
            processInvitesStreamData(snapshot);
            return Scaffold(
              key: scaffoldKey,
              appBar: AppBar(
                backgroundColor: AppTheme.getLightOrDarkModeTheme(isDark),
                elevation: 0,
                title: Text(
                  'multiplayer',
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
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
                color: AppTheme.getLightOrDarkModeTheme(isDark),
                child: SafeArea(
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 500),
                    opacity: widgetOpacity,
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
          }),
    );
  }
}
