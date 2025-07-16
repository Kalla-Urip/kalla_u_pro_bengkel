class ApiConstants {
  // FIX: Define separate base URLs for the different API domains.
  static const String mechanicBaseUrl = 'https://api.kallaurip.pro/mobile/mechanic';
  static const String customerBaseUrl = 'https://api.kallaurip.pro/mobile';

  // Endpoints relative to mechanicBaseUrl
  static const String loginEndpoint = '/auth/login';
  static const String vehicleTypeEndpoint = '/vehicle-type';
  static const String addCustomerEndpoint = '/customer';
  static const String mechanicEndpoint = '/mechanic';
  static const String stallEndPoint = '/stall';
  static const String serviceData = '/service-data';
  static const String customerChasis = '/customer/chassis-number';

  // Endpoint relative to customerBaseUrl
  static const String serviceDetail = '/customer/vehicle/service/detail';
}

class PrefKeys {
  static const String accessToken = 'accessToken';
  static const String isLoggedInKey = 'isLoggedIn';
  static const String userNameKey = 'userName';
  static const String userNikKey = 'userNik';
}
