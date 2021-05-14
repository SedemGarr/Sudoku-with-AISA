import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sudoku/src/models/stats.dart';
import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:sudoku/src/models/user.dart';
import 'package:sudoku/src/providers/local_storage_provider.dart';
import 'package:sudoku/src/providers/multiplayer_provider.dart';
import 'package:sudoku/src/providers/user_state_update_provider.dart';

class DatabaseProvider {
  final firestore = FirebaseFirestore.instance;

  Future<Map> createUser(String uid, String username, String profileUrl) async {
    Users user;

    var doc = await firestore.collection('user-data').doc(uid).get();

    if (doc.exists) {
      user = Users.fromJson(doc.data());
      // save user locally
      LocalStorageProvider localStorageProvider = LocalStorageProvider();
      await localStorageProvider.setUser(user);
      return {'user': user, 'status': 'success'};
    } else {
      // create user
      user = Users(
          freePlayDifficulty: 0,
          preferedPattern: 'Random',
          id: uid,
          username: username,
          profileUrl: profileUrl,
          level: 0,
          difficultyLevel: 0,
          audioEnabled: true,
          backupBoard: [],
          profilePath: '',
          enableWakelock: true,
          hasCompletedGame: false,
          selectedTheme: 6,
          isDark: false,
          elapsedTime: null,
          hasCompletedIntro: false,
          isFriendly: true,
          hasTrainingWheels: false,
          stats: [],
          savedBoard: [],
          savedSolvedBoard: [],
          score: 0);
      // push to firestore
      await firestore
          .collection('user-data')
          .doc(uid)
          .set(user.toJson(), SetOptions(merge: true));
      // save user locally
      LocalStorageProvider localStorageProvider = LocalStorageProvider();
      await localStorageProvider.setUser(user);
      return {'user': user, 'status': 'success'};
    }
  }

  Future<void> updateUserData(Users user) async {
    await firestore
        .collection('user-data')
        .doc(user.id)
        .set(user.toJson(), SetOptions(merge: true));
  }

  Future<Users> updateProfilePhoto(Users user, File image) async {
    if (user.profileUrl != '' && user.profilePath != '') {
      Reference oldStorageReference;
      oldStorageReference =
          FirebaseStorage.instance.ref().child(user.profilePath);
      await oldStorageReference.delete();
    }

    String storagePath = 'images/avatars/' + Path.basename(image.path);

    Reference storageReference =
        FirebaseStorage.instance.ref().child(storagePath);

    await storageReference.putFile(image);

    // assign image link
    user.profileUrl = await storageReference.getDownloadURL();
    user.profilePath = storagePath;

    // update user
    UserStateUpdateProvider userStateUpdateProvider = UserStateUpdateProvider();
    await userStateUpdateProvider.updateUser(user);

    // update multiplayer records
    MultiplayerProvider multiplayerProvider = MultiplayerProvider();
    await multiplayerProvider.updateOngoingGames(user);

    return user;
  }

  Future deleteProfilePhoto(Users user) async {
    if (user.profilePath != '') {
      Reference oldStorageReference;
      oldStorageReference =
          FirebaseStorage.instance.ref().child(user.profilePath);
      await oldStorageReference.delete();
    }
    user.profileUrl = '';
    user.profilePath = '';

    UserStateUpdateProvider userStateUpdateProvider = UserStateUpdateProvider();
    await userStateUpdateProvider.updateUser(user);

    // update multiplayer records
    MultiplayerProvider multiplayerProvider = MultiplayerProvider();
    await multiplayerProvider.updateOngoingGames(user);
  }

  Future<List<Stats>> getUserStatistics(String uid) async {
    List<Stats> stats = [];

    await firestore.collection('user-data').doc(uid).get().then((res) async {
      Users user = Users.fromJson(res.data());
      user.stats.forEach((stat) {
        stats.add(Stats.fromJson(stat));
      });
    });

    return stats;
  }

  Future resetGame() async {
// has completed == false
// loop and remove all singleplayer stats
// do not clear score
  }

  Stream getLeaderboard() {
    return firestore
        .collection('user-data')
        .orderBy('score', descending: true)
        .snapshots();
  }
}
