import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sudoku/src/components/choice_dialog.dart';
import 'package:sudoku/src/models/difficulty.dart';
import 'package:sudoku/src/models/invite.dart';
import 'package:sudoku/src/models/multiplayer.dart';
import 'package:sudoku/src/models/theme.dart';
import 'package:sudoku/src/models/user.dart';
import 'package:sudoku/src/providers/database_provider.dart';
import 'package:sudoku/src/providers/multiplayer_provider.dart';
import 'package:sudoku/src/providers/theme_provider.dart';
import 'package:sudoku/src/providers/user_state_update_provider.dart';
import 'package:sudoku/src/screens/friends_screen/friends_screen.dart';
import 'package:sudoku/src/screens/home_screen/home_screen.dart';
import 'package:sudoku/src/screens/multiplayer_game_screen/multiplayer_game_screen.dart';
import 'package:wakelock/wakelock.dart';
import 'multiplayer_lobby_screen_ui.dart';

class MultiplayerLobbyScreen extends StatefulWidget {
  final Users user;

  MultiplayerLobbyScreen({@required this.user});

  @override
  MultiplayerLobbyScreenView createState() => MultiplayerLobbyScreenView();
}

abstract class MultiplayerLobbyScreenState extends State<MultiplayerLobbyScreen> with TickerProviderStateMixin {
  String searchTerm = '';

  Users user;
  bool isDark;

  bool isLoading = false;
  bool isHosting = false;
  bool isJoining = true;
  bool hasInvited = false;
  bool isViewingInvitations = false;
  String joiningGameId;
  String preferedPattern;

  List<MultiplayerGame> onGoingGames = [];
  List<Users> foundUsers = [];
  List<Users> allUsers = [];
  List<Invite> myInvites = [];

  MultiplayerGame currentGame;

  AppTheme appTheme;

  ThemeProvider themeProvider = ThemeProvider();
  final formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  MultiplayerProvider multiplayerProvider = MultiplayerProvider();
  DatabaseProvider databaseProvider = DatabaseProvider();
  UserStateUpdateProvider userStateUpdateProvider = UserStateUpdateProvider();

  void initVariables() {
    this.user = widget.user;
    this.isDark = widget.user.isDark;
    this.preferedPattern = this.user.preferedPattern;
    this.appTheme = this.themeProvider.getCurrentAppTheme(this.user);
  }

  @override
  void initState() {
    initVariables();
    super.initState();
  }

  void toggleIsViewingInvitations() {
    setState(() {
      this.isViewingInvitations = !isViewingInvitations;
    });
  }

  void toggleLoading() {
    setState(() {
      this.isLoading = !isLoading;
    });
  }

  void host() {
    if (!isHosting) {
      setState(() {
        isHosting = !isHosting;
        isJoining = !isJoining;
      });

      this.createGame();
      this.enableWakeLock();
    }
  }

  void join() {
    if (!isJoining) {
      if (!hasInvited) {
        this.multiplayerProvider.deleteGame(this.currentGame.id);
      }
      this.currentGame = null;
      this.hasInvited = false;

      setState(() {
        isJoining = !isJoining;
        isHosting = !isHosting;
      });
    }
    this.disableWakeLock();
  }

  Future<void> createGame() async {
    this.toggleLoading();
    this.currentGame = await multiplayerProvider.createGame(this.user);
    this.toggleLoading();
    FlutterClipboard.copy(this.currentGame.id).then((value) => this.showCopiedSnackBar());
  }

  void processInvitesStreamData(AsyncSnapshot snapshot) {
    this.myInvites = [];
    snapshot.data.docs.forEach((invite) {
      myInvites.add(Invite.fromJson(invite.data()));
    });
  }

  void processOngoingGamesStreamData(AsyncSnapshot snapshot) {
    this.onGoingGames = [];
    List<MultiplayerGame> tempArray = [];
    snapshot.data.docs.forEach((game) {
      tempArray.add(MultiplayerGame.fromJson(game.data()));
      if (tempArray[tempArray.length - 1].players.where((element) => element.id == this.user.id).toList().length > 0) {
        this.onGoingGames.add(tempArray[tempArray.length - 1]);
      }
    });
  }

