import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sudoku/src/models/difficulty.dart';
import 'package:sudoku/src/models/multiplayer.dart';
import 'package:sudoku/src/models/user.dart';

class MultiplayerProvider {
  final firestore = FirebaseFirestore.instance;

  Stream getCurrentGame(String gameId) {
    return firestore
        .collection('games')
        .where('id', isEqualTo: gameId)
        .snapshots();
  }

  Stream getOngoingGames(Users user) {
    return firestore
        .collection('games')
        // .where('players', arrayContains: user)
        .snapshots();
  }

  Stream getStartingGame(String docId) {
    return firestore
        .collection('games')
        .where('id', isEqualTo: docId)
        .snapshots();
  }

  Future<void> startGameOnInit(MultiplayerGame currentGame) async {
    currentGame.hasStarted = true;

    await firestore
        .collection('games')
        .doc(currentGame.id)
        .set(currentGame.toJson(), SetOptions(merge: true));
  }

  Future<MultiplayerGame> createGame(Users user) async {
    var gameRef = firestore.collection("games");

    MultiplayerGame game = MultiplayerGame(
        level: null,
        elapsedTime: null,
        hasFinished: false,
        difficulty: user.freePlayDifficulty,
        hasStarted: false,
        preferedPattern: user.preferedPattern,
        hostId: user.id,
        hostSelectedIndex: null,
        participantSelectedIndex: null,
        id: gameRef.doc().id,
        isCompetitive: false,
        isCooperative: true,
        players: [user],
        createdOn: DateTime.now().toString(),
        lastPlayedOn: DateTime.now().toString(),
        lastPlayer: user.id);

    game.level = await Difficulty.regenerateLevel(
        user.freePlayDifficulty, 400, user.preferedPattern);

    await gameRef.doc(game.id).set(game.toJson(), SetOptions(merge: true));

    return game;
  }

  Future<bool> checkIfGameExists(String gameId) async {
    var doc = await firestore.collection('games').doc(gameId).get();

    if (doc.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future<MultiplayerGame> joinGame(String gameId, Users user) async {
    await firestore.collection('games').doc(gameId).update({
      "players": FieldValue.arrayUnion([user.toJson()])
    });

    return MultiplayerGame.fromJson(
        (await firestore.collection('games').doc(gameId).get()).data());
  }

  Future<void> leaveGame(MultiplayerGame game, Users user) async {
    game.players.removeWhere((element) => element.id == user.id);

    await updateGameSettings(game);
  }

  Future<void> deleteGame(String gameId) async {
    await firestore.collection('games').doc(gameId).delete();
  }

  Future<void> updateGameSettings(MultiplayerGame currentGame) async {
    // make a transaction
    await firestore
        .collection('games')
        .doc(currentGame.id)
        .set(currentGame.toJson(), SetOptions(merge: true));
  }

  Future<void> updateOngoingGames(Users user) async {
    await firestore
        .collection('games')
        .where('players', arrayContains: user.id)
        .get()
        .then((res) {
      res.docs.forEach((game) async {
        MultiplayerGame tempGame = MultiplayerGame.fromJson(game.data());

        int index =
            tempGame.players.indexWhere((element) => element.id == user.id);

        tempGame.players[index] = user;

        await firestore
            .collection('games')
            .doc(game.data()['id'])
            .set(tempGame.toJson(), SetOptions(merge: true));
      });
    });
  }
}
