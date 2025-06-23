import 'package:dio/dio.dart';
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
    final response = await client.post(
      ApiConstants.loginEndpoint,
      data: {'nik': nik, 'password': password},
      options: Options(
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      ),
    );
    return LoginResponseModel.fromJson(response.data);
  }
}