import 'package:flutter/material.dart';

class MultiplayerGame {
  String id;
  String hostId;
  String lastPlayer;
  bool hasStarted;
  bool hasFinished;
  bool isCompetitive;
  bool isCooperative;
  List<dynamic> players;
  List<dynamic> board;
  List<dynamic> backupBoard;
  List<dynamic> solvedBoard;

  MultiplayerGame({
    @required this.backupBoard,
    @required this.board,
    @required this.hasFinished,
    @required this.hasStarted,
    @required this.hostId,
    @required this.id,
    @required this.isCompetitive,
    @required this.isCooperative,
    @required this.players,
    @required this.solvedBoard,
  });

  MultiplayerGame.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    hostId = json['hostId'];
    lastPlayer = json['lastPlayer'];
    hasStarted = json['hasStarted'];
    hasFinished = json['hasFinished'];
    isCompetitive = json['isCompetitive'];
    isCooperative = json['isCooperative'];

    if (json['players'] != null) {
      players = <String>[];
      json['players'].forEach((v) {
        players.add(v);
      });
    }
    if (json['board'] != null) {
      board = [];
      json['board'].forEach((v) {
        board.add(v);
      });
    }
    if (json['solvedBoard'] != null) {
      solvedBoard = [];
      json['solvedBoard'].forEach((v) {
        solvedBoard.add(v);
      });
    }
    if (json['backupBoard'] != null) {
      backupBoard = [];
      json['backupBoard'].forEach((v) {
        backupBoard.add(v);
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['hostId'] = this.hostId;
    data['lastPlayer'] = this.lastPlayer;
    data['hasFinished'] = this.hasFinished;
    data['hasStarted'] = this.hasStarted;
    data['isCompetitive'] = this.isCompetitive;
    data['isCooperative'] = this.isCooperative;

    if (this.players != null) {
      data['players'] = this.players.map((v) => v.toJson()).toList();
    }
    if (this.board != null) {
      data['board'] = this.board.map((v) => v).toList();
    }
    if (this.solvedBoard != null) {
      data['solvedBoard'] = this.solvedBoard.map((v) => v).toList();
    }
    if (this.backupBoard != null) {
      data['backupBoard'] = this.backupBoard.map((v) => v).toList();
    }
    return data;
  }
}
