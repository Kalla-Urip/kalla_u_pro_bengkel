// kalla_u_pro_bengkel/features/auth/data/models/user_model.dart
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String name;
  final String nik;

  const UserModel({
    required this.name,
    required this.nik,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] as String,
      nik: json['nik'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nik': nik,
    };
  }

  @override
  List<Object?> get props => [name, nik];
}



class LoginResponseModel extends Equatable {
  final String message;
  final String accessToken;
  final UserModel user;

  const LoginResponseModel({
    required this.message,
    required this.accessToken,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      message: json['message'] as String,
      accessToken: json['data']['accessToken'] as String,
      user: UserModel.fromJson(json['data']['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': {
        'accessToken': accessToken,
        'user': user.toJson(),
      }
    };
  }

  @override
  List<Object?> get props => [message, accessToken, user];
}