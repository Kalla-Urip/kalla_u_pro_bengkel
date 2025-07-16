import 'package:equatable/equatable.dart';

// Main response model
class ServiceDetailResponseModel extends Equatable {
  final String? message;
  final ServiceDetailModel? data;

  const ServiceDetailResponseModel({this.message, this.data});

  factory ServiceDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return ServiceDetailResponseModel(
      message: json['message'] as String?,
      data: json['data'] != null
          ? ServiceDetailModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [message, data];
}

// Detailed service data model
class ServiceDetailModel extends Equatable {
  final int? id;
  final String? serviceDate;
  final String? serviceType;
  final String? note;
  final String? engineRoomCondition;
  final CarpetCondition? carpetCondition;
  final TireThicknessCondition? tireThicknessCondtion;
  final String? batteraiCondition;
  final String? fuelTotal;
  final int? kilometer;
  final Luggage? luggage;
  final BodyCondition? bodyCondition;
  final bool? tradeIn;
  final VehicleDetail? vehicle;
  final String? name;
  final String? birthDate;
  final String? insurance;

  const ServiceDetailModel({
    this.id,
    this.serviceDate,
    this.serviceType,
    this.note,
    this.engineRoomCondition,
    this.carpetCondition,
    this.tireThicknessCondtion,
    this.batteraiCondition,
    this.fuelTotal,
    this.kilometer,
    this.luggage,
    this.bodyCondition,
    this.tradeIn,
    this.vehicle,
    this.name,
    this.birthDate,
    this.insurance,
  });

