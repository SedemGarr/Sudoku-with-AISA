import 'package:flutter/material.dart';
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

  ThemeProvider themeProvider = ThemeProvider();
  DatabaseProvider databaseProvider = DatabaseProvider();
  final formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void initVariables() {
    this.user = widget.user;
    this.isDark = this.user.isDark;
    this.isSearching = false;
    this.isViewingInvites = false;
    this.isViewingFriends = true;
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
}
