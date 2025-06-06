import 'package:equatable/equatable.dart';

// Model untuk satu item vehicle type
class VehicleTypeModel extends Equatable {
  final int id;
  final String name;

  const VehicleTypeModel({
    required this.id,
    required this.name,
  });

  factory VehicleTypeModel.fromJson(Map<String, dynamic> json) {
    return VehicleTypeModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  List<Object?> get props => [id, name];
}

// Model untuk keseluruhan response dari API
class VehicleTypeResponseModel extends Equatable {
  final String message;
  final List<VehicleTypeModel> data;

  const VehicleTypeResponseModel({
    required this.message,
    required this.data,
  });

  factory VehicleTypeResponseModel.fromJson(Map<String, dynamic> json) {
    return VehicleTypeResponseModel(
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => VehicleTypeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [message, data];
}