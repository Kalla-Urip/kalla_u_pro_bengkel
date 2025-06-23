import 'package:dartz/dartz.dart';
import 'package:kalla_u_pro_bengkel/core/error/error_codes.dart';
import 'package:kalla_u_pro_bengkel/core/error/failures.dart';
import 'package:kalla_u_pro_bengkel/core/network/network_info.dart';

class RequestHandler {
  final NetworkInfo networkInfo;

  RequestHandler({required this.networkInfo});

  Future<Either<Failure, T>> handle<T>(Future<T> Function() request) async {
    if (!await networkInfo.isConnected()) {
      return Left(Failure(rawMessage: 'No internet connection', errorCode: ErrorCode.noInternet));
    }
    try {
      final result = await request();
      return Right(result);
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    }
  }
}

