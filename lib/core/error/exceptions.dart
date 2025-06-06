
import 'package:dio/dio.dart';
import 'package:kalla_u_pro_bengkel/core/error/error_codes.dart';

class ServerException extends DioException {
  ServerException({
    required super.requestOptions,
    String message = 'Terjadi kesalahan pada server.',
    this.statusCode,
    this.errorCode = ErrorCode.serverInternalError,
  }) : super(message: message);

  final int? statusCode;
  final ErrorCode errorCode;

  @override
  String toString() => message ?? 'Terjadi kesalahan pada server (Kode Internal: ${errorCode.name}).';
}

class NoInternetException extends DioException {
  NoInternetException({
    required super.requestOptions,
    String message = 'Tidak ada koneksi internet.',
    this.errorCode = ErrorCode.noInternet,
  }) : super(message: message);

  final ErrorCode errorCode;

  @override
  String toString() => message ?? 'Tidak ada koneksi internet.';
}

class GeneralException extends DioException {
   GeneralException({
    required super.requestOptions,
    required String message,
    this.statusCode,
    this.errorCode = ErrorCode.apiError,
  }) : super(message: message);
  
  final int? statusCode;
  final ErrorCode errorCode;
}