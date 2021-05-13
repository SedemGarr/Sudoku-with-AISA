import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sudoku/src/models/difficulty.dart';
import 'package:sudoku/src/models/multiplayer.dart';
import 'package:sudoku/src/models/user.dart';

class MultiplayerProvider {
  final firestore = FirebaseFirestore.instance;

  Stream getOngoingGames(String id) {
    return firestore
        .collection('games')
        .where('players', arrayContains: id)
        .snapshots();
  }

  Stream getStartingGame(String docId) {
    return firestore
        .collection('games')
        .where('id', isEqualTo: docId)
        .snapshots();
  }

  Future<MultiplayerGame> createGame(Users user) async {
    var gameRef = firestore.collection("games");

    MultiplayerGame game = MultiplayerGame(
        level: null,
        elapsedTime: 0,
        hasFinished: false,
        difficulty: user.freePlayDifficulty,
        hasStarted: false,
        hostId: user.id,
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

  Future<void> deleteGame(String gameId) async {
    await firestore.collection('games').doc(gameId).delete();
  }

  Future<void> updateOngoingGames(Users user) async {
    await firestore
        .collection("games")
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
