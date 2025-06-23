import 'package:dartz/dartz.dart';
import 'package:kalla_u_pro_bengkel/core/error/failures.dart';
import 'package:kalla_u_pro_bengkel/core/util/request_handler.dart';
// Impor RequestHandler yang baru dibuat
import 'package:kalla_u_pro_bengkel/features/home/data/datasources/home_remote_data_source.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/chasis_customer_model.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/mechanic_model.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/service_data_model.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/stall_model.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/vehicle_type_model.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<VehicleTypeModel>>> getVehicleTypes();
  Future<Either<Failure, void>> addCustomer(Map<String, dynamic> data);
  Future<Either<Failure, List<StallModel>>> getStalls();
  Future<Either<Failure, List<MechanicModel>>> getMechanics();
  Future<Either<Failure, List<ServiceDataModel>>> getServiceData();
  Future<Either<Failure, ChassisCustomerModel?>> getCustomerByChassisNumber(
      String chassisNumber); // New method
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
  Future<Either<Failure, List<ServiceDataModel>>> getServiceData() async {
    return requestHandler
        .handleRequest(() => remoteDataSource.getServiceData());
  }

  @override
  Future<Either<Failure, List<StallModel>>> getStalls() async {
    return requestHandler.handleRequest(() => remoteDataSource.getStalls());
  }

  @override
  Future<Either<Failure, List<MechanicModel>>> getMechanics() async {
    return requestHandler.handleRequest(() => remoteDataSource.getMechanics());
  }

  @override
  Future<Either<Failure, List<VehicleTypeModel>>> getVehicleTypes() async {
    // Cukup panggil handleRequest dan berikan fungsi pemanggilan data source
    return requestHandler
        .handleRequest(() => remoteDataSource.getVehicleTypes());
  }

  @override
  Future<Either<Failure, void>> addCustomer(Map<String, dynamic> data) async {
    // Logikanya sama untuk semua metode
    return requestHandler
        .handleRequest(() => remoteDataSource.addCustomer(data));
  }

  @override
  Future<Either<Failure, ChassisCustomerModel?>> getCustomerByChassisNumber(String chassisNumber) async {
    return requestHandler.handleRequest(() => remoteDataSource.getCustomerByChassisNumber(chassisNumber));
  }
}