  factory ServiceDetailModel.fromJson(Map<String, dynamic> json) {
    return ServiceDetailModel(
      id: json['id'] as int?,
      serviceDate: json['serviceDate'] as String?,
      serviceType: json['serviceType'] as String?,
      note: json['note'] as String?,
      engineRoomCondition: json['engineRoomCondition'] as String?,
      carpetCondition: json['carpetCondition'] != null
          ? CarpetCondition.fromJson(json['carpetCondition'] as Map<String, dynamic>)
          : null,
      tireThicknessCondtion: json['tireThicknessCondtion'] != null
          ? TireThicknessCondition.fromJson(json['tireThicknessCondtion'] as Map<String, dynamic>)
          : null,
      batteraiCondition: json['batteraiCondition'] as String?,
      fuelTotal: json['fuelTotal'] as String?,
      kilometer: json['kilometer'] as int?,
      luggage: json['luggage'] != null
          ? Luggage.fromJson(json['luggage'] as Map<String, dynamic>)
          : null,
      bodyCondition: json['bodyCondition'] != null
          ? BodyCondition.fromJson(json['bodyCondition'] as Map<String, dynamic>)
          : null,
      tradeIn: json['tradeIn'] as bool?,
      vehicle: json['Vehicle'] != null
          ? VehicleDetail.fromJson(json['Vehicle'] as Map<String, dynamic>)
          : null,
      name: json['name'] as String?,
      birthDate: json['birthDate'] as String?,
      insurance: json['insurance'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        serviceDate,
        serviceType,
        note,
        engineRoomCondition,
        carpetCondition,
        tireThicknessCondtion,
        batteraiCondition,
        fuelTotal,
        kilometer,
        luggage,
        bodyCondition,
        tradeIn,
        vehicle,
        name,
        birthDate,
        insurance
      ];
}

// Nested models
class CarpetCondition extends Equatable {
  final String? base;
  final String? driver;

  const CarpetCondition({this.base, this.driver});

  factory CarpetCondition.fromJson(Map<String, dynamic> json) {
    return CarpetCondition(
      base: json['base'] as String?,
      driver: json['driver'] as String?,
    );
  }

  @override
  List<Object?> get props => [base, driver];
}

class TireThicknessCondition extends Equatable {
  final String? frLh;
  final String? frRh;
  final String? rrLh;
  final String? rrRh;

  const TireThicknessCondition({this.frLh, this.frRh, this.rrLh, this.rrRh});

  factory TireThicknessCondition.fromJson(Map<String, dynamic> json) {
    return TireThicknessCondition(
      frLh: json['fr_lh'] as String?,
      frRh: json['fr_rh'] as String?,
      rrLh: json['rr_lh'] as String?,
      rrRh: json['rr_rh'] as String?,
    );
  }

  @override
  List<Object?> get props => [frLh, frRh, rrLh, rrRh];
}

class Luggage extends Equatable {
  final String? p3k;
  final String? stnk;
  final String? money;
  final String? booklet;
  final String? toolset;
  final String? umbrella;
  final String? triangleProtection;

  const Luggage({
    this.p3k,
    this.stnk,
    this.money,
    this.booklet,
    this.toolset,
    this.umbrella,
    this.triangleProtection,
  });

  factory Luggage.fromJson(Map<String, dynamic> json) {
    return Luggage(
      p3k: json['p3k'] as String?,
      stnk: json['stnk'] as String?,
      money: json['money'] as String?,
      booklet: json['booklet'] as String?,
      toolset: json['toolset'] as String?,
      umbrella: json['umbrella'] as String?,
      triangleProtection: json['triangle_protection'] as String?,
    );
  }

  @override
  List<Object?> get props => [p3k, stnk, money, booklet, toolset, umbrella, triangleProtection];
}

class BodyCondition extends Equatable {
  final String? kapMesin;
  final String? atapMobil;
  final String? spionKiri;
  final String? spionKanan;
  final String? bumperDepan;
  final String? bumperBelakang;
  final String? pintuDepanKiri;
  final String? fenderDepanKiri;
  final String? pintuDepanKanan;
  final String? fenderDepanKanan;
  final String? pintuBelakangKiri;
  final String? pintuBelakangKanan;
  final String? fenderBelakangKanan;

  const BodyCondition({
    this.kapMesin,
    this.atapMobil,
    this.spionKiri,
    this.spionKanan,
    this.bumperDepan,
    this.bumperBelakang,
    this.pintuDepanKiri,
    this.fenderDepanKiri,
    this.pintuDepanKanan,
    this.fenderDepanKanan,
    this.pintuBelakangKiri,
    this.pintuBelakangKanan,
    this.fenderBelakangKanan,
  });

  factory BodyCondition.fromJson(Map<String, dynamic> json) {
    return BodyCondition(
      kapMesin: json['kap_mesin'] as String?,
      atapMobil: json['atap_mobil'] as String?,
      spionKiri: json['spion_kiri'] as String?,
      spionKanan: json['spion_kanan'] as String?,
      bumperDepan: json['bumper_depan'] as String?,
      bumperBelakang: json['bumper_belakang'] as String?,
      pintuDepanKiri: json['pintu_depan_kiri'] as String?,
      fenderDepanKiri: json['fender_depan_kiri'] as String?,
      pintuDepanKanan: json['pintu_depan_kanan'] as String?,
      fenderDepanKanan: json['fender_depan_kanan'] as String?,
      pintuBelakangKiri: json['pintu_belakang_kiri'] as String?,
      pintuBelakangKanan: json['pintu_belakang_kanan'] as String?,
      fenderBelakangKanan: json['fender_belakang_kanan'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        kapMesin,
        atapMobil,
        spionKiri,
        spionKanan,
        bumperDepan,
        bumperBelakang,
        pintuDepanKiri,
        fenderDepanKiri,
        pintuDepanKanan,
        fenderDepanKanan,
        pintuBelakangKiri,
        pintuBelakangKanan,
        fenderBelakangKanan,
      ];
}

class VehicleDetail extends Equatable {
  final int? id;
  final String? chassisNumber;
  final String? plateNumber;
  final int? year;
  final String? insurance;
  final OwnerDetail? owner;

  const VehicleDetail({
    this.id,
    this.chassisNumber,
    this.plateNumber,
    this.year,
    this.insurance,
    this.owner,
  });

  factory VehicleDetail.fromJson(Map<String, dynamic> json) {
    return VehicleDetail(
      id: json['id'] as int?,
      chassisNumber: json['chassisNumber'] as String?,
      plateNumber: json['plateNumber'] as String?,
      year: json['year'] as int?,
      insurance: json['insurance'] as String?,
      owner: json['owner'] != null
          ? OwnerDetail.fromJson(json['owner'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, chassisNumber, plateNumber, year, insurance, owner];
}

class OwnerDetail extends Equatable {
  final int? id;
  final String? name;
  final String? phone;
  final String? address;

  const OwnerDetail({this.id, this.name, this.phone, this.address});

  factory OwnerDetail.fromJson(Map<String, dynamic> json) {
    return OwnerDetail(
      id: json['id'] as int?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, phone, address];
}
