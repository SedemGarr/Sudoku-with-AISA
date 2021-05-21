class Level {
  Level({this.levelNumber, this.board, this.solvedBoard, this.backupBoard});

  int levelNumber;
  List<dynamic> board = [];
  List<dynamic> solvedBoard = [];
  List<dynamic> backupBoard = [];

  Level.fromJson(Map<String, dynamic> json) {
    levelNumber = json['levelNumber'];
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
    data['levelNumber'] = this.levelNumber;
    if (this.board != null) {
      data['board'] = this.board.map((v) => v).toList();
    }
    if (this.board != null) {
      data['solvedBoard'] = this.solvedBoard.map((v) => v).toList();
    }
    if (this.board != null) {
      data['backupBoard'] = this.backupBoard.map((v) => v).toList();
    }
    return data;
  }
}
