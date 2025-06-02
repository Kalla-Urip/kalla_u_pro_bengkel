// kalla_u_pro_bengkel/core/utils/constants.dart
class ApiConstants {
  static const String baseUrl = 'http://141.11.25.72:5000/mobile';
  static const String loginEndpoint = '/mechanic/auth/login';
  // Add other endpoints here
}

class PrefKeys {
  static const String accessToken = 'accessToken';
  static const String isLoggedInKey = 'isLoggedIn'; // from your AuthService
  static const String userNameKey = 'userName'; // from your AuthService
  static const String userNikKey = 'userNik'; // from your AuthService
}