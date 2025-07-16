import 'package:dartz/dartz.dart';
import 'package:kalla_u_pro_bengkel/core/error/failures.dart';
import 'package:kalla_u_pro_bengkel/core/util/request_handler.dart'; // Impor RequestHandler
import 'package:kalla_u_pro_bengkel/features/home/data/datasources/home_remote_data_source.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/chasis_customer_model.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/mechanic_model.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/service_data_model.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/service_detail_model.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/stall_model.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/vehicle_type_model.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<VehicleTypeModel>>> getVehicleTypes();
  Future<Either<Failure, void>> addCustomer(Map<String, dynamic> data);
  Future<Either<Failure, List<StallModel>>> getStalls();
  Future<Either<Failure, List<MechanicModel>>> getMechanics();
  Future<Either<Failure, List<ServiceDataModel>>> getServiceData();
  Future<Either<Failure, ChassisCustomerModel?>> getCustomerByChassisNumber(
      String chassisNumber);
  Future<Either<Failure, ServiceDetailModel>> getServiceDetail(int id);
}

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final RequestHandler requestHandler;

  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.requestHandler,
  });

  @override
  Future<Either<Failure, List<VehicleTypeModel>>> getVehicleTypes() {
    return requestHandler.handle(() => remoteDataSource.getVehicleTypes());
  }
  
  @override
  Future<Either<Failure, void>> addCustomer(Map<String, dynamic> data) {
    return requestHandler.handle(() => remoteDataSource.addCustomer(data));
  }

  @override
  Future<Either<Failure, List<StallModel>>> getStalls() {
    return requestHandler.handle(() => remoteDataSource.getStalls());
  }

  @override
  Future<Either<Failure, List<MechanicModel>>> getMechanics() {
    return requestHandler.handle(() => remoteDataSource.getMechanics());
  }

  @override
  Future<Either<Failure, List<ServiceDataModel>>> getServiceData() {
    return requestHandler.handle(() => remoteDataSource.getServiceData());
  }

  @override
  Future<Either<Failure, ChassisCustomerModel?>> getCustomerByChassisNumber(String chassisNumber) {
    return requestHandler.handle(() => remoteDataSource.getCustomerByChassisNumber(chassisNumber));
  }
  @override
  Future<Either<Failure, ServiceDetailModel>> getServiceDetail(int id) {
    return requestHandler.handle(() => remoteDataSource.getServiceDetail(id));
  }
}