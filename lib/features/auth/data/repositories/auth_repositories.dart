import 'package:dartz/dartz.dart';
import 'package:kalla_u_pro_bengkel/core/error/error_codes.dart';
import 'package:kalla_u_pro_bengkel/core/error/exceptions.dart';
import 'package:kalla_u_pro_bengkel/core/error/failures.dart';
import 'package:kalla_u_pro_bengkel/core/network/network_info.dart';
import 'package:kalla_u_pro_bengkel/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:kalla_u_pro_bengkel/features/auth/data/models/login_response_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, LoginResponseModel>> login(String nik, String password);
}


class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, LoginResponseModel>> login(String nik, String password) async {
    if (await networkInfo.isConnected()) {
      try {
        final remoteLoginResponse = await remoteDataSource.login(nik, password);
        return Right(remoteLoginResponse);
      } on GeneralException catch (e) { // Pesan dari API, seringkali untuk 4xx
        return Left(AuthenticationFailure(e.message, errorCode: e.errorCode, statusCode: e.statusCode));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message ?? 'Kesalahan server', errorCode: e.errorCode, statusCode: e.statusCode));
      } on NoInternetException catch (e) { 
        return Left(NetworkFailure(e.message, errorCode: e.errorCode));
      // } on DioException catch(e) { // Sebaiknya DioException sudah di-handle di DataSource
      //    // ...
      } catch (e) { 
        return Left(UnknownFailure('Terjadi kesalahan yang tidak diketahui: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('Tidak ada koneksi internet.', errorCode: ErrorCode.noInternet));
    }
  }
}