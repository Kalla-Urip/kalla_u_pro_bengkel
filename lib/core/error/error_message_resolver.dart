import 'failures.dart';
import 'error_codes.dart';

class ErrorMessageResolver {
  static String getMessage(Failure failure) {
    String defaultUserMessage;

    switch (failure.errorCode) {
      // Network Errors
      case ErrorCode.noInternet:
        defaultUserMessage = "Koneksi internet tidak terdeteksi. Mohon periksa kembali jaringan Anda, lalu coba lagi.";
        break;
      case ErrorCode.timeout:
        defaultUserMessage = "Waktu koneksi habis. Server mungkin sibuk atau jaringan Anda lambat. Silakan coba beberapa saat lagi.";
        break;
      case ErrorCode.networkOther:
         defaultUserMessage = "Terjadi masalah jaringan yang tidak dikenal. Mohon periksa koneksi Anda dan coba lagi.";
        break;

      // Authentication Errors
      case ErrorCode.authenticationFailed:
        // Pesan dari server (failure.rawMessage) mungkin lebih spesifik,
        // misalnya "NIK tidak ditemukan" atau "Password salah".
        // Jika pesan server ada dan dianggap cukup baik, kita bisa gunakan itu.
        // Untuk contoh ini, kita beri pesan yang lebih umum namun sopan.
        if (failure.rawMessage.isNotEmpty && _isPotentiallyUserFriendly(failure.rawMessage)) {
            defaultUserMessage = failure.rawMessage; // Gunakan pesan dari API jika dianggap layak
        } else {
            defaultUserMessage = "NIK atau password yang Anda masukkan salah. Mohon periksa kembali dan coba lagi.";
        }
        break;
      case ErrorCode.unauthorized:
        defaultUserMessage = "Sesi Anda telah berakhir atau tidak valid. Silakan login kembali.";
        break;

      // Server Errors
      case ErrorCode.serverInternalError:
        defaultUserMessage = "Terjadi gangguan pada sistem kami (Kode: ${failure.statusCode ?? 'Tidak Diketahui'}). Tim kami sedang menanganinya. Mohon coba lagi nanti.";
        break;
      case ErrorCode.apiError:
        // Jika API memberikan pesan error yang bisa ditampilkan ke user
        if (failure.rawMessage.isNotEmpty && _isPotentiallyUserFriendly(failure.rawMessage)) {
          defaultUserMessage = "Terjadi kendala: ${failure.rawMessage} (Kode: ${failure.statusCode ?? 'N/A'}).";
        } else {
          defaultUserMessage = "Layanan sedang mengalami kendala (Kode: ${failure.statusCode ?? 'N/A'}). Mohon coba beberapa saat lagi.";
        }
        break;
      case ErrorCode.invalidResponse:
        defaultUserMessage = "Gagal memproses respons dari server. Mohon coba lagi atau hubungi dukungan jika masalah berlanjut.";
        break;

      // Cache Errors
      case ErrorCode.cacheError:
        defaultUserMessage = "Gagal memuat data dari penyimpanan lokal. Mohon coba lagi.";
        break;
      
      // Unknown/Generic Error
      case ErrorCode.unknownError:
      default:
        defaultUserMessage = "Terjadi kesalahan yang tidak terduga. Kami mohon maaf atas ketidaknyamanannya, silakan coba lagi setelah beberapa saat.";
        break;
    }
    return defaultUserMessage;
  }

  /// Helper sederhana untuk mencoba menebak apakah pesan dari backend
  /// cukup ramah untuk ditampilkan langsung ke pengguna.
  /// Ini bisa disesuaikan atau dihilangkan jika ada kesepakatan
  /// format pesan error dengan tim backend.
  static bool _isPotentiallyUserFriendly(String message) {
    if (message.isEmpty) return false;
    // Hindari pesan yang terlalu teknis atau dalam bahasa Inggris default
    final lowerMessage = message.toLowerCase();
    if (lowerMessage.contains("exception") || 
        lowerMessage.contains("error code:") ||
        lowerMessage.contains("stacktrace") ||
        lowerMessage.contains("failed to connect") ||
        lowerMessage.contains("unexpected token") ||
        lowerMessage.contains("internal server error") && message.length > 100 // Generic internal server error, usually not for user
        ) {
      return false;
    }
    // Jika tidak ada tanda-tanda pesan teknis, anggap bisa ditampilkan
    return true; 
  }
}