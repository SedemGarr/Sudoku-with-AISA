class Board {
  List cells;

  Board({this.cells});

  Board.fromJson(Map<String, dynamic> json) {
    if (json['cells'] != null) {
      cells = new List<Null>();
      json['cells'].forEach((v) {
        cells.add(v);
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.cells != null) {
      data['cells'] = this.cells.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
