import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sudoku/src/models/request.dart';
import 'package:sudoku/src/models/theme.dart';
import 'package:sudoku/src/models/user.dart';
import 'package:sudoku/src/providers/database_provider.dart';
import 'package:sudoku/src/providers/theme_provider.dart';
import 'package:sudoku/src/screens/multiplayer_lobby_screen/multiplayer_lobby_screen.dart';
import 'friends_screen_ui.dart';

class FriendsScreen extends StatefulWidget {
  final Users user;

  FriendsScreen({@required this.user});

  @override
  FriendsScreenView createState() => FriendsScreenView();
}

abstract class FriendsScreenState extends State<FriendsScreen>
    with TickerProviderStateMixin {
  String searchTerm = '';

  bool isDark;
  bool isSearching;
  bool isViewingFriends;
  bool isViewingInvites;

  Users user;
  AppTheme appTheme;

  List<Users> foundUsers = [];
  List<Users> allUsers = [];
  List<Request> allRequests = [];
  List<Request> myRequests = [];

  ThemeProvider themeProvider = ThemeProvider();
  DatabaseProvider databaseProvider = DatabaseProvider();
  final formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void initVariables() {
    this.user = widget.user;
    this.isDark = this.user.isDark;
    this.isSearching = true;
    this.isViewingInvites = false;
    this.isViewingFriends = false;
    this.getTheme();
  }

  @override
  void initState() {
    initVariables();
    super.initState();
  }

  void getTheme() {
    AppTheme appTheme = this.themeProvider.getCurrentAppTheme(this.user);
    setState(() {
      this.appTheme = appTheme;
    });
  }

  void search() {
    setState(() {
      this.isSearching = true;
      this.isViewingFriends = false;
    });
  }

  void viewFriends() {
    setState(() {
      this.searchTerm = '';
      this.isViewingFriends = true;
      this.isSearching = false;
    });
  }

  void processFindUserData(AsyncSnapshot snapshot) {
    this.allUsers = [];
    this.foundUsers = [];

    snapshot.data.docs.forEach((user) {
      this.allUsers.add(Users.fromJson(user.data()));
    });

    if (searchTerm != '') {
      this.allUsers.forEach((user) {
        if (user.username.toLowerCase().startsWith(searchTerm.toLowerCase()) ||
            user.username.toLowerCase().contains(searchTerm.toLowerCase()) &&
                user.id != this.user.id) {
          this.foundUsers.add(user);
        }
      });
    }
  }

  void processRequestsData(AsyncSnapshot snapshot) {
    this.allRequests = [];
    this.myRequests = [];

    if (snapshot.data != null) {
      snapshot.data.docs.forEach((request) {
        this.allRequests.add(Request.fromJson(request.data()));
        if (Request.fromJson(request.data()).requestee.id == this.user.id) {
          this.myRequests.add(Request.fromJson(request.data()));
        }
      });
    }
  }

  bool hasRequestPending(Users friend) {
    return this.allRequests.indexWhere((request) =>
                request.requestee.id == friend.id &&
                request.requester.id == this.user.id) ==
            -1
        ? false
        : true;
  }

  bool hasSentUserRequestPending(Users friend) {
    return this.allRequests.indexWhere((request) =>
                request.requester.id == friend.id &&
                request.requestee.id == this.user.id) ==
            -1
        ? false
        : true;
  }

  void createFriendRequest(Users friend, Users user) async {
    if (!await this.databaseProvider.createFriendRequest(friend, user)) {
      this.showRequestAlreadySentToUSerSnackBar(friend);
    }
    // show snackbar
    this.showRequestSentSnackBar(friend);
  }

  void acceptRequest(Request request, Users friend) async {
    await this.databaseProvider.acceptRequest(request, friend.id, this.user.id);
    this.showRequestAcceptedSnackBar(friend);
  }

  void denyRequest(Request request, Users friend) async {
    await this.databaseProvider.denyRequest(request);
    this.showRequestDeniedSnackBar(friend);
  }

  void unFriend(Users friend) async {
    await this.databaseProvider.unfriend(friend.id, this.user.id);
    this.showUnfriendedSnackBar(friend);
  }

  showUnfriendedSnackBar(Users friend) {
    Future.delayed(Duration(seconds: 1), () {
      scaffoldKey.currentState.showSnackBar(SnackBar(
          backgroundColor: appTheme.themeColor,
          content: Text(
            'you and ${friend.username} are no longer friends',
            style: GoogleFonts.lato(
                color: this.isDark ? Colors.grey[900] : Colors.white),
            textAlign: TextAlign.start,
          )));
    });
  }

  showRequestAlreadySentToUSerSnackBar(Users friend) {
    Future.delayed(Duration(seconds: 1), () {
      scaffoldKey.currentState.showSnackBar(SnackBar(
          backgroundColor: appTheme.themeColor,
          content: Text(
            '${friend.username} has already sent you a request',
            style: GoogleFonts.lato(
                color: this.isDark ? Colors.grey[900] : Colors.white),
            textAlign: TextAlign.start,
          )));
    });
  }

  showRequestAcceptedSnackBar(Users friend) {
    Future.delayed(Duration(seconds: 1), () {
      scaffoldKey.currentState.showSnackBar(SnackBar(
          backgroundColor: appTheme.themeColor,
          content: Text(
            'you and ${friend.username} are now friends',
            style: GoogleFonts.lato(
                color: this.isDark ? Colors.grey[900] : Colors.white),
            textAlign: TextAlign.start,
          )));
    });
  }

  showRequestDeniedSnackBar(Users friend) {
    Future.delayed(Duration(seconds: 1), () {
      scaffoldKey.currentState.showSnackBar(SnackBar(
          backgroundColor: appTheme.themeColor,
          content: Text(
            '${friend.username}\'s request denied',
            style: GoogleFonts.lato(
                color: this.isDark ? Colors.grey[900] : Colors.white),
            textAlign: TextAlign.start,
          )));
    });
  }

  showRequestSentSnackBar(Users friend) {
    Future.delayed(Duration(seconds: 1), () {
      scaffoldKey.currentState.showSnackBar(SnackBar(
          backgroundColor: appTheme.themeColor,
          content: Text(
            'a friend request has been sent to ${friend.username}',
            style: GoogleFonts.lato(
                color: this.isDark ? Colors.grey[900] : Colors.white),
            textAlign: TextAlign.start,
          )));
    });
  }

  bool isFriend(int index) {
    return this
            .foundUsers[index]
            .friends
            .indexWhere((user) => user.id == this.user.id) !=
        -1;
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

  void goToMultiplayerLobbyScreen() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) {
        return MultiplayerLobbyScreen(user: this.user);
      },
    ));
  }

  showSendRequestDialog(Users friend, BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            title: Text('send ${friend.username} a friend request?',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                    color: isDark ? Colors.white : Colors.grey[900])),
            actions: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('what if they think I\'m stalking them?',
                          textAlign: TextAlign.end,
                          style: GoogleFonts.lato(
                              color:
                                  isDark ? Colors.white : Colors.grey[900]))),
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      this.createFriendRequest(friend, this.user);
                    },
                    child: Text(
                      'yep!',
                      textAlign: TextAlign.end,
                      style: GoogleFonts.lato(color: appTheme.themeColor),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }

  showAcceptRequestDialog(Request request, Users friend, BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            title: Text('accept ${friend.username}\'s friend request?',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                    color: isDark ? Colors.white : Colors.grey[900])),
            actions: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('oops!',
                          textAlign: TextAlign.end,
                          style: GoogleFonts.lato(
                              color:
                                  isDark ? Colors.white : Colors.grey[900]))),
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      this.acceptRequest(request, friend);
                    },
                    child: Text(
                      '👍',
                      textAlign: TextAlign.end,
                      style: GoogleFonts.lato(color: appTheme.themeColor),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }

  showDenyRequestDialog(Request request, Users friend, BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            title: Text('deny ${friend.username}\'s friend request?',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                    color: isDark ? Colors.white : Colors.grey[900])),
            actions: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('nah, changed my mind',
                          textAlign: TextAlign.end,
                          style: GoogleFonts.lato(
                              color:
                                  isDark ? Colors.white : Colors.grey[900]))),
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      this.denyRequest(request, friend);
                    },
                    child: Text(
                      'yes, deny',
                      textAlign: TextAlign.end,
                      style: GoogleFonts.lato(color: appTheme.themeColor),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }

  showUnFriendDialog(Users friend, BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            title: Text('had enough of ${friend.username}?',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                    color: isDark ? Colors.white : Colors.grey[900])),
            actions: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('oops!',
                          textAlign: TextAlign.end,
                          style: GoogleFonts.lato(
                              color:
                                  isDark ? Colors.white : Colors.grey[900]))),
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      this.unFriend(friend);
                    },
                    child: Text(
                      'yes! 🙄',
                      textAlign: TextAlign.end,
                      style: GoogleFonts.lato(color: appTheme.themeColor),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }
}
