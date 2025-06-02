import 'package:equatable/equatable.dart';
import 'package:kalla_u_pro_bengkel/core/error/error_codes.dart';

abstract class Failure extends Equatable {
  final String rawMessage; // Pesan asli dari exception/server (untuk logging/debugging)
  final ErrorCode errorCode;
  final int? statusCode; // HTTP status code jika relevan

  const Failure(
    this.rawMessage, {
    required this.errorCode,
    this.statusCode,
  });

  @override
  List<Object?> get props => [rawMessage, errorCode, statusCode];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure(super.rawMessage, {required super.errorCode, super.statusCode});
}

class CacheFailure extends Failure {
  const CacheFailure(super.rawMessage, {required super.errorCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.rawMessage, {required super.errorCode});
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.rawMessage, {required super.errorCode, super.statusCode});
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.rawMessage)
      : super(errorCode: ErrorCode.unknownError);
}