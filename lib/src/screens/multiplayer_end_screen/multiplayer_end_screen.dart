import 'package:flutter/material.dart';
import 'multiplayer_end_screen_ui.dart';

class MultiplayerEndScreen extends StatefulWidget {
  @override
  MultiplayerEndScreenView createState() => MultiplayerEndScreenView();
}

abstract class MultiplayerEndScreenState extends State<MultiplayerEndScreen>
    with TickerProviderStateMixin {}
