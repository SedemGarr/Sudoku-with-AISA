import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sudoku/src/providers/database_provider.dart';
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

  Future<void> deleteAccount() {
    // delete photo in storage
    // delete document
    // delete auth
    // sign out

    return null;
  }
}