  void processStartingGameStreamData(AsyncSnapshot snapshot, BuildContext context) async {
    if (this.currentGame.invitationStatus == 3 && snapshot.data.docs[0].data()['invitationStatus'] == 0) {
      // show player declined snackbar
      showPlayerDeclinedSnackbar(this.currentGame.invitee);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(() {
          this.hasInvited = false;
        });
      });
      this.currentGame.hasInvited = false;
      this.currentGame.invitee = null;
      this.currentGame.invitationStatus = 2;
      await this.multiplayerProvider.updateGameSettings(this.currentGame);
    }
    this.currentGame = MultiplayerGame.fromJson(snapshot.data.docs[0].data());
    this.hasGameStarted(currentGame, context);
  }

  void hasGameStarted(MultiplayerGame currentGame, BuildContext context) {
    if (currentGame.players.length > 1) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        this.goToMultiplayerGameScreen(context);
      });
    }
  }

  void showPlayerDeclinedSnackbar(Users user) {
    Future.delayed(Duration(seconds: 1), () {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: appTheme.themeColor,
          content: Text(
            '${user.username} has declined your invitation',
            style: GoogleFonts.lato(color: AppTheme.getLightOrDarkModeTheme(isDark)),
            textAlign: TextAlign.start,
          )));
    });
  }

  String getInitials(String username) {
    List<String> names = username.split(" ");
    String initials = "";
    int numWords = names.length;

    if (numWords < names.length) {
      numWords = names.length;
    }
    for (var i = 0; i < numWords; i++) {
      initials += '${names[i][0]}'.toUpperCase();
    }
    return initials;
  }

  void submitAndJoinGame(BuildContext context) {
    if (formKey.currentState.validate()) {
      joinGameWithCode(context);
    }
  }

  joinGameWithCode(BuildContext context) async {
    this.toggleLoading();
    if (await this.multiplayerProvider.checkIfGameExists(this.joiningGameId, this.user)) {
      this.currentGame = await this.multiplayerProvider.joinGame(this.joiningGameId, this.user);
      this.goToMultiplayerGameScreen(context);
    } else {
      // game with that id does not exist
      this.toggleLoading();
      this.showNoSuchGameSnackBar();
    }
  }

  joinGameFromList(MultiplayerGame game) async {
    this.toggleLoading();
    if (await this.multiplayerProvider.checkIfGameExists(game.id, this.user)) {
      this.currentGame = await this.multiplayerProvider.joinGame(game.id, this.user);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        this.goToMultiplayerGameScreen(context);
      });
    } else {
      // game with that id does not exist
      this.toggleLoading();
      this.showNoSuchGameSnackBar();
    }
  }

  joinGameFromInvite(String gameId) async {
    this.toggleLoading();
    if (await this.multiplayerProvider.checkIfGameExists(gameId, this.user)) {
      this.currentGame = await this.multiplayerProvider.joinGame(gameId, this.user);
      await multiplayerProvider.refuseInviteByGameId(gameId, true);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        this.goToMultiplayerGameScreen(context);
      });
    } else {
      // game with that id does not exist
      this.toggleLoading();
      this.showSomethingWrongSnackBar();
    }
  }

  void setCompetitiveSetting(bool value) async {
    if (value) {
      setState(() {
        this.currentGame.isCompetitive = true;
        this.currentGame.isCooperative = false;
      });
      this.multiplayerProvider.updateGameSettings(this.currentGame);
    } else {
      setState(() {
        this.currentGame.isCompetitive = false;
        this.currentGame.isCooperative = true;
      });
      this.multiplayerProvider.updateGameSettings(this.currentGame);
    }
  }

  Future<void> setBoardPatterns(String pattern) async {
    switch (pattern) {
      case 'Random':
        setState(() {
          this.preferedPattern = 'Random';
        });
        this.currentGame.level = await Difficulty.regenerateLevel(currentGame.difficulty, 400, preferedPattern);
        await this.multiplayerProvider.updateGameSettings(this.currentGame);
        break;
      case 'spring':
        setState(() {
          this.preferedPattern = 'spring';
        });
        this.currentGame.level = await Difficulty.regenerateLevel(currentGame.difficulty, 400, preferedPattern);
        await this.multiplayerProvider.updateGameSettings(this.currentGame);
        break;
      case 'summer':
        setState(() {
          this.preferedPattern = 'summer';
        });
        this.currentGame.level = await Difficulty.regenerateLevel(currentGame.difficulty, 400, preferedPattern);
        await this.multiplayerProvider.updateGameSettings(this.currentGame);
        break;
      case 'fall':
        setState(() {
          this.preferedPattern = 'fall';
        });
        this.currentGame.level = await Difficulty.regenerateLevel(currentGame.difficulty, 400, preferedPattern);
        await this.multiplayerProvider.updateGameSettings(this.currentGame);
        break;
      case 'winter':
        setState(() {
          this.preferedPattern = 'winter';
        });
        this.currentGame.level = await Difficulty.regenerateLevel(currentGame.difficulty, 400, preferedPattern);
        await this.multiplayerProvider.updateGameSettings(this.currentGame);
        break;
    }
  }

  showCopiedSnackBar() {
    Future.delayed(Duration(seconds: 1), () {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: appTheme.themeColor,
          content: Text(
            'game id copied to clipbaord',
            style: GoogleFonts.lato(color: AppTheme.getLightOrDarkModeTheme(isDark)),
            textAlign: TextAlign.start,
          )));
    });
  }

  showNoSuchGameSnackBar() {
    Future.delayed(Duration(seconds: 1), () {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: appTheme.themeColor,
          content: Text(
            'a game with that id was not found',
            style: GoogleFonts.lato(color: AppTheme.getLightOrDarkModeTheme(isDark)),
            textAlign: TextAlign.start,
          )));
    });
  }

  showSomethingWrongSnackBar() {
    Future.delayed(Duration(seconds: 1), () {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: appTheme.themeColor,
          content: Text(
            'something went wrong',
            style: GoogleFonts.lato(color: AppTheme.getLightOrDarkModeTheme(isDark)),
            textAlign: TextAlign.start,
          )));
    });
  }

  void enableWakeLock() {
    Wakelock.enable();
  }

  void disableWakeLock() {
    Wakelock.disable();
  }

  void goToMultiplayerGameScreen(BuildContext contexts) async {
    disableWakeLock();
    Navigator.of(contexts).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) {
        return MultiplayerGameScreenScreen(
          currentGame: this.currentGame,
          user: this.user,
          isSavedGame: this.currentGame.elapsedTime != null,
        );
      },
    ));
  }

  void gotoFriendsScreen() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) {
        return FriendsScreen(
          user: this.user,
        );
      },
    ));
  }

  void goToHomeScreen() async {
    this.toggleLoading();
    this.disableWakeLock();
    if (this.isHosting) {
      if (!hasInvited) {
        await this.multiplayerProvider.deleteGame(this.currentGame.id);
      }
    }

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) {
        return HomeScreen(user: this.user);
      },
    ));
  }

  String formatDateTime(String datetime) {
    return Jiffy(datetime).fromNow();
  }

  void share() {
    Share.share('Hi! use this code to join to my game on Sudoku with AISA: \n\n${this.currentGame.id}');
  }

  void inviteFriend(Users friend) async {
    setState(() {
      this.hasInvited = true;
    });
    await this.multiplayerProvider.sendInvite(friend, this.user, this.currentGame);
    // show snackbar
    this.showInviteSentSnackBar(friend);
  }

  void processFindFriendsData(AsyncSnapshot snapshot) {
    this.allUsers = [];
    this.foundUsers = [];

    snapshot.data.docs.forEach((user) {
      this.allUsers.add(Users.fromJson(user.data()));
    });

    if (searchTerm != '') {
      this.allUsers.forEach((user) {
        if (user.username.toLowerCase().startsWith(searchTerm.toLowerCase()) || user.username.toLowerCase().contains(searchTerm.toLowerCase())) {
          if (user.id != this.user.id) {
            if (user.isFriendly || isFriend(user)) this.foundUsers.add(user);
          }
        }
      });
    }
  }

  bool isFriend(Users user) {
    return user.friends.indexWhere((user) => user.id == this.user.id) != -1;
  }

  showInviteSentSnackBar(Users friend) {
    Future.delayed(Duration(seconds: 1), () {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: appTheme.themeColor,
          content: Text(
            'an invite has been sent to ${friend.username}',
            style: GoogleFonts.lato(color: AppTheme.getLightOrDarkModeTheme(isDark)),
            textAlign: TextAlign.start,
          )));
    });
  }

  showInviteDeniedSnackBar(Users friend) {
    Future.delayed(Duration(seconds: 1), () {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: appTheme.themeColor,
          content: Text(
            'you have declined ${friend.username}\'s invite',
            style: GoogleFonts.lato(color: AppTheme.getLightOrDarkModeTheme(isDark)),
            textAlign: TextAlign.start,
          )));
    });
  }

  void refuseInvite(Invite invite, bool accepted) async {
    await this.multiplayerProvider.refuseInviteByGameId(invite.gameId, accepted);
    this.showInviteDeniedSnackBar(invite.inviter);
  }

  void acceptInvite(Invite invite) async {
    await this.joinGameFromInvite(invite.gameId);
  }

  showAcceptInviteDialog(Invite invite, BuildContext context) {
    return showChoiceDialog(
        context: context,
        title: 'join this game with ${invite.inviter.username}?',
        contentMessage: '',
        yesMessage: 'let\'s go!',
        noMessage: 'on second thought, nah',
        isDark: this.isDark,
        appTheme: appTheme,
        onYes: () {
          Navigator.pop(context);
          this.acceptInvite(invite);
        },
        onNo: () {
          Navigator.pop(context);
        });

    // return showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         backgroundColor: AppTheme.getLightOrDarkModeTheme(isDark),
    //         title: Text('join this game with ${invite.inviter.username}?', textAlign: TextAlign.center, style: GoogleFonts.lato(color: isDark ? Colors.white : Colors.grey[900])),
    //         actions: [
    //           Column(
    //             crossAxisAlignment: CrossAxisAlignment.end,
    //             children: [
    //               TextButton(
    //                   onPressed: () {
    //                     Navigator.pop(context);
    //                   },
    //                   child: Text('on second thought, nah', textAlign: TextAlign.end, style: GoogleFonts.lato(color: isDark ? Colors.white : Colors.grey[900]))),
    //               TextButton(
    //                 onPressed: () {
    //                   Navigator.pop(context);
    //                   this.acceptInvite(invite);
    //                 },
    //                 child: Text(
    //                   'let\'s go!',
    //                   textAlign: TextAlign.end,
    //                   style: GoogleFonts.lato(color: appTheme.themeColor),
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ],
    //       );
    //     });
  }

  showRefuseInviteDialog(Invite invite, BuildContext context) {
    return showChoiceDialog(
        context: context,
        title: 'refuse ${invite.inviter.username}\'s invite?',
        contentMessage: '',
        yesMessage: 'yep. not interested',
        noMessage: 'oops!',
        isDark: this.isDark,
        appTheme: appTheme,
        onYes: () {
          Navigator.pop(context);
          this.refuseInvite(invite, false);
        },
        onNo: () {
          Navigator.pop(context);
        });

    // return showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         backgroundColor: AppTheme.getLightOrDarkModeTheme(isDark),
    //         title: Text('refuse ${invite.inviter.username}\'s invite?', textAlign: TextAlign.center, style: GoogleFonts.lato(color: isDark ? Colors.white : Colors.grey[900])),
    //         actions: [
    //           Column(
    //             crossAxisAlignment: CrossAxisAlignment.end,
    //             children: [
    //               TextButton(
    //                   onPressed: () {
    //                     Navigator.pop(context);
    //                   },
    //                   child: Text('oops!', textAlign: TextAlign.end, style: GoogleFonts.lato(color: isDark ? Colors.white : Colors.grey[900]))),
    //               TextButton(
    //                 onPressed: () {
    //                   Navigator.pop(context);
    //                   this.refuseInvite(invite, false);
    //                 },
    //                 child: Text(
    //                   'yep. not interested',
    //                   textAlign: TextAlign.end,
    //                   style: GoogleFonts.lato(color: appTheme.themeColor),
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ],
    //       );
    //     });
  }

  showInviteFriendsDialog(BuildContext context) {
    searchTerm = '';
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              backgroundColor: AppTheme.getLightOrDarkModeTheme(isDark),
              title: Text('select a friend', textAlign: TextAlign.center, style: GoogleFonts.lato(color: isDark ? Colors.white : Colors.grey[900])),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                        key: formKey,
                        child: Row(
                          children: [
                            Expanded(
                                child: TextFormField(
                              autofocus: true,
                              cursorColor: appTheme.themeColor,
                              keyboardType: TextInputType.text,
                              style: GoogleFonts.lato(color: appTheme.themeColor),
                              decoration: InputDecoration(
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: appTheme.themeColor)),
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: appTheme.themeColor)),
                                  hintText: 'enter a username',
                                  hintStyle: GoogleFonts.lato(color: appTheme.themeColor)),
                              onChanged: (value) {
                                setState(() {
                                  searchTerm = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'please enter a username';
                                }
                                return null;
                              },
                            )),
                          ],
                        )),
                  ),
                  Flexible(
                      child: StreamBuilder(
                    stream: this.databaseProvider.getUsers(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (!snapshot.hasData || snapshot.data == null) {
                        return Container();
                      }
                      processFindFriendsData(snapshot);
                      if (searchTerm != '' && searchTerm != user.username && foundUsers.length == 0) {
                        return Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height * 0.5,
                                child: Center(
                                  child: Text(
                                    'no results found for $searchTerm',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lato(color: appTheme.themeColor),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      }
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.9,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                            itemCount: foundUsers.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                onTap: () {
                                  Navigator.pop(context);
                                  inviteFriend(foundUsers[index]);
                                },
                                dense: true,
                                tileColor: appTheme.themeColor,
                                leading: CircularProfileAvatar(
                                  foundUsers[index].profileUrl,
                                  radius: 20,
                                  backgroundColor: AppTheme.getLightOrDarkModeTheme(isDark),
                                  initialsText: Text(
                                    getInitials(foundUsers[index].username),
                                    style: GoogleFonts.lato(
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
                                title: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    foundUsers[index].username,
                                    style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.getLightOrDarkModeTheme(isDark)),
                                  ),
                                ),
                                // subtitle: Text(
                                //   // check if friendly
                                //   'you and ${foundUsers[index].username} are friends',
                                //   style: GoogleFonts.lato(
                                //     color: isDark
                                //         ? Colors.grey[900]
                                //         : Colors.white,
                                //   ),
                                // ),
                                // trailing: IconButton(
                                //   icon: Icon(
                                //     LineIcons.userPlus,
                                //     color: isDark
                                //         ? Colors.grey[900]
                                //         : Colors.white,
                                //   ),
                                //   onPressed: () {},
                                // ),
                              );
                            }),
                      );
                    },
                  ))
                ],
              ),
            );
          });
        });
  }

  showJoiningGameFromListDialog(MultiplayerGame game, BuildContext context) {
    return showChoiceDialog(
        context: context,
        title: game.players.indexWhere((element) => element.id != user.id) == -1
            ? 'rejoing this game?'
            : 'rejoin this game with ' + game.players[game.players.indexWhere((element) => element.id != user.id)].username + '?',
        contentMessage: '',
        yesMessage: 'yes please',
        noMessage: 'oops!',
        isDark: this.isDark,
        appTheme: appTheme,
        onYes: () {
          Navigator.pop(context);
          this.joinGameFromList(game);
        },
        onNo: () {
          Navigator.pop(context);
        });

    // return showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         backgroundColor: AppTheme.getLightOrDarkModeTheme(isDark),
    //         title: Text(
    //             game.players.indexWhere((element) => element.id != user.id) == -1
    //                 ? 'rejoing this game?'
    //                 : 'rejoin this game with ' + game.players[game.players.indexWhere((element) => element.id != user.id)].username + '?',
    //             textAlign: TextAlign.center,
    //             style: GoogleFonts.lato(color: isDark ? Colors.white : Colors.grey[900])),
    //         actions: [
    //           Column(
    //             crossAxisAlignment: CrossAxisAlignment.end,
    //             children: [
    //               TextButton(
    //                   onPressed: () {
    //                     Navigator.pop(context);
    //                   },
    //                   child: Text('oops!', textAlign: TextAlign.end, style: GoogleFonts.lato(color: isDark ? Colors.white : Colors.grey[900]))),
    //               TextButton(
    //                 onPressed: () {
    //                   Navigator.pop(context);
    //                   this.joinGameFromList(game);
    //                 },
    //                 child: Text(
    //                   'yes please',
    //                   textAlign: TextAlign.end,
    //                   style: GoogleFonts.lato(color: appTheme.themeColor),
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ],
    //       );
    //     });
  }

  showDeleteGameDialog(MultiplayerGame game, BuildContext context) {
    return showChoiceDialog(
        context: context,
        title: game.players.indexWhere((element) => element.id != user.id) == -1
            ? 'end game?'
            : 'end this game with ' + game.players[game.players.indexWhere((element) => element.id != user.id)].username + '?',
        contentMessage: '',
        yesMessage: 'mmhm, end it',
        noMessage: 'oops!',
        isDark: this.isDark,
        appTheme: appTheme,
        onYes: () {
          Navigator.pop(context);
          this.multiplayerProvider.deleteGame(game.id);
        },
        onNo: () {
          Navigator.pop(context);
        });

    // return showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         backgroundColor: AppTheme.getLightOrDarkModeTheme(isDark),
    //         title: Text(
    //             game.players.indexWhere((element) => element.id != user.id) == -1
    //                 ? 'end game?'
    //                 : 'end this game with ' + game.players[game.players.indexWhere((element) => element.id != user.id)].username + '?',
    //             textAlign: TextAlign.center,
    //             style: GoogleFonts.lato(color: isDark ? Colors.white : Colors.grey[900])),
    //         actions: [
    //           Column(
    //             crossAxisAlignment: CrossAxisAlignment.end,
    //             children: [
    //               TextButton(
    //                   onPressed: () {
    //                     Navigator.pop(context);
    //                   },
    //                   child: Text('oops!', textAlign: TextAlign.end, style: GoogleFonts.lato(color: isDark ? Colors.white : Colors.grey[900]))),
    //               TextButton(
    //                 onPressed: () {
    //                   Navigator.pop(context);
    //                   this.multiplayerProvider.deleteGame(game.id);
    //                 },
    //                 child: Text(
    //                   'mmhm, end it',
    //                   textAlign: TextAlign.end,
    //                   style: GoogleFonts.lato(color: appTheme.themeColor),
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ],
    //       );
    //     });
  }

  showLeaveGameDialog(MultiplayerGame game, BuildContext context) {
    return showChoiceDialog(
        context: context,
        title: 'leave this game with ' + game.players[game.players.indexWhere((element) => element.id != user.id)].username + '?',
        contentMessage: '',
        yesMessage: 'yes, I want to leave',
        noMessage: 'oops!',
        isDark: this.isDark,
        appTheme: appTheme,
        onYes: () {
          Navigator.pop(context);
          this.multiplayerProvider.leaveGame(game, this.user);
        },
        onNo: () {
          Navigator.pop(context);
        });

    // return showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         backgroundColor: AppTheme.getLightOrDarkModeTheme(isDark),
    //         title: Text('leave this game with ' + game.players[game.players.indexWhere((element) => element.id != user.id)].username + '?',
    //             textAlign: TextAlign.center, style: GoogleFonts.lato(color: isDark ? Colors.white : Colors.grey[900])),
    //         actions: [
    //           Column(
    //             crossAxisAlignment: CrossAxisAlignment.end,
    //             children: [
    //               TextButton(
    //                   onPressed: () {
    //                     Navigator.pop(context);
    //                   },
    //                   child: Text('oops!', textAlign: TextAlign.end, style: GoogleFonts.lato(color: isDark ? Colors.white : Colors.grey[900]))),
    //               TextButton(
    //                 onPressed: () {
    //                   Navigator.pop(context);
    //                   this.multiplayerProvider.leaveGame(game, this.user);
    //                 },
    //                 child: Text(
    //                   'yes, I want to leave',
    //                   textAlign: TextAlign.end,
    //                   style: GoogleFonts.lato(color: appTheme.themeColor),
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ],
    //       );
    //     });
  }
}
