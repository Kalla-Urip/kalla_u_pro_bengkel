import 'package:dio/dio.dart';
import 'package:kalla_u_pro_bengkel/core/util/constants.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/chasis_customer_model.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/mechanic_model.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/service_data_model.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/service_detail_model.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/stall_model.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/vehicle_type_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<VehicleTypeModel>> getVehicleTypes();
  Future<void> addCustomer(Map<String, dynamic> data);
  Future<List<StallModel>> getStalls();
  Future<List<MechanicModel>> getMechanics();
  Future<List<ServiceDataModel>> getServiceData();
  Future<ChassisCustomerModel?> getCustomerByChassisNumber(String chassisNumber);
  Future<ServiceDetailModel> getServiceDetail(int id);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio client;
  // FIX: Add a separate Dio client for customer-related APIs.
  final Dio customerClient;

  // FIX: Update the constructor to accept the new client.
  HomeRemoteDataSourceImpl({required this.client, required this.customerClient});

  @override
  Future<void> addCustomer(Map<String, dynamic> data) async {
    await client.post(
      ApiConstants.addCustomerEndpoint,
      data: data,
      options: Options(
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      ),
    );
  }

  @override
  Future<ChassisCustomerModel?> getCustomerByChassisNumber(String chassisNumber) async {
    final url = '${ApiConstants.customerChasis}/$chassisNumber';
    final response = await client.get(url);
    final chassisCustomerResponse = ChassisCustomerResponseModel.fromJson(response.data);
    return chassisCustomerResponse.data;
  }

  @override
  Future<List<MechanicModel>> getMechanics() async {
    final response = await client.get(ApiConstants.mechanicEndpoint);
    final mechanicResponse = MechanicResponseModel.fromJson(response.data);
    return mechanicResponse.data ?? [];
  }

  @override
  Future<List<ServiceDataModel>> getServiceData() async {
    final response = await client.get(ApiConstants.serviceData);
    final serviceDataResponse = ServiceDataResponseModel.fromJson(response.data);
    return serviceDataResponse.data ?? [];
  }

  @override
  Future<List<StallModel>> getStalls() async {
    final response = await client.get(ApiConstants.stallEndPoint);
    final stallResponse = StallResponseModel.fromJson(response.data);
    return stallResponse.data ?? [];
  }

  @override
  Future<List<VehicleTypeModel>> getVehicleTypes() async {
    final response = await client.get(ApiConstants.vehicleTypeEndpoint);
    final vehicleTypeResponse = VehicleTypeResponseModel.fromJson(response.data);
    return vehicleTypeResponse.data ?? [];
  }

  // FIX: This method now uses the dedicated 'customerClient'.
  @override
  Future<ServiceDetailModel> getServiceDetail(int id) async {
    final url = '${ApiConstants.serviceDetail}/$id';
    // Use the customerClient which has the correct base URL ('.../mobile').
    final response = await customerClient.get(url);
    final serviceDetailResponse = ServiceDetailResponseModel.fromJson(response.data);
    if (serviceDetailResponse.data != null) {
      return serviceDetailResponse.data!;
    } else {
      throw Exception('Failed to get service detail data');
    }
  }
}
