import 'package:dio/dio.dart';
import 'package:kalla_u_pro_bengkel/core/error/error_codes.dart';
import 'package:kalla_u_pro_bengkel/core/error/exceptions.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/mechanic_model.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/service_data_model.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/stall_model.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/vehicle_type_model.dart';
import 'package:kalla_u_pro_bengkel/core/util/constants.dart';

abstract class HomeRemoteDataSource {
  Future<List<VehicleTypeModel>> getVehicleTypes();
  Future<void> addCustomer(Map<String, dynamic> data);
  Future<List<StallModel>> getStalls();
  Future<List<MechanicModel>> getMechanics();
  Future<List<ServiceDataModel>> getServiceData();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio client;

  HomeRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ServiceDataModel>> getServiceData() async {
    const url = ApiConstants.serviceData;

    try {
      final response = await client.get(url);
      final serviceDataResponse = ServiceDataResponseModel.fromJson(response.data);
      // Return an empty list if data is null for safety
      return serviceDataResponse.data ?? []; 
    } on DioException {
      rethrow;
    } catch (e) {
      throw ServerException(
        requestOptions: RequestOptions(path: url),
        message: 'Gagal memproses data layanan: ${e.toString()}',
        errorCode: ErrorCode.invalidResponse,
      );
    }
  }

  @override
  Future<List<StallModel>> getStalls() async {
    const url = ApiConstants.stallEndPoint; // Gunakan endpoint relatif
    try {
      final response = await client.get(url);
      final stallResponse = StallResponseModel.fromJson(response.data);
      return stallResponse.data;
    } on DioException {
      rethrow;
    } catch (e) {
      throw ServerException(
        requestOptions: RequestOptions(path: url),
        message: 'Gagal memproses data stall: ${e.toString()}',
        errorCode: ErrorCode.invalidResponse,
      );
    }
  }

  @override
  Future<List<MechanicModel>> getMechanics() async {
    const url = ApiConstants.mechanicEndpoint; // Gunakan endpoint relatif
    try {
      final response = await client.get(url);
      final mechanicResponse = MechanicResponseModel.fromJson(response.data);
      return mechanicResponse.data;
    } on DioException {
      rethrow;
    } catch (e) {
      throw ServerException(
        requestOptions: RequestOptions(path: url),
        message: 'Gagal memproses data mekanik: ${e.toString()}',
        errorCode: ErrorCode.invalidResponse,
      );
    }
  }

  @override
  Future<List<VehicleTypeModel>> getVehicleTypes() async {
    const url = ApiConstants.vehicleTypeEndpoint;

    try {
      final response = await client.get(url);
      // Fokus pada parsing data. Jika client.get() gagal,
      // interceptor akan melempar exception kustom dan blok catch akan menangkapnya.
      final vehicleTypeResponse = VehicleTypeResponseModel.fromJson(response.data);
      return vehicleTypeResponse.data;
    } on DioException {
      // Biarkan error dari interceptor langsung dilempar ke atas.
      rethrow;
    } catch (e) {
      // Tangkap error lain, terutama dari parsing JSON atau error tak terduga.
      // Ini adalah fallback yang bagus.
      throw ServerException(
        requestOptions: RequestOptions(path: url),
        message: 'Gagal memproses data respons: ${e.toString()}',
        errorCode: ErrorCode.invalidResponse,
      );
    }
  }

  @override
  Future<void> addCustomer(Map<String, dynamic> data) async {
    const url = ApiConstants.addCustomerEndpoint;
    try {
      final formData = FormData.fromMap(data);
      final response = await client.post(
        url,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      // Logika bisnis spesifik untuk endpoint ini.
      // Interceptor tidak tahu bahwa endpoint ini butuh status 201.
      if (response.statusCode != 201) {
        throw ServerException(
          requestOptions: response.requestOptions,
          message: 'Gagal menyimpan data, server merespon dengan status ${response.statusCode}',
          errorCode: ErrorCode.apiError, // Kode error yang sesuai
          statusCode: response.statusCode,
        );
      }
      // Jika status 201, metode selesai tanpa return (Future<void>)
    } on DioException {
      // Sama seperti di atas, cukup lemparkan kembali exception
      // yang sudah disiapkan oleh interceptor.
      rethrow;
    } catch (e) {
      // Jika exception yang dilempar bukan DioException (misalnya dari throw ServerException di atas)
      // atau error lainnya, lemparkan kembali atau bungkus jika perlu.
      if (e is ServerException) rethrow; // Jangan bungkus ulang exception kustom kita

      // Fallback untuk error lainnya
      throw ServerException(
        requestOptions: RequestOptions(path: url),
        message: 'Terjadi kesalahan tak terduga: ${e.toString()}',
        errorCode: ErrorCode.invalidResponse,
      );
    }
  }
}