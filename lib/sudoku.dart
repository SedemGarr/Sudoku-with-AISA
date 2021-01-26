import 'package:flutter_sudoku/puzzles.dart';
import 'globalvariables.dart';

List board = List.generate(9, (i) => List(9), growable: false);
List solvedboard = List.generate(9, (i) => List(9), growable: false);
List backupBoard = List.generate(9, (i) => List(9), growable: false);

generateSudoku() {
  List tempUnsolvedSudoku = puzzles[level].split("");
  List tempSolvedSudoku = solvedPuzzles[level].split("");

  List unsolvedSudoku = [];
  List solvedSudoku = [];

//implement loading
  if (loaded.length > 50 && loadedsolved.length > 50) {
    print("dsgjvfkjsdbhkghsbfkjsnldjfgnlskjdglksjfdnlgkjsfnlkjgnslfjkglndfkj");
    loadTime1 = loadTime;

    for (int i = 0; i < loaded.length; i++) {
      unsolvedSudoku.add(int.parse(loaded[i]));
      solvedSudoku.add(int.parse(loadedsolved[i]));
    }
  } else {
//
    for (int i = 0; i < tempUnsolvedSudoku.length; i++) {
      unsolvedSudoku.add(int.parse(tempUnsolvedSudoku[i]));
    }
//
    for (int i = 0; i < tempSolvedSudoku.length; i++) {
      solvedSudoku.add(int.parse(tempSolvedSudoku[i]));
    }
  }
//implement loading

// add to board
  int count = 0;
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      board[i][j] = unsolvedSudoku[count];
      solvedboard[i][j] = solvedSudoku[count];
      count++;
    }
  }

  count = 0;
// create backup
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      backupBoard[i][j] = int.parse(tempUnsolvedSudoku[count]);
      count++;
    }
  }

  count = 0;
}
