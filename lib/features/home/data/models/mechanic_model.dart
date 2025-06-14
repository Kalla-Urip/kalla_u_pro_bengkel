import 'package:equatable/equatable.dart';

class MechanicResponseModel {
  final String message;
  final List<MechanicModel> data;

  MechanicResponseModel({required this.message, required this.data});

  factory MechanicResponseModel.fromJson(Map<String, dynamic> json) {
    return MechanicResponseModel(
      message: json['message'],
      data: List<MechanicModel>.from(
          json['data'].map((x) => MechanicModel.fromJson(x))),
    );
  }
}

class MechanicModel extends Equatable {
  final int id;
  final String name;
  final String nik;

  const MechanicModel({required this.id, required this.name, required this.nik});

  factory MechanicModel.fromJson(Map<String, dynamic> json) {
    return MechanicModel(
      id: json['id'],
      name: json['name'],
      nik: json['nik'],
    );
  }

  @override
  List<Object?> get props => [id, name, nik];
}