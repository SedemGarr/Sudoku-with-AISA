import 'package:flutter/material.dart';
import 'package:sudoku/src/models/user.dart';

import 'level.dart';

class MultiplayerGame {
  String id;
  String hostId;
  String lastPlayer;
  String createdOn;
  String preferedPattern;
  String lastPlayedOn;
  int elapsedTime;
  int difficulty;
  bool hasStarted;
  bool hasFinished;
  bool isCompetitive;
  bool isCooperative;
  List<dynamic> players;
  Level level;

  MultiplayerGame({
    @required this.difficulty,
    @required this.hasFinished,
    @required this.createdOn,
    @required this.lastPlayer,
    @required this.preferedPattern,
    @required this.lastPlayedOn,
    @required this.hasStarted,
    @required this.hostId,
    @required this.elapsedTime,
    @required this.id,
    @required this.isCompetitive,
    @required this.isCooperative,
    @required this.players,
    @required this.level,
  });

  MultiplayerGame.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    hostId = json['hostId'];
    createdOn = json['createdOn'];
    lastPlayedOn = json['lastPlayedOn'];
    lastPlayer = json['lastPlayer'];
    preferedPattern = json['preferedPattern'];
    hasStarted = json['hasStarted'];
    elapsedTime = json['elapsedTime'];
    difficulty = json['difficulty'];
    hasFinished = json['hasFinished'];
    isCompetitive = json['isCompetitive'];
    isCooperative = json['isCooperative'];
    level = Level.fromJson(json['level']);

    if (json['players'] != null) {
      players = <Users>[];
      json['players'].forEach((v) {
        players.add(new Users.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['hostId'] = this.hostId;
    data['createdOn'] = this.createdOn;
    data['lastPlayedOn'] = this.lastPlayedOn;
    data['lastPlayer'] = this.lastPlayer;
    data['hasFinished'] = this.hasFinished;
    data['elapsedTime'] = this.elapsedTime;
    data['preferedPattern'] = this.preferedPattern;
    data['difficulty'] = this.difficulty;
    data['hasStarted'] = this.hasStarted;
    data['isCompetitive'] = this.isCompetitive;
    data['isCooperative'] = this.isCooperative;
    data['level'] = this.level.toJson();

    if (this.players != null) {
      data['players'] = this.players.map((v) => v.toJson()).toList();
    }

    return data;
  }
}
