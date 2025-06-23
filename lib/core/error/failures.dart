import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:kalla_u_pro_bengkel/core/error/error_codes.dart';

class Failure extends Equatable {
  final String rawMessage;
  final ErrorCode errorCode;
  final int? statusCode;

  const Failure({
    required this.rawMessage,
    required this.errorCode,
    this.statusCode,
  });

  String get userMessage {
    switch (errorCode) {
      case ErrorCode.noInternet:
        return "Koneksi internet tidak terdeteksi. Mohon periksa jaringan Anda.";
      case ErrorCode.timeout:
        return "Waktu koneksi habis. Server mungkin sibuk, silakan coba lagi.";
      case ErrorCode.unauthorized:
        return "Sesi Anda telah berakhir. Silakan login kembali.";
      case ErrorCode.authenticationFailed:
        if (rawMessage.isNotEmpty && !rawMessage.toLowerCase().contains("exception") && !rawMessage.toLowerCase().contains("html")) {
          return rawMessage;
        }
        return "NIK atau password yang Anda masukkan salah. Mohon periksa kembali.";
      case ErrorCode.serverInternalError:
        return "Terjadi gangguan pada sistem kami (Kode: ${statusCode ?? 500}). Mohon coba lagi nanti.";
      case ErrorCode.apiError:
         // Jika pesan error dari server terlalu teknis (misal mengandung HTML), tampilkan pesan generik.
        if (rawMessage.isNotEmpty && !rawMessage.toLowerCase().contains("exception") && !rawMessage.toLowerCase().contains("html")) {
          return "Terjadi kendala: $rawMessage";
        }
        return "Layanan sedang mengalami kendala (Kode: ${statusCode ?? 'N/A'}). Mohon coba beberapa saat lagi.";
      case ErrorCode.invalidResponse:
        return "Gagal memproses respons dari server. Respon tidak valid.";
      default:
        return "Terjadi kesalahan yang tidak terduga. Mohon coba lagi.";
    }
  }

  @override
  List<Object?> get props => [rawMessage, errorCode, statusCode];

  factory Failure.fromException(Exception e) {
    if (e is DioException) {
      final statusCode = e.response?.statusCode;
      String message;

      // FIX: Cek tipe data dari response sebelum mengaksesnya
      if (e.response?.data is Map<String, dynamic>) {
        // Jika response adalah JSON Map, ambil 'message'
        message = e.response!.data['message'] ?? e.message ?? 'Unknown error message';
      } else if (e.response?.data is String && (e.response!.data as String).isNotEmpty) {
        // Jika response adalah String (seperti HTML), gunakan status message atau isi stringnya (jika pendek)
        // Untuk HTML, lebih baik menggunakan statusMessage agar tidak terlalu panjang.
        message = e.response?.statusMessage ?? e.response!.data;
      } else {
        // Fallback jika data null atau tipe tidak dikenal
        message = e.response?.statusMessage ?? e.message ?? 'Unknown DioException';
      }

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Failure(rawMessage: e.message ?? 'Timeout', errorCode: ErrorCode.timeout, statusCode: statusCode);

        case DioExceptionType.connectionError:
          return Failure(rawMessage: e.message ?? 'No Internet', errorCode: ErrorCode.noInternet, statusCode: statusCode);

        case DioExceptionType.badResponse:
           // Jika responsnya adalah HTML, kemungkinan besar ini adalah error server atau URL salah,
           // bukan sekadar API error biasa. Kita bisa kategorikan sebagai invalidResponse.
          if (e.response?.data is String && (e.response!.data as String).trim().toLowerCase().startsWith('<!doctype html')) {
              return Failure(rawMessage: message, errorCode: ErrorCode.invalidResponse, statusCode: statusCode);
          }

          if (statusCode == 401 || statusCode == 403) {
            final errorCode = e.requestOptions.path.contains('login')
                ? ErrorCode.authenticationFailed
                : ErrorCode.unauthorized;
            return Failure(rawMessage: message, errorCode: errorCode, statusCode: statusCode);
          }
          if (statusCode != null && statusCode >= 500) {
            return Failure(rawMessage: message, errorCode: ErrorCode.serverInternalError, statusCode: statusCode);
          }
          return Failure(rawMessage: message, errorCode: ErrorCode.apiError, statusCode: statusCode);

        default:
          return Failure(rawMessage: e.toString(), errorCode: ErrorCode.unknownError, statusCode: statusCode);
      }
    }
    return Failure(rawMessage: e.toString(), errorCode: ErrorCode.unknownError);
  }
}