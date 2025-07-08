import 'package:equatable/equatable.dart';

class ChassisCustomerResponseModel extends Equatable {
  final String? message;
  final ChassisCustomerModel? data; // Data can be null if not found

  const ChassisCustomerResponseModel({
    this.message,
    this.data,
  });

  factory ChassisCustomerResponseModel.fromJson(Map<String, dynamic> json) {
    return ChassisCustomerResponseModel(
      message: json['message'] as String?,
      data: json['data'] != null
          ? ChassisCustomerModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.toJson(),
    };
  }

  @override
  List<Object?> get props => [message, data];
}

class ChassisCustomerModel extends Equatable {
  final String? chassisNumber;
  final String? plateNumber;
  final int? year;
  final String? insurance;
  final int? typeId;
  final String? type;
  final String? name;
  final String? birthDate;
  final String? address;
  final bool? mToyota;
  final String? phone; // <-- [ADDED] Add the phone field

  const ChassisCustomerModel({
    this.chassisNumber,
    this.plateNumber,
    this.year,
    this.insurance,
    this.typeId,
    this.type,
    this.name,
    this.birthDate,
    this.address,
    this.mToyota,
    this.phone, // <-- [ADDED] Add to constructor
  });

  factory ChassisCustomerModel.fromJson(Map<String, dynamic> json) {
    return ChassisCustomerModel(
      chassisNumber: json['chassisNumber'] as String?,
      plateNumber: json['plateNumber'] as String?,
      year: json['year'] as int?,
      insurance: json['insurance'] as String?,
      typeId: json['typeId'] as int?,
      type: json['type'] as String?,
      name: json['name'] as String?,
      birthDate: json['birthDate'] as String?,
      address: json['address'] as String?,
      mToyota: json['mToyota'] as bool?,
      phone: json['phone'] as String?, // <-- [ADDED] Parse from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chassisNumber': chassisNumber,
      'plateNumber': plateNumber,
      'year': year,
      'insurance': insurance,
      'typeId': typeId,
      'type': type,
      'name': name,
      'birthDate': birthDate,
      'address': address,
      'mToyota': mToyota,
      'phone': phone, // <-- [ADDED] Add to JSON
    };
  }

  @override
  List<Object?> get props => [
        chassisNumber,
        plateNumber,
        year,
        insurance,
        typeId,
        type,
        name,
        birthDate,
        address,
        mToyota,
        phone, // <-- [ADDED] Add to props
      ];
}