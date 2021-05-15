import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sudoku/src/models/multiplayer.dart';
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
      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      final signedInUser = FirebaseAuth.instance.currentUser;

      signedInUser.reauthenticateWithCredential(credential);

      // delete photo in storage
      await databaseProvider.deleteProfilePhoto(userToDelete);
      // delete document
      await databaseProvider.deleteUserDocument(userToDelete.id);

      // delete multiplayer games
      mpGames = await multiplayerProvider.getOngoingGamesList(userToDelete);
      mpGames.forEach((game) async {
        multiplayerProvider.deleteGame(game.id);
      });

      await signedInUser.delete();

      // clear user locally
      await localStorageProvider.clearUser();
    }
  }
}
