import 'package:sudoku/src/models/user.dart';
import 'package:sudoku/src/providers/database_provider.dart';
import 'package:sudoku/src/providers/local_storage_provider.dart';

class UserStateUpdateProvider {
  Future<void> updateUser(Users user) async {
    LocalStorageProvider localStorageProvider = LocalStorageProvider();
    DatabaseProvider databaseProvider = DatabaseProvider();
    await localStorageProvider.setUser(user);
    await databaseProvider.updateUserData(user);
  }
}
