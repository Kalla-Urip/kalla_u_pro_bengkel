import 'package:equatable/equatable.dart';

class StallResponseModel {
  final String message;
  final List<StallModel> data;

  StallResponseModel({required this.message, required this.data});

  factory StallResponseModel.fromJson(Map<String, dynamic> json) {
    return StallResponseModel(
      message: json['message'],
      data: List<StallModel>.from(
          json['data'].map((x) => StallModel.fromJson(x))),
    );
  }
}

class StallModel extends Equatable {
  final int id;
  final String name;

  const StallModel({required this.id, required this.name});

  factory StallModel.fromJson(Map<String, dynamic> json) {
    return StallModel(
      id: json['id'],
      name: json['name'],
    );
  }

  @override
  List<Object?> get props => [id, name];
}