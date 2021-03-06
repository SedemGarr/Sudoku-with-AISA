import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sudoku/src/components/choice_dialog.dart';
import 'package:sudoku/src/components/photo_viewer.dart';
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

abstract class FriendsScreenState extends State<FriendsScreen> with TickerProviderStateMixin {
  String searchTerm = '';

  bool isDark;
  bool isSearching;
  bool isViewingFriends;
  bool isViewingInvites;

  Users user;
  AppTheme appTheme;

  double widgetOpacity = 0;

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

  void loadInWidgets() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        this.widgetOpacity = 1;
      });
    });
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

  void openPhoto(BuildContext context, String profileUrl, String username) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) {
        return ViewPhotoWidget(
          photoUrl: profileUrl,
          user: this.user,
          appTheme: this.appTheme,
          username: username,
        );
      },
    ));
  }

  void processFindUserData(AsyncSnapshot snapshot) {
    this.allUsers = [];
    this.foundUsers = [];

    snapshot.data.docs.forEach((user) {
      this.allUsers.add(Users.fromJson(user.data()));
    });

    if (searchTerm != '') {
      this.allUsers.forEach((user) {
        if (user.username.toLowerCase().startsWith(searchTerm.toLowerCase()) || user.username.toLowerCase().contains(searchTerm.toLowerCase())) {
          if (user.id != this.user.id) {
            this.foundUsers.add(user);
          }
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
    return this.allRequests.indexWhere((request) => request.requestee.id == friend.id && request.requester.id == this.user.id) == -1 ? false : true;
  }

  bool hasSentUserRequestPending(Users friend) {
    return this.allRequests.indexWhere((request) => request.requester.id == friend.id && request.requestee.id == this.user.id) == -1 ? false : true;
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: appTheme.themeColor,
          content: Text(
            'you and ${friend.username} are no longer friends',
            style: GoogleFonts.quicksand(color: AppTheme.getLightOrDarkModeTheme(isDark)),
            textAlign: TextAlign.start,
          )));
    });
  }

  showRequestAlreadySentToUSerSnackBar(Users friend) {
    Future.delayed(Duration(seconds: 1), () {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: appTheme.themeColor,
          content: Text(
            '${friend.username} has already sent you a request',
            style: GoogleFonts.quicksand(color: AppTheme.getLightOrDarkModeTheme(isDark)),
            textAlign: TextAlign.start,
          )));
    });
  }

  showRequestAcceptedSnackBar(Users friend) {
    Future.delayed(Duration(seconds: 1), () {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: appTheme.themeColor,
          content: Text(
            'you and ${friend.username} are now friends',
            style: GoogleFonts.quicksand(color: AppTheme.getLightOrDarkModeTheme(isDark)),
            textAlign: TextAlign.start,
          )));
    });
  }

  showRequestDeniedSnackBar(Users friend) {
    Future.delayed(Duration(seconds: 1), () {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: appTheme.themeColor,
          content: Text(
            '${friend.username}\'s request denied',
            style: GoogleFonts.quicksand(color: AppTheme.getLightOrDarkModeTheme(isDark)),
            textAlign: TextAlign.start,
          )));
    });
  }

  showRequestSentSnackBar(Users friend) {
    Future.delayed(Duration(seconds: 1), () {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: appTheme.themeColor,
          content: Text(
            'a friend request has been sent to ${friend.username}',
            style: GoogleFonts.quicksand(color: AppTheme.getLightOrDarkModeTheme(isDark)),
            textAlign: TextAlign.start,
          )));
    });
  }

  bool isFriend(int index) {
    return this.foundUsers[index].friends.indexWhere((user) => user.id == this.user.id) != -1;
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
    return showChoiceDialog(
        context: context,
        title: 'send request',
        contentMessage: 'send ${friend.username} a friend request?',
        yesMessage: 'yep!',
        noMessage: 'what if they think I\'m stalking them?',
        isDark: this.isDark,
        appTheme: appTheme,
        onYes: () {
          Navigator.pop(context);
          this.createFriendRequest(friend, this.user);
        },
        onNo: () {
          Navigator.pop(context);
        });
  }

  showAcceptRequestDialog(Request request, Users friend, BuildContext context) {
    return showChoiceDialog(
        context: context,
        title: 'accept request',
        contentMessage: 'accept ${friend.username}\'s friend request?',
        yesMessage: '👍',
        noMessage: 'oops!',
        isDark: this.isDark,
        appTheme: appTheme,
        onYes: () {
          Navigator.pop(context);
          this.acceptRequest(request, friend);
        },
        onNo: () {
          Navigator.pop(context);
        });
  }

  showDenyRequestDialog(Request request, Users friend, BuildContext context) {
    return showChoiceDialog(
        context: context,
        title: 'deny request',
        contentMessage: 'deny ${friend.username}\'s friend request?',
        yesMessage: 'yes, deny',
        noMessage: 'nah, changed my mind',
        isDark: this.isDark,
        appTheme: appTheme,
        onYes: () {
          Navigator.pop(context);
          this.denyRequest(request, friend);
        },
        onNo: () {
          Navigator.pop(context);
        });
  }

  showUnFriendDialog(Users friend, BuildContext context) {
    return showChoiceDialog(
        context: context,
        title: 'un-friend',
        contentMessage: 'had enough of ${friend.username}?',
        yesMessage: 'yes! 🙄',
        noMessage: 'oops!',
        isDark: this.isDark,
        appTheme: appTheme,
        onYes: () {
          Navigator.pop(context);
          this.unFriend(friend);
        },
        onNo: () {
          Navigator.pop(context);
        });
  }
}
