import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sudoku/src/models/multiplayer.dart';
import 'package:sudoku/src/models/request.dart';
import 'package:sudoku/src/models/user.dart';
import 'package:sudoku/src/providers/database_provider.dart';
import 'package:sudoku/src/providers/multiplayer_provider.dart';
import 'local_storage_provider.dart';

class AuthenticationProvider {
  final googleSignIn = GoogleSignIn();

  Future<GoogleSignInAccount> getGoogleUser() async {
    final googleUser = await googleSignIn.signIn();
    return googleUser != null ? googleUser : null;
  }

  Future<Map> signIn(GoogleSignInAccount googleUser) async {
    var res = {};

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    await FirebaseAuth.instance.signInWithCredential(credential);

    final signedInUser = FirebaseAuth.instance.currentUser;

    DatabaseProvider databaseProvider = DatabaseProvider();
    res = await databaseProvider.createUser(
        signedInUser.uid, signedInUser.displayName, signedInUser.photoURL);

    return res;
  }

  Future<void> signOut() async {
    try {
      // sign out
      await googleSignIn.disconnect();
      await FirebaseAuth.instance.signOut();
      // clear user locally
      LocalStorageProvider localStorageProvider = LocalStorageProvider();
      await localStorageProvider.clearUser();
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteAccount(Users userToDelete) async {
    DatabaseProvider databaseProvider = DatabaseProvider();
    MultiplayerProvider multiplayerProvider = MultiplayerProvider();
    LocalStorageProvider localStorageProvider = LocalStorageProvider();

    List<MultiplayerGame> mpGames;

    final googleUser = await getGoogleUser();

    if (googleUser != null) {
      final firestore = FirebaseFirestore.instance;
      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      final signedInUser = FirebaseAuth.instance.currentUser;

      signedInUser.reauthenticateWithCredential(credential);

      // delete photo in storage
      await databaseProvider.deleteProfilePhoto(userToDelete);

      //TO DO: UNFRIEND ALL FRIENDS
      await firestore.collection('user-data').get().then((value) {
        value.docs.forEach((element) async {
          if (Users.fromJson(element.data())
                  .friends
                  .indexWhere((user) => user.id == userToDelete.id) !=
              -1) {
            Users friend = Users.fromJson(element.data());
            friend.friends.removeAt(friend.friends
                .indexWhere((user) => user.id == userToDelete.id));
            await firestore
                .collection("user-data")
                .doc(element.id)
                .set(friend.toJson(), SetOptions(merge: true));
          }
        });
      });

      //TO DO: DELETE ALL INVITES
      // commented out because deleting games deletes all invites already
      // await firestore.collection('invites').get().then((value) {
      //   value.docs.forEach((element) async {
      //     if (Invite.fromJson(element.data()).inviteeId == userToDelete.id ||
      //         Invite.fromJson(element.data()).inviterId == userToDelete.id) {
      //       await FirebaseFirestore.instance
      //           .collection("invites")
      //           .doc(element.id)
      //           .delete();
      //     }
      //   });
      // });

      //TO DO: DELETE ALL REQUESTS
      await firestore.collection('requests').get().then((value) {
        value.docs.forEach((element) async {
          Request request = Request.fromJson(element.data());
          if (request.requestee.id == userToDelete.id ||
              request.requester.id == userToDelete.id) {
            await FirebaseFirestore.instance
                .collection('requests')
                .doc(request.id)
                .delete();
          }
        });
      });

      // delete multiplayer games
      mpGames = await multiplayerProvider.getOngoingGamesList(userToDelete);
      mpGames.forEach((game) async {
        multiplayerProvider.deleteGame(game.id);
      });

      // delete document
      await databaseProvider.deleteUserDocument(userToDelete.id);

      await signedInUser.delete();

      // clear user locally
      await localStorageProvider.clearUser();
    }
  }
}
