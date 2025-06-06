import 'dart:io';
import 'package:dio/dio.dart';
import 'package:kalla_u_pro_bengkel/core/error/error_codes.dart';
import 'package:kalla_u_pro_bengkel/core/error/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Panggil handler.next(err) untuk melanjutkan rantai error.
    // Di sini kita akan membuat exception kustom berdasarkan tipe error Dio.
    
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        // Cukup teruskan exception NoInternetException.
        // Data source akan menangkapnya.
        return handler.next(
          NoInternetException(
            message: 'Waktu koneksi habis. Mohon periksa koneksi internet Anda.',
            errorCode: ErrorCode.timeout,
            requestOptions: err.requestOptions,
          ),
        );

      case DioExceptionType.connectionError:
      case DioExceptionType.badResponse:
        // Cek jika error disebabkan oleh masalah konektivitas (misal tidak ada internet)
        if (err.error is SocketException) {
          return handler.next(
            NoInternetException(
              message: 'Gagal terhubung ke server. Mohon periksa koneksi internet Anda.',
              errorCode: ErrorCode.noInternet,
              requestOptions: err.requestOptions,
            ),
          );
        }
        
        // Handle error dari response server (misal 4xx, 5xx)
        if (err.response != null) {
          final statusCode = err.response?.statusCode;
          final errorMessage = err.response?.data?['message'] ?? 
                               err.response?.data?['status'] ?? 
                               'Terjadi kesalahan dari server.';
          
          if (statusCode == 401) {
            return handler.next(
              GeneralException( // Gunakan GeneralException untuk error spesifik seperti 401
                message: errorMessage,
                statusCode: statusCode,
                errorCode: ErrorCode.authenticationFailed,
                requestOptions: err.requestOptions,
              ),
            );
          }
          
          return handler.next(
            ServerException(
              message: errorMessage,
              statusCode: statusCode,
              errorCode: ErrorCode.apiError,
              requestOptions: err.requestOptions,
            ),
          );
        }
        
        // Fallback untuk error badResponse lainnya
        return handler.next(err);

      default:
        // Untuk error lainnya (cancel, unknown), teruskan saja error aslinya.
        return handler.next(err);
    }
  }
}
