import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sudoku/src/models/request.dart';
import 'package:sudoku/src/models/stats.dart';
import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:sudoku/src/models/user.dart';
import 'package:sudoku/src/providers/local_storage_provider.dart';
import 'package:sudoku/src/providers/multiplayer_provider.dart';
import 'package:sudoku/src/providers/user_state_update_provider.dart';

class DatabaseProvider {
  final firestore = FirebaseFirestore.instance;

  Stream getUsers() {
    return firestore.collection('user-data').snapshots();
  }

  Stream getRequests() {
    return firestore.collection('requests').snapshots();
  }

  Future<Users> getUser(String id) async {
    return Users.fromJson(
        (await firestore.collection('user-data').doc(id).get()).data());
  }

  Future<bool> createFriendRequest(Users friend, Users user) async {
    var reqRef = firestore.collection("requests");

    Request request = Request(
        id: reqRef.doc().id,
        createdOn: DateTime.now().toString(),
        requestee: friend,
        requesteeId: friend.id,
        requesterId: user.id,
        requester: user);

    //  check if friend has already sent request
    var querySnapshot = await firestore
        .collection('requests')
        .where("requesterId", isEqualTo: friend.id)
        .get();

    querySnapshot.docs.forEach((result) {
      if (Request.fromJson(result.data()).requestee.id == user.id) {
        return false;
      }
    });

    // if no request exists
    await reqRef.doc(request.id).set(request.toJson(), SetOptions(merge: true));
    return true;
  }

  Future<void> acceptRequest(
      Request request, String friendId, String userId) async {
    Users friend = Users.fromJson(
        (await firestore.collection('user-data').doc(friendId).get()).data());
    Users user = Users.fromJson(
        (await firestore.collection('user-data').doc(userId).get()).data());

    List friendFriends = [];
    List userFriends = [];

    friend.friends.forEach((user) {
      friendFriends.add(user.toJson());
    });

    user.friends.forEach((user) {
      userFriends.add(user.toJson());
    });

    friendFriends.add(user.toJson());
    userFriends.add(friend.toJson());

    await denyRequest(request);

    await firestore
        .collection('user-data')
        .doc(friendId)
        .update({"friends": FieldValue.arrayUnion(friendFriends)});

    await firestore
        .collection('user-data')
        .doc(userId)
        .update({"friends": FieldValue.arrayUnion(userFriends)});

    LocalStorageProvider localStorageProvider = LocalStorageProvider();
    await localStorageProvider.setUser(user);
  }

  Future<void> denyRequest(Request request) async {
    await firestore.collection("requests").doc(request.id).delete();
  }

  Future<void> unfriend(String friendId, String userId) async {
    Users friend = Users.fromJson(
        (await firestore.collection('user-data').doc(friendId).get()).data());
    Users user = Users.fromJson(
        (await firestore.collection('user-data').doc(userId).get()).data());

    friend.friends
        .removeAt(friend.friends.indexWhere((element) => element.id == userId));
    user.friends
        .removeAt(user.friends.indexWhere((element) => element.id == friendId));

    await firestore
        .collection('user-data')
        .doc(friendId)
        .set(friend.toJson(), SetOptions(merge: true));

    await firestore
        .collection('user-data')
        .doc(userId)
        .set(user.toJson(), SetOptions(merge: true));

    LocalStorageProvider localStorageProvider = LocalStorageProvider();
    await localStorageProvider.setUser(user);
  }

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
      // get system dark/light mode
      var brightness = SchedulerBinding.instance.window.platformBrightness;

      // create user
      user = Users(
          freePlayDifficulty: 0,
          preferedPattern: 'Random',
          id: uid,
          username: username,
          profileUrl: profileUrl,
          level: 0,
          difficultyLevel: 0,
          tokens: [],
          audioEnabled: true,
          backupBoard: [],
          friends: [],
          profilePath: '',
          enableWakelock: true,
          hasCompletedGame: false,
          selectedTheme: 6,
          isDark: brightness == Brightness.dark,
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

  Future<void> deleteUserDocument(String id) async {
    await firestore.collection('user-data').doc(id).delete();
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

  Future resetGame(Users user) async {
    UserStateUpdateProvider userStateUpdateProvider = UserStateUpdateProvider();
    MultiplayerProvider multiplayerProvider = MultiplayerProvider();

    user.hasCompletedGame = false;
    user.difficultyLevel = 0;
    user.level = 0;
    user.hasCompletedIntro = false;
    user.stats =
        user.stats.where((element) => !element.isSinglePlayer).toList();
    await userStateUpdateProvider.updateUser(user);
    await multiplayerProvider.updateOngoingGames(user);
  }

  Stream getLeaderboard() {
    return firestore
        .collection('user-data')
        .orderBy('score', descending: true)
        .snapshots();
  }
}
