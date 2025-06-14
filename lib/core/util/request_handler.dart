import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:kalla_u_pro_bengkel/core/error/error_codes.dart';
import 'package:kalla_u_pro_bengkel/core/error/exceptions.dart';
import 'package:kalla_u_pro_bengkel/core/error/failures.dart';
import 'package:kalla_u_pro_bengkel/core/network/network_info.dart';

class RequestHandler {
  final NetworkInfo networkInfo;

  RequestHandler({required this.networkInfo});

  /// Menangani pemanggilan API dan mengubah error menjadi Failure.
  /// Dapat digunakan oleh semua repository.
  Future<Either<Failure, T>> handleRequest<T>(Future<T> Function() request) async {
    if (!await networkInfo.isConnected()) {
      return const Left(NetworkFailure('Tidak ada koneksi internet.', errorCode: ErrorCode.noInternet));
    }
    try {
      final result = await request();
      return Right(result);
    } on DioException catch (e) {
      // Petakan DioException (termasuk exception kustom kita) ke Failure
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      // Tangani error lain yang tidak terduga
      return Left(UnknownFailure('Terjadi kesalahan yang tidak diketahui: ${e.toString()}'));
    }
  }

  /// Helper privat untuk memetakan Exception dari Dio ke Failure yang sesuai.
  Failure _mapExceptionToFailure(DioException e) {
    if (e is ServerException) {
      return ServerFailure(e.message ?? 'Kesalahan server', errorCode: e.errorCode, statusCode: e.statusCode);
    }
    if (e is NoInternetException) {
      return NetworkFailure(e.message ?? 'Tidak ada koneksi', errorCode: e.errorCode);
    }
    if (e is GeneralException) {
      return AuthenticationFailure(e.message ?? 'Akses ditolak', errorCode: e.errorCode, statusCode: e.statusCode);
    }
    // Fallback untuk DioException lain yang mungkin belum ditangani
    return UnknownFailure('Kesalahan jaringan tidak terduga: ${e.message}');
  }
}