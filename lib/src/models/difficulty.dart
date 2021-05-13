import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:sudoku/src/models/level.dart';
import 'package:sudoku/src/models/theme.dart';
import 'package:sudoku_api/sudoku_api.dart';
import 'dart:math';

class Difficulty {
  int id;
  List<Level> levels;
  String difficultyName;
  IconData icon;
  AppTheme theme;

  static final random = new Random();
  static int generateRandomInt(int min, int max) {
    return min + random.nextInt(max - min);
  }

  static int parseDifficultyLevel(int difficultyLevel) {
    if (difficultyLevel <= 1) {
      return 1;
    }
    if (difficultyLevel > 1 && difficultyLevel <= 3) {
      return 2;
    }
    if (difficultyLevel > 3 && difficultyLevel <= 5) {
      return 3;
    } else {
      return 10;
    }
  }

  static Future<List<Level>> generateLevels(int difficultyLevel) async {
    List<Level> levels = [];

    for (int i = 0; i < 9; i++) {
      // setup sudoku object and pass options
      Puzzle sudoku = Puzzle(
        PuzzleOptions(
          patternName: "Random",
          difficulty: parseDifficultyLevel(difficultyLevel) == 10
              ? 3
              : parseDifficultyLevel(difficultyLevel),
        ),
      );
      sudoku.generate().then((_) {
        Level level =
            Level(board: [], levelNumber: i, solvedBoard: [], backupBoard: []);

        // create level boards
        for (int j = 0; j < 81; j++) {
          level.board.add(sudoku.board().cellAt(Position(index: j)).getValue());
          level.backupBoard
              .add(sudoku.board().cellAt(Position(index: j)).getValue());
          level.solvedBoard
              .add(sudoku.solvedBoard().cellAt(Position(index: j)).getValue());
        }

        // add level to levels list
        levels.add(level);
      });
    }

    return levels;
  }

  static Future<Level> regenerateLevel(
      int difficultyLevel, int levelNumber, String patternName) async {
    Level level = Level(
        board: [], levelNumber: levelNumber, solvedBoard: [], backupBoard: []);

    Puzzle sudoku = Puzzle(
      PuzzleOptions(
        patternName: patternName,
        difficulty: parseDifficultyLevel(difficultyLevel) == 10
            ? parseDifficultyLevel(generateRandomInt(0, 6))
            : parseDifficultyLevel(difficultyLevel),
      ),
    );

    sudoku.generate().then((_) {
      for (int j = 0; j < 81; j++) {
        level.board.add(sudoku.board().cellAt(Position(index: j)).getValue());
        level.backupBoard
            .add(sudoku.board().cellAt(Position(index: j)).getValue());
        level.solvedBoard
            .add(sudoku.solvedBoard().cellAt(Position(index: j)).getValue());
      }
    });

    return level;
  }

  Difficulty({
    this.difficultyName,
    this.icon,
    this.id,
    this.levels,
    this.theme,
  });

  static Difficulty getDifficulty(int difficultyLevel) {
    switch (difficultyLevel) {
      case 0:
        return Difficulty(
            difficultyName: 'easy',
            icon: LineIcons.laughingSquintingFaceAlt,
            id: 0,
            levels: [],
            theme: AppTheme.themes[0]);
        break;
      case 1:
        return Difficulty(
            difficultyName: 'medium',
            icon: LineIcons.smilingFaceAlt,
            id: 1,
            levels: [],
            theme: AppTheme.themes[1]);
        break;
      case 2:
        return Difficulty(
            difficultyName: 'hard',
            icon: LineIcons.neutralFaceAlt,
            id: 2,
            levels: [],
            theme: AppTheme.themes[2]);
        break;
      case 3:
        return Difficulty(
            difficultyName: 'very hard',
            icon: LineIcons.grimacingFaceAlt,
            id: 3,
            levels: [],
            theme: AppTheme.themes[3]);
        break;
      case 4:
        return Difficulty(
            difficultyName: 'insane',
            icon: LineIcons.frowningFaceWithOpenMouthAlt,
            id: 4,
            levels: [],
            theme: AppTheme.themes[4]);
        break;
      case 5:
        return Difficulty(
            difficultyName: 'inhuman',
            icon: LineIcons.flushedFaceAlt,
            id: 5,
            levels: [],
            theme: AppTheme.themes[5]);
        break;
      case 6:
        return Difficulty(
            difficultyName: 'free-play',
            icon: LineIcons.starAlt,
            id: 6,
            levels: [],
            theme: AppTheme.themes[6]);
        break;
      default:
        return Difficulty(
            difficultyName: 'complete',
            icon: Icons.ac_unit,
            id: 6,
            levels: [],
            theme: AppTheme.themes[6]);
    }
  }
}
