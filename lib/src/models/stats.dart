class Stats {
  Stats(
      {this.level,
      this.timeTaken,
      this.isCompetitive,
      this.isCoop,
      this.isMultiplayer,
      this.isSinglePlayer,
      this.wonGame});

  int level;
  int timeTaken;
  bool isSinglePlayer;
  bool isMultiplayer;
  bool isCoop;
  bool isCompetitive;
  bool wonGame;

  Stats.fromJson(Map<String, dynamic> json) {
    timeTaken = json['timeTaken'];
    level = json['level'];
    isCompetitive = json['isCompetitive'];
    isCoop = json['isCoop'];
    isMultiplayer = json['Multiplayer'];
    isSinglePlayer = json['isSinglePlayer'];
    wonGame = json['wonGame'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['timeTaken'] = this.timeTaken;
    data['level'] = this.level;
    data['wonGame'] = this.wonGame;
    data['isCompetitive'] = this.isCompetitive;
    data['isCoop'] = this.isCoop;
    data['isMultiplayer'] = this.isMultiplayer;
    data['isSinglePlayer'] = this.isSinglePlayer;
    return data;
  }
}
