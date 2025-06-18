import 'package:equatable/equatable.dart';

class ServiceDataResponseModel extends Equatable {
  final String? message; // Made nullable for safety
  final List<ServiceDataModel>? data; // Made nullable for safety

  const ServiceDataResponseModel({
    this.message,
    this.data,
  });

  factory ServiceDataResponseModel.fromJson(Map<String, dynamic> json) {
    return ServiceDataResponseModel(
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((x) => ServiceDataModel.fromJson(x as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.map((x) => x.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [message, data];
}

class ServiceDataModel extends Equatable {
  final int? id; // Made nullable for safety
  final String? owner; // Made nullable for safety
  final String? plateNumber; // Made nullable for safety
  final int? year; // Made nullable for safety
  final String? type; // Made nullable for safety

  const ServiceDataModel({
    this.id,
    this.owner,
    this.plateNumber,
    this.year,
    this.type,
  });

  factory ServiceDataModel.fromJson(Map<String, dynamic> json) {
    return ServiceDataModel(
      id: json['id'] as int?,
      owner: json['owner'] as String?,
      plateNumber: json['plateNumber'] as String?,
      year: json['year'] as int?,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner': owner,
      'plateNumber': plateNumber,
      'year': year,
      'type': type,
    };
  }

  @override
  List<Object?> get props => [id, owner, plateNumber, year, type];
}
