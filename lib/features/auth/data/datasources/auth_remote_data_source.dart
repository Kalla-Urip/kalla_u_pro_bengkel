import 'dart:io';

import 'package:dio/dio.dart';
import 'package:kalla_u_pro_bengkel/core/error/error_codes.dart';
import 'package:kalla_u_pro_bengkel/core/error/exceptions.dart';
import 'package:kalla_u_pro_bengkel/features/auth/data/models/login_response_model.dart';
import 'package:kalla_u_pro_bengkel/util/constants.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(String nik, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<LoginResponseModel> login(String nik, String password) async {
    const url = ApiConstants.loginEndpoint;

    try {
      final response = await client.post(
        url, // Hanya endpoint
        data: {'nik': nik, 'password': password},
        options: Options(
          // Content-Type ini spesifik untuk form-urlencoded, jadi baik untuk tetap di sini
          // Jika sebagian besar request Anda adalah JSON, Anda bisa set 'Content-Type': 'application/json' di BaseOptions Dio
          // dan hanya override di sini jika berbeda.
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Pastikan response.data adalah Map sebelum di-parse
        if (response.data is Map<String, dynamic>) {
          return LoginResponseModel.fromJson(response.data);
        } else {
          throw ServerException(
            message: "Format respons tidak valid dari server.", 
            statusCode: response.statusCode,
            errorCode: ErrorCode.invalidResponse // Kode error spesifik
          );
        }
      } else {
        // Harusnya ini ditangani oleh DioException, tapi sebagai fallback
        final String errorMessage = response.data?['message'] ?? 'Login gagal. Silakan coba lagi.';
        throw GeneralException(errorMessage, statusCode: response.statusCode, errorCode: ErrorCode.apiError);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NoInternetException(message: 'Waktu koneksi habis: ${e.message}', errorCode: ErrorCode.timeout);
      } else if (e.error is SocketException || e.type == DioExceptionType.connectionError) {
         throw NoInternetException(message: 'Gagal terhubung ke server: ${e.message}', errorCode: ErrorCode.noInternet);
      } else if (e.response != null) {
        final String errorMessage = e.response?.data?['message'] ?? e.response?.data?['status'] ?? 'Terjadi kesalahan dari server.';
        if (e.response?.statusCode == 401) {
           throw GeneralException(errorMessage, statusCode: e.response?.statusCode, errorCode: ErrorCode.authenticationFailed);
        }
        throw ServerException(message: errorMessage, statusCode: e.response?.statusCode, errorCode: ErrorCode.apiError);
      } else {
        throw ServerException(message: 'Kesalahan tidak terduga saat komunikasi jaringan: ${e.message}', errorCode: ErrorCode.networkOther);
      }
    } catch (e) { 
      if (e is ServerException || e is GeneralException || e is NoInternetException) rethrow; // Jika sudah exception custom, lempar lagi
      throw ServerException(message: 'Kesalahan tidak terduga: ${e.toString()}', errorCode: ErrorCode.unknownError);
    }
  }
}