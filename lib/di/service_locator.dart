import 'package:get_it/get_it.dart';
import 'package:kalla_u_pro_bengkel/core/services/auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt locator = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Register services that require async initialization
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(sharedPreferences);
  
  // Register services
  locator.registerLazySingleton<AuthService>(() => AuthService(locator<SharedPreferences>()));
  
  // You can add more services here as needed
}
