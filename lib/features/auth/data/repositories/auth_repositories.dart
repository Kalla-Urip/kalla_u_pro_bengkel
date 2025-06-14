import 'package:dartz/dartz.dart';
import 'package:kalla_u_pro_bengkel/core/error/failures.dart';
import 'package:kalla_u_pro_bengkel/core/util/request_handler.dart';
import 'package:kalla_u_pro_bengkel/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:kalla_u_pro_bengkel/features/auth/data/models/login_response_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, LoginResponseModel>> login(String nik, String password);
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  // Hapus NetworkInfo, ganti dengan RequestHandler
  final RequestHandler requestHandler;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.requestHandler, 
  });

  @override
  Future<Either<Failure, LoginResponseModel>> login(String nik, String password) async {
    return requestHandler.handleRequest(
      () => remoteDataSource.login(nik, password),
    );
  }
}