import 'package:flutter/cupertino.dart';

class Stats {
  Stats(
      {@required this.level,
      @required this.timeTaken,
      @required this.isCompetitive,
      @required this.isCoop,
      @required this.gameId,
      @required this.difficulty,
      @required this.isMultiplayer,
      @required this.isSinglePlayer,
      @required this.wonGame});

  String gameId;
  int level;
  int timeTaken;
  int difficulty;
  bool isSinglePlayer;
  bool isMultiplayer;
  bool isCoop;
  bool isCompetitive;
  bool wonGame;

  @override
  bool operator ==(other) {
    return (other is Stats) &&
        other.level == level &&
        other.timeTaken == timeTaken &&
        other.isCompetitive == isCompetitive &&
        other.isCoop == isCoop &&
        other.gameId == gameId &&
        other.isMultiplayer == isMultiplayer &&
        other.isSinglePlayer == isSinglePlayer &&
        other.wonGame == wonGame;
  }

  @override
  int get hashCode =>
      gameId.hashCode ^ level.hashCode ^ timeTaken.hashCode ^ isSinglePlayer.hashCode ^ isMultiplayer.hashCode ^ isCoop.hashCode ^ isCompetitive.hashCode ^ wonGame.hashCode;

  Stats.fromJson(Map<String, dynamic> json) {
    timeTaken = json['timeTaken'];
    level = json['level'];
    gameId = json['gameId'];
    isCompetitive = json['isCompetitive'];
    isCoop = json['isCoop'];
    isMultiplayer = json['Multiplayer'];
    isSinglePlayer = json['isSinglePlayer'];
    wonGame = json['wonGame'];
    difficulty = json['difficulty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['timeTaken'] = this.timeTaken;
    data['level'] = this.level;
    data['wonGame'] = this.wonGame;
    data['gameId'] = this.gameId;
    data['isCompetitive'] = this.isCompetitive;
    data['isCoop'] = this.isCoop;
    data['isMultiplayer'] = this.isMultiplayer;
    data['isSinglePlayer'] = this.isSinglePlayer;
    data['difficulty'] = this.difficulty;
    return data;
  }
}
