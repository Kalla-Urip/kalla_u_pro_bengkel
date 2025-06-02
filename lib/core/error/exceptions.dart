
import 'package:kalla_u_pro_bengkel/core/error/error_codes.dart';

class ServerException implements Exception {
  final String? message;
  final int? statusCode;
  final ErrorCode errorCode; // Tambahkan ErrorCode

  ServerException({this.message, this.statusCode, this.errorCode = ErrorCode.serverInternalError});

  @override
  String toString() => message ?? 'Terjadi kesalahan pada server (Kode Internal: ${errorCode.name}).';
}

class CacheException implements Exception {
   final String message;
   final ErrorCode errorCode; // Tambahkan ErrorCode

   CacheException({this.message = 'Terjadi kesalahan pada cache.', this.errorCode = ErrorCode.cacheError});

   @override
  String toString() => message;
}

class GeneralException implements Exception { // Ini biasanya untuk pesan dari API
  final String message;
  final int? statusCode;
  final ErrorCode errorCode; // Tambahkan ErrorCode

  GeneralException(this.message, {this.statusCode, this.errorCode = ErrorCode.apiError});

  @override
  String toString() => message;
}

class NoInternetException implements Exception {
  final String message;
  final ErrorCode errorCode; // Tambahkan ErrorCode

  NoInternetException({this.message = 'Tidak ada koneksi internet.', this.errorCode = ErrorCode.noInternet});

  @override
  String toString() => message;
}