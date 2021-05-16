import 'package:flutter/material.dart';
import 'friends_screen_ui.dart';

class FriendsScreen extends StatefulWidget {
  @override
  FriendsScreenView createState() => FriendsScreenView();
}

abstract class FriendsScreenState extends State<FriendsScreen>
    with TickerProviderStateMixin {}
