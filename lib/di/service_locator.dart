// kalla_u_pro_bengkel/core/di/service_locator.dart (or your existing file)
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:kalla_u_pro_bengkel/core/network/network_info.dart';
import 'package:kalla_u_pro_bengkel/core/services/auth_services.dart';
import 'package:kalla_u_pro_bengkel/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:kalla_u_pro_bengkel/features/auth/data/repositories/auth_repositories.dart';
import 'package:kalla_u_pro_bengkel/features/auth/presentation/bloc/login_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt locator = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(sharedPreferences);
  locator.registerLazySingleton<Dio>(() => Dio()); // Basic Dio instance
  locator.registerLazySingleton<Connectivity>(() => Connectivity());

  // Core
  locator.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(locator()));
  // AuthService (already registered in your provided code, ensure it uses the SharedPreferences from locator if refactoring)
  // If not, ensure it's registered:
  if (!locator.isRegistered<AuthService>()) {
    locator.registerLazySingleton<AuthService>(() => AuthService(locator<SharedPreferences>()));
  }


  // Features - Auth
  // Data sources
  locator.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: locator()),
  );

  // Repositories
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: locator(),
      networkInfo: locator(),
    ),
  );

  // Cubits (Factories because they might have state that shouldn't persist across features/screens)
  locator.registerFactory(
    () => LoginCubit(
      authRepository: locator(),
      authService: locator(), // Inject AuthService
    ),
  );
  
  // You can add more services and features here
}