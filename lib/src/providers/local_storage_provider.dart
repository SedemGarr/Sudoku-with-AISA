import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/src/models/user.dart';

class LocalStorageProvider {
  SharedPreferences _preferences;

  setUser(Users user) async {
    this._preferences = await SharedPreferences.getInstance();
    await this._preferences.setString('user', json.encode(user.toJson()));
  }

  Future<Users> getUser() async {
    this._preferences = await SharedPreferences.getInstance();
    var user = this._preferences.get('user');
    return user == null ? null : Users.fromJson(json.decode(user));
  }

  Future<void> clearUser() async {
    this._preferences = await SharedPreferences.getInstance();
    await this._preferences.remove('user');
  }

  // setDarkMode(bool value) async {
  //   this._preferences = await SharedPreferences.getInstance();
  //   await this._preferences.setBool('isDark', value);
  // }

  // Future<bool> getDarkMode() async {
  //   this._preferences = await SharedPreferences.getInstance();
  //   return this._preferences.getBool('isDark') == null
  //       ? true
  //       : this._preferences.getBool('isDark');
  // }

}
