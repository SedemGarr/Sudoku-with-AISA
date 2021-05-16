import 'package:flutter/material.dart';
import 'friends_screen.dart';

class FriendsScreenView extends FriendsScreenState {
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
