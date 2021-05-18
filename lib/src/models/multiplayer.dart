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
  int hostSelectedIndex;
  int participantSelectedIndex;
  bool hasStarted;
  bool hasFinished;
  bool isCompetitive;
  bool isCooperative;
  bool hasInvited;
  int invitationStatus;
  // 0 - declined
  // 1 - accepted
  // 2 - initial
  // 3 - pending
  Users invitee;
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
    @required this.hasInvited,
    @required this.hostSelectedIndex,
    @required this.participantSelectedIndex,
    @required this.elapsedTime,
    @required this.id,
    @required this.invitationStatus,
    @required this.invitee,
    @required this.isCompetitive,
    @required this.isCooperative,
    @required this.players,
    @required this.level,
  });

  MultiplayerGame.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    hasInvited = json['hasInvited'];
    hostId = json['hostId'];
    createdOn = json['createdOn'];
    lastPlayedOn = json['lastPlayedOn'];
    lastPlayer = json['lastPlayer'];
    preferedPattern = json['preferedPattern'];
    hasStarted = json['hasStarted'];
    elapsedTime = json['elapsedTime'];
    hostSelectedIndex = json['hostSelectedIndex'];
    participantSelectedIndex = json['participantSelectedIndex'];
    difficulty = json['difficulty'];
    hasFinished = json['hasFinished'];
    isCompetitive = json['isCompetitive'];
    isCooperative = json['isCooperative'];
    invitationStatus = json['invitationStatus'];
    level = Level.fromJson(json['level']);
    if (json['invitee'] != null) {
      invitee = Users.fromJson(json['invitee']);
    }
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
    data['hasInvited'] = this.hasInvited;
    data['invitationStatus'] = this.invitationStatus;
    data['hostId'] = this.hostId;
    data['createdOn'] = this.createdOn;
    data['lastPlayedOn'] = this.lastPlayedOn;
    data['lastPlayer'] = this.lastPlayer;
    data['hasFinished'] = this.hasFinished;
    data['elapsedTime'] = this.elapsedTime;
    data['hostSelectedIndex'] = this.hostSelectedIndex;
    data['participantSelectedIndex'] = this.participantSelectedIndex;
    data['preferedPattern'] = this.preferedPattern;
    data['difficulty'] = this.difficulty;
    data['hasStarted'] = this.hasStarted;
    data['isCompetitive'] = this.isCompetitive;
    data['isCooperative'] = this.isCooperative;
    data['level'] = this.level.toJson();

    if (this.invitee != null) {
      data['invitee'] = this.invitee.toJson();
    }

    if (this.players != null) {
      data['players'] = this.players.map((v) => v.toJson()).toList();
    }

    return data;
  }
}
