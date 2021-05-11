import 'package:sudoku/src/models/difficulty.dart';

class Game {
  static List<Difficulty> generateGame() {
    List<Difficulty> game = [];

    for (int i = 0; i < 7; i++) {
      game.add(Difficulty.getDifficulty(i));
    }

    return game;
  }
}
