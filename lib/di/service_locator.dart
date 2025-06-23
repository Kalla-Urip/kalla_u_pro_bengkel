// kalla_u_pro_bengkel/core/di/service_locator.dart

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Untuk kDebugMode
import 'package:get_it/get_it.dart';
import 'package:kalla_u_pro_bengkel/core/network/network_info.dart';
import 'package:kalla_u_pro_bengkel/core/services/auth_services.dart';
import 'package:kalla_u_pro_bengkel/core/services/fcm_service.dart';
import 'package:kalla_u_pro_bengkel/core/util/request_handler.dart';
import 'package:kalla_u_pro_bengkel/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:kalla_u_pro_bengkel/features/auth/data/repositories/auth_repositories.dart';
import 'package:kalla_u_pro_bengkel/features/auth/presentation/bloc/login_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/datasources/home_remote_data_source.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/repositories/home_repository.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/add_customer_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/get_customer_by_chasis_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/get_mechanic_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/get_service_data_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/get_stall_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/get_vehicle_type_cubit.dart';
import 'package:kalla_u_pro_bengkel/core/util/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';


final GetIt locator = GetIt.instance;

Future<void> setupServiceLocator() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(sharedPreferences);
  locator.registerLazySingleton<Connectivity>(() => Connectivity());
  locator.registerLazySingleton<AuthService>(() => AuthService(locator<SharedPreferences>()));
  locator.registerLazySingleton<FcmService>(() => FcmService());

  locator.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {'Accept': 'application/json'},
      ),
    );
    
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final authService = locator<AuthService>();
        final token = await authService.getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        logPrint: (object) => debugPrint(object.toString()),
      ));
    }
    return dio;
  });

  locator.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(locator()));
  locator.registerLazySingleton<RequestHandler>(() => RequestHandler(networkInfo: locator()));

  locator.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(client: locator()));
  locator.registerLazySingleton<HomeRemoteDataSource>(() => HomeRemoteDataSourceImpl(client: locator()));

  locator.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: locator(), requestHandler: locator()));
  locator.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(remoteDataSource: locator(), requestHandler: locator()));
  
  locator.registerFactory(() => LoginCubit(authRepository: locator(), authService: locator(), fcmService: locator()));
  locator.registerFactory(() => GetVehicleTypeCubit(homeRepository: locator()));
  locator.registerFactory(() => AddCustomerCubit(homeRepository: locator()));
  locator.registerFactory(() => GetStallsCubit(homeRepository: locator()));
  locator.registerFactory(() => GetMechanicsCubit(homeRepository: locator()));
  locator.registerFactory(() => GetServiceDataCubit(homeRepository: locator()));
  locator.registerFactory(() => GetCustomerByChassisCubit(homeRepository: locator()));
}