// kalla_u_pro_bengkel/core/services/auth_services.dart
import 'package:kalla_u_pro_bengkel/core/util/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
class AuthService {
  final SharedPreferences _prefs;
  AuthService(this._prefs);

  Future<bool> isLoggedIn() async {
    return _prefs.getBool(PrefKeys.isLoggedInKey) ?? false;
  }

  // Updated login method
  Future<void> login(String name, String nik, String accessToken) async {
    await _prefs.setBool(PrefKeys.isLoggedInKey, true);
    await _prefs.setString(PrefKeys.userNameKey, name);
    await _prefs.setString(PrefKeys.userNikKey, nik);
    await _prefs.setString(PrefKeys.accessToken, accessToken); // Save access token
  }

  Future<String> getUserName() async {
    return _prefs.getString(PrefKeys.userNameKey) ?? '';
  }

  Future<String> getUserNik() async {
    return _prefs.getString(PrefKeys.userNikKey) ?? '';
  }

  // Get access token
  Future<String?> getAccessToken() async {
    return _prefs.getString(PrefKeys.accessToken);
  }

  Future<void> logout() async {
    await _prefs.setBool(PrefKeys.isLoggedInKey, false);
    await _prefs.remove(PrefKeys.userNameKey);
    await _prefs.remove(PrefKeys.userNikKey);
    await _prefs.remove(PrefKeys.accessToken); // Remove access token on logout
  }
}