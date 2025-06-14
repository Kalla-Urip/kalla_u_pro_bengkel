import 'package:dartz/dartz.dart';
import 'package:kalla_u_pro_bengkel/core/error/failures.dart';
import 'package:kalla_u_pro_bengkel/core/util/request_handler.dart';
// Impor RequestHandler yang baru dibuat
import 'package:kalla_u_pro_bengkel/features/home/data/datasources/home_remote_data_source.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/vehicle_type_model.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<VehicleTypeModel>>> getVehicleTypes();
  Future<Either<Failure, void>> addCustomer(Map<String, dynamic> data);
}

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  // Hapus NetworkInfo, ganti dengan RequestHandler
  final RequestHandler requestHandler;

  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.requestHandler, // Inject RequestHandler
  });

  @override
  Future<Either<Failure, List<VehicleTypeModel>>> getVehicleTypes() async {
    // Cukup panggil handleRequest dan berikan fungsi pemanggilan data source
    return requestHandler.handleRequest(() => remoteDataSource.getVehicleTypes());
  }

  @override
  Future<Either<Failure, void>> addCustomer(Map<String, dynamic> data) async {
    // Logikanya sama untuk semua metode
    return requestHandler.handleRequest(() => remoteDataSource.addCustomer(data));
  }
}