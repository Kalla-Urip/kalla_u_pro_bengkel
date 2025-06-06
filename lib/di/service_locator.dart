// kalla_u_pro_bengkel/core/di/service_locator.dart

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Untuk kDebugMode
import 'package:get_it/get_it.dart';
import 'package:kalla_u_pro_bengkel/core/error/error_interceptor.dart';
import 'package:kalla_u_pro_bengkel/core/network/network_info.dart';
import 'package:kalla_u_pro_bengkel/core/services/auth_services.dart';
import 'package:kalla_u_pro_bengkel/core/services/fcm_service.dart';
import 'package:kalla_u_pro_bengkel/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:kalla_u_pro_bengkel/features/auth/data/repositories/auth_repositories.dart';
import 'package:kalla_u_pro_bengkel/features/auth/presentation/bloc/login_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/datasources/home_remote_data_source.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/repositories/home_repository.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/get_vehicle_type_cubit.dart';
import 'package:kalla_u_pro_bengkel/util/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt locator = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(sharedPreferences);
  locator.registerLazySingleton<Connectivity>(() => Connectivity());

  // AuthService (Penting untuk diakses oleh interceptor Dio)
  // Pastikan ini terdaftar SEBELUM Dio jika Dio bergantung padanya secara langsung saat pembuatan.
  // Dalam kasus interceptor yang mengambilnya dari locator, urutan tidak terlalu kritis selama keduanya lazy singletons.
  if (!locator.isRegistered<AuthService>()) {
    locator.registerLazySingleton<AuthService>(() => AuthService(locator<SharedPreferences>()));
  }

  // Dio (dengan konfigurasi terpusat)
  locator.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15), // Contoh timeout koneksi
        receiveTimeout: const Duration(seconds: 15), // Contoh timeout menerima data
        sendTimeout: const Duration(seconds: 15),    // Contoh timeout mengirim data
        headers: {
          'Accept': 'application/json', // Contoh header default
          // 'Content-Type': 'application/json', // Default Content-Type jika kebanyakan endpoint Anda JSON
                                              // Jika tidak, set per request atau di interceptor jika logikanya kompleks
        },
      ),
    );
    dio.interceptors.add(ErrorInterceptor()); 

    // Interceptor untuk menambahkan token otentikasi
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Ambil token dari AuthService
          final authService = locator<AuthService>();
          final token = await authService.getAccessToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options); // Lanjutkan request
        },
        onResponse: (response, handler) {
          // Anda bisa melakukan sesuatu dengan response di sini
          return handler.next(response); // Lanjutkan
        },
        onError: (DioException e, handler) async {
          // Anda bisa menangani error global di sini, misalnya token expired -> refresh token
          // Contoh sederhana:
          if (e.response?.statusCode == 401) {
            // Token mungkin expired atau tidak valid
            // Anda bisa implementasikan logic refresh token di sini atau logout pengguna
            // Misalnya, panggil authService.logout() dan navigasi ke halaman login
            // print("Token expired or invalid. Logging out.");
            // await locator<AuthService>().logout();
            // Mungkin perlu mekanisme untuk mengarahkan pengguna ke login screen
          }
          return handler.next(e); // Lanjutkan
        },
      ),
    );

    // Interceptor untuk logging (berguna saat development)
    if (kDebugMode) { // Hanya aktifkan pada mode debug
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
        logPrint: (object) {
          debugPrint(object.toString());
        },
      ));
    }
    return dio;
  });

  // Core
  locator.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(locator()));
   locator.registerLazySingleton<FcmService>(() => FcmService()); // Daftarkan FcmService


  // Features - Auth
  // Data sources
  locator.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: locator()), // Dio sudah terkonfigurasi
  );

  // Repositories
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: locator(),
      networkInfo: locator(),
    ),
  );

  // Cubits
  locator.registerFactory(
    () => LoginCubit(
      authRepository: locator(),
      authService: locator(),
      fcmService: locator()
    ),
  );

  // Features - Home
  // Data sources
  locator.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(client: locator()),
  );

  // Repositories
  locator.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      remoteDataSource: locator(),
      networkInfo: locator(),
    ),
  );

  // Cubits
  locator.registerFactory(
    () => GetVehicleTypeCubit(homeRepository: locator()),
  );
}