import 'package:flutter/material.dart';
import 'multiplayer_end_screen.dart';

class MultiplayerEndScreenView extends MultiplayerEndScreenState {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(),
      ),
    );
  }
}
