import 'package:dio/dio.dart';
import 'package:kalla_u_pro_bengkel/core/error/error_codes.dart';
import 'package:kalla_u_pro_bengkel/core/error/exceptions.dart';
import 'package:kalla_u_pro_bengkel/features/auth/data/models/login_response_model.dart';
import 'package:kalla_u_pro_bengkel/core/util/constants.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(String nik, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<LoginResponseModel> login(String nik, String password) async {
    const url = ApiConstants.loginEndpoint;

    try {
      final response = await client.post(
        url,
        data: {'nik': nik, 'password': password},
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );
      // Dio secara default akan throw error untuk status non-2xx,
      // jadi tidak perlu `if (response.statusCode == 200)`
      return LoginResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      // Interceptor sudah mengubah DioException menjadi exception kustom kita.
      // Cukup rethrow agar bisa ditangkap oleh Repository.
      if (e is ServerException || e is GeneralException || e is NoInternetException) {
        rethrow;
      }
      // Fallback untuk error Dio yang tidak terduga
      throw ServerException(
        requestOptions: e.requestOptions,
        message: 'Kesalahan jaringan tidak terduga: ${e.message}',
        errorCode: ErrorCode.networkOther,
      );
    } catch (e) {
      // Menangkap error non-Dio, seperti error parsing JSON.
      throw ServerException(
        requestOptions: RequestOptions(path: url),
        message: 'Gagal memproses data: ${e.toString()}',
        errorCode: ErrorCode.invalidResponse,
      );
    }
  }
}