import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final SharedPreferences _prefs;
  
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userNameKey = 'userName';
  static const String _userNikKey = 'userNik';

  // Constructor takes SharedPreferences instance
  AuthService(this._prefs);

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return _prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Login and save user data
  Future<void> login(String name, String nik) async {
    await _prefs.setBool(_isLoggedInKey, true);
    await _prefs.setString(_userNameKey, name);
    await _prefs.setString(_userNikKey, nik);
  }

  // Get user name
  Future<String> getUserName() async {
    return _prefs.getString(_userNameKey) ?? '';
  }

  // Get user NIK
  Future<String> getUserNik() async {
    return _prefs.getString(_userNikKey) ?? '';
  }

  // Logout
  Future<void> logout() async {
    await _prefs.setBool(_isLoggedInKey, false);
    await _prefs.remove(_userNameKey);
    await _prefs.remove(_userNikKey);
  }
}