import 'package:dartz/dartz.dart';
import 'package:kalla_u_pro_bengkel/core/error/error_codes.dart';
import 'package:kalla_u_pro_bengkel/core/error/exceptions.dart';
import 'package:kalla_u_pro_bengkel/core/error/failures.dart';
import 'package:kalla_u_pro_bengkel/core/network/network_info.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/datasources/home_remote_data_source.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/vehicle_type_model.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<VehicleTypeModel>>> getVehicleTypes();
}

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<VehicleTypeModel>>> getVehicleTypes() async {
    if (await networkInfo.isConnected()) {
      try {
        final vehicleTypes = await remoteDataSource.getVehicleTypes();
        return Right(vehicleTypes);
      } on GeneralException catch (e) {
        // Endpoint ini mungkin juga butuh otentikasi, jadi tangani GeneralException
        return Left(AuthenticationFailure(e.message ?? 'Akses ditolak', errorCode: e.errorCode, statusCode: e.statusCode));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message ?? 'Kesalahan server', errorCode: e.errorCode, statusCode: e.statusCode));
      } on NoInternetException catch (e) {
        return Left(NetworkFailure(e.message ?? 'Tidak ada koneksi', errorCode: e.errorCode));
      } catch (e) {
        return Left(UnknownFailure('Terjadi kesalahan yang tidak diketahui: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('Tidak ada koneksi internet.', errorCode: ErrorCode.noInternet));
    }
  }
}