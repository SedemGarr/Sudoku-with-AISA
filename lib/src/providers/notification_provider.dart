import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sudoku/src/models/user.dart';
import 'package:sudoku/src/providers/user_state_update_provider.dart';

class PushNotificationProvider {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  void initialiseFirebaseMessaging() async {
    // firebaseMessaging.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     print('on message: $message');
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     print('on message: $message');
    //   },
    //   onLaunch: (Map<String, dynamic> message) async {
    //     print('on message: $message');
    //   },
    // );
  }

  saveDeviceToken(Users user) async {
    String token = await firebaseMessaging.getToken();

    if (!user.tokens.contains(token)) {
      UserStateUpdateProvider userStateUpdateProvider =
          UserStateUpdateProvider();
      user.tokens.add(token);
      await userStateUpdateProvider.updateUser(user);
    }
  }
}
