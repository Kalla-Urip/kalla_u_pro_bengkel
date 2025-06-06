import 'package:dio/dio.dart';
import 'package:kalla_u_pro_bengkel/core/error/error_codes.dart';
import 'package:kalla_u_pro_bengkel/core/error/exceptions.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/vehicle_type_model.dart';
import 'package:kalla_u_pro_bengkel/util/constants.dart';

abstract class HomeRemoteDataSource {
  Future<List<VehicleTypeModel>> getVehicleTypes();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio client;

  HomeRemoteDataSourceImpl({required this.client});

  @override
  Future<List<VehicleTypeModel>> getVehicleTypes() async {
    const url = ApiConstants.vehicleTypeEndpoint;

    try {
      final response = await client.get(url);
      // Logika sukses, tidak perlu cek status code di sini
      final vehicleTypeResponse = VehicleTypeResponseModel.fromJson(response.data);
      return vehicleTypeResponse.data;
    } on DioException catch (e) {
      // Logika yang sama persis seperti di AuthRemoteDataSource
      if (e is ServerException || e is GeneralException || e is NoInternetException) {
        rethrow;
      }
      // Fallback
      throw ServerException(
        requestOptions: e.requestOptions,
        message: 'Kesalahan jaringan tidak terduga: ${e.message}',
        errorCode: ErrorCode.networkOther,
      );
    } catch (e) {
      // Menangkap error non-Dio
      throw ServerException(
        requestOptions: RequestOptions(path: url),
        message: 'Gagal memproses data: ${e.toString()}',
        errorCode: ErrorCode.invalidResponse,
      );
    }
  }
}