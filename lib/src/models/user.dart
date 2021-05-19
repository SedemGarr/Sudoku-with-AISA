import 'package:flutter/material.dart';
import 'package:sudoku/src/models/stats.dart';

class Users {
  String id;
  String username;
  String profileUrl;
  String profilePath;
  String preferedPattern;
  int score;
  int level;
  int elapsedTime;
  int difficultyLevel;
  int selectedTheme;
  int freePlayDifficulty;
  bool hasCompletedIntro;
  bool enableWakelock;
  bool hasCompletedGame;
  bool isFriendly;
  bool isDark;
  bool audioEnabled;
  bool hasTrainingWheels;
  List<dynamic> tokens;
  List<dynamic> friends;
  List<dynamic> stats;
  List<dynamic> savedBoard;
  List<dynamic> backupBoard;
  List<dynamic> savedSolvedBoard;

  Users(
      {@required this.id,
      @required this.profileUrl,
      @required this.profilePath,
      @required this.audioEnabled,
      @required this.isDark,
      @required this.preferedPattern,
      @required this.freePlayDifficulty,
      @required this.selectedTheme,
      @required this.hasCompletedGame,
      @required this.enableWakelock,
      @required this.username,
      @required this.score,
      @required this.level,
      @required this.friends,
      @required this.elapsedTime,
      @required this.difficultyLevel,
      @required this.hasCompletedIntro,
      @required this.hasTrainingWheels,
      @required this.isFriendly,
      @required this.stats,
      @required this.tokens,
      @required this.backupBoard,
      @required this.savedBoard,
      @required this.savedSolvedBoard});

  Users.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    profileUrl = json['profileUrl'];
    profilePath = json['profilePath'];
    score = json['score'];
    level = json['level'];
    audioEnabled = json['audioEnabled'];
    preferedPattern = json['preferedPattern'];
    freePlayDifficulty = json['freePlayDifficulty'];
    isDark = json['isDark'];
    hasCompletedGame = json['hasCompletedGame'];
    enableWakelock = json['enableWakelock'];
    selectedTheme = json['selectedTheme'];
    elapsedTime = json['elapsedTime'];
    hasCompletedIntro = json['hasCompletedIntro'];
    hasTrainingWheels = json['hasTrainingWheels'];
    isFriendly = json['isFriendly'];
    difficultyLevel = json['difficultyLevel'];
    if (json['tokens'] != null) {
      tokens = <String>[];
      json['tokens'].forEach((v) {
        tokens.add(v);
      });
    }
    if (json['friends'] != null) {
      friends = <Users>[];
      json['friends'].forEach((v) {
        friends.add(new Users.fromJson(v));
      });
    }
    if (json['stats'] != null) {
      stats = <Stats>[];
      json['stats'].forEach((v) {
        stats.add(new Stats.fromJson(v));
      });
    }
    if (json['savedBoard'] != null) {
      savedBoard = [];
      json['savedBoard'].forEach((v) {
        savedBoard.add(v);
      });
    }
    if (json['savedSolvedBoard'] != null) {
      savedSolvedBoard = [];
      json['savedSolvedBoard'].forEach((v) {
        savedSolvedBoard.add(v);
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
    data['username'] = this.username;
    data['profileUrl'] = this.profileUrl;
    data['profilePath'] = this.profilePath;
    data['score'] = this.score;
    data['level'] = this.level;
    data['hasCompletedGame'] = this.hasCompletedGame;
    data['freePlayDifficulty'] = this.freePlayDifficulty;
    data['preferedPattern'] = this.preferedPattern;
    data['audioEnabled'] = this.audioEnabled;
    data['enableWakelock'] = this.enableWakelock;
    data['isDark'] = this.isDark;
    data['selectedTheme'] = this.selectedTheme;
    data['elapsedTime'] = this.elapsedTime;
    data['hasCompletedIntro'] = this.hasCompletedIntro;
    data['hasTrainingWheels'] = this.hasTrainingWheels;
    data['isFriendly'] = this.isFriendly;
    data['difficultyLevel'] = this.difficultyLevel;
    if (this.tokens != null) {
      data['tokens'] = this.tokens.map((v) => v).toList();
    }
    if (this.friends != null) {
      data['friends'] = this.friends.map((v) => v.toJson()).toList();
    }
    if (this.stats != null) {
      data['stats'] = this.stats.map((v) => v.toJson()).toList();
    }
    if (this.savedBoard != null) {
      data['savedBoard'] = this.savedBoard.map((v) => v).toList();
    }
    if (this.savedSolvedBoard != null) {
      data['savedSolvedBoard'] = this.savedSolvedBoard.map((v) => v).toList();
    }
    if (this.backupBoard != null) {
      data['backupBoard'] = this.backupBoard.map((v) => v).toList();
    }
    return data;
  }
}
