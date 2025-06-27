
import 'package:dio/dio.dart';
import 'package:kalla_u_pro_bengkel/core/services/auth_services.dart';
import 'package:kalla_u_pro_bengkel/core/util/global_navigator.dart';

class UnauthorizedInterceptor extends Interceptor {
  final AuthService authService;

  UnauthorizedInterceptor({required this.authService});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Cek jika error adalah 401 (Unauthorized) DAN bukan dari endpoint login itu sendiri
    if (err.response?.statusCode == 401 && !err.requestOptions.path.contains('/login')) {
      // 1. Tampilkan pesan kepada pengguna bahwa sesinya telah berakhir.
      GlobalNavigator.showSnackBar('Sesi Anda telah berakhir. Silakan login kembali.');

      // 2. Lakukan proses logout (menghapus token, dll).
      await authService.logout();

      // 3. Navigasikan pengguna kembali ke halaman login.
      GlobalNavigator.navigateToLogin();
      
      // Kita bisa menghentikan rantai error di sini jika mau,
      // karena navigasi sudah terjadi. Atau teruskan agar UI lokal
      // bisa bereaksi sebentar sebelum navigasi. Meneruskannya lebih aman.
      return handler.next(err);
    }
    
    // Untuk semua error lain, teruskan saja ke interceptor berikutnya atau ke Dio.
    return handler.next(err);
  }
}

