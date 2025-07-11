// kalla_u_pro_bengkel/core/utils/constants.dart
class ApiConstants {
  static const String baseUrl = 'https://api-dev.kallaurip.pro/mobile/mechanic';
  static const String loginEndpoint = '/auth/login';

  // Home
   static const String vehicleTypeEndpoint = '/vehicle-type';
   static const String addCustomerEndpoint = '/customer';
   static const String mechanicEndpoint = '/mechanic';
   static const String stallEndPoint = '/stall';
   static const String serviceData = '/service-data';
   static const String customerChasis = '/customer/chassis-number';
}

class PrefKeys {
  static const String accessToken = 'accessToken';
  static const String isLoggedInKey = 'isLoggedIn'; // from your AuthService
  static const String userNameKey = 'userName'; // from your AuthService
  static const String userNikKey = 'userNik'; // from your AuthService
}