import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sudoku/src/models/difficulty.dart';
import 'package:sudoku/src/models/invite.dart';
import 'package:sudoku/src/models/multiplayer.dart';
import 'package:sudoku/src/models/user.dart';

class MultiplayerProvider {
  final firestore = FirebaseFirestore.instance;

  Stream getCurrentGame(String gameId) {
    return firestore.collection('games').where('id', isEqualTo: gameId).snapshots();
  }

  Stream getOngoingGames(Users user) {
    return firestore
        .collection('games')
        // .where('players', arrayContains: user)
        .snapshots();
  }

  Stream getStartingGame(String docId) {
    return firestore.collection('games').where('id', isEqualTo: docId).snapshots();
  }

  Stream getInvites(String id) {
    return firestore.collection('invites').where('inviteeId', isEqualTo: id).snapshots();
  }

  Future<void> sendInvite(Users friend, Users user, MultiplayerGame game) async {
    var inviteRef = firestore.collection("invites");

    Invite invite = Invite(
        id: inviteRef.doc().id,
        gameId: game.id,
        isCoop: game.isCooperative,
        createdOn: DateTime.now().toString(),
        invitee: friend,
        inviteeId: friend.id,
        inviterId: user.id,
        inviter: user);

    await inviteRef.doc(game.id).set(invite.toJson(), SetOptions(merge: true));

    game.hasInvited = true;
    game.invitee = friend;
    game.invitationStatus = 3;

    await updateGameSettings(game);
  }

  Future<bool> checkIfInviteExists(String id) async {
    var doc = await firestore.collection('invites').doc(id).get();
    return doc.exists;
  }

  Future<void> refuseInviteByGameId(String gameId, bool accepted) async {
    MultiplayerGame game = await getGame(gameId);
    await firestore.collection("invites").doc(gameId).delete();

    game.invitationStatus = accepted ? 1 : 0;
    updateGameSettings(game);
  }

  Future<List<MultiplayerGame>> getOngoingGamesList(Users user) async {
    List<MultiplayerGame> games = [];
    List<MultiplayerGame> tempGames = [];

    await firestore.collection('games').get().then((value) => {
          value.docs.forEach((mpGame) {
            tempGames.add(MultiplayerGame.fromJson(mpGame.data()));
            if (tempGames[tempGames.length - 1].players.where((element) => element.id == user.id).toList().length > 0) {
              games.add(MultiplayerGame.fromJson(mpGame.data()));
            }
          })
        });

    return games;
  }

  Future<void> startGameOnInit(MultiplayerGame currentGame) async {
    currentGame.hasStarted = true;

    await firestore.collection('games').doc(currentGame.id).set(currentGame.toJson(), SetOptions(merge: true));
  }

  Future<MultiplayerGame> createGame(Users user) async {
    var gameRef = firestore.collection("games");

    MultiplayerGame game = MultiplayerGame(
        hasInvited: false,
        invitationStatus: 2,
        invitee: null,
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
        lastPlayer: null);

    game.level = await Difficulty.regenerateLevel(user.freePlayDifficulty, 400, user.preferedPattern);

    await gameRef.doc(game.id).set(game.toJson(), SetOptions(merge: true));

    return game;
  }

  Future<bool> checkIfGameExists(String gameId, Users user) async {
    var doc = await firestore.collection('games').doc(gameId).get();

    if (doc.exists) {
      if (doc.data()['players'].length <= 1 || doc.data()['players'].indexWhere((element) => element['id'] != user.id) != -1) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<MultiplayerGame> getGame(String gameId) async {
    return MultiplayerGame.fromJson((await firestore.collection('games').doc(gameId).get()).data());
  }

  Future<MultiplayerGame> joinGame(String gameId, Users user) async {
    MultiplayerGame game = MultiplayerGame.fromJson((await firestore.collection('games').doc(gameId).get()).data());

    if (game.players.indexWhere((element) => element.id == user.id) == -1) {
      await firestore.collection('games').doc(gameId).update({
        "players": FieldValue.arrayUnion([user.toJson()])
      });
    }

    return MultiplayerGame.fromJson((await firestore.collection('games').doc(gameId).get()).data());
  }

  Future<void> leaveGame(MultiplayerGame game, Users user) async {
    game.players.removeWhere((element) => element.id == user.id);

    await updateGameSettings(game);
  }

  Future<void> deleteGame(String gameId) async {
    // delete invite as well
    if (await checkIfInviteExists(gameId)) {
      await refuseInviteByGameId(gameId, false);
    }

    await firestore.collection('games').doc(gameId).delete();
  }

  Future<void> updateGameSettings(MultiplayerGame currentGame) async {
    // make a transaction
    await firestore.collection('games').doc(currentGame.id).set(currentGame.toJson(), SetOptions(merge: true));
  }

  Future<void> updateOngoingGames(Users user) async {
    await firestore.collection('games').get().then((res) {
      res.docs.forEach((game) async {
        MultiplayerGame tempGame = MultiplayerGame.fromJson(game.data());

        int index = tempGame.players.indexWhere((element) => element.id == user.id);

        if (index != -1) {
          tempGame.players[index] = user;

          await firestore.collection('games').doc(game.data()['id']).set(tempGame.toJson(), SetOptions(merge: true));
        }
      });
    });
  }
}
