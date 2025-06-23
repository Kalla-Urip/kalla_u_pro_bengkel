import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/vehicle_type_model.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/repositories/home_repository.dart';



class GetVehicleTypeCubit extends Cubit<GetVehicleTypeState> {
  final HomeRepository homeRepository;

  GetVehicleTypeCubit({required this.homeRepository}) : super(GetVehicleTypeInitial());

  Future<void> fetchVehicleTypes() async {
    emit(GetVehicleTypeLoading());
    final result = await homeRepository.getVehicleTypes();
    result.fold(
      (failure) {
        // PERUBAHAN: Gunakan failure.userMessage secara langsung.
        emit(GetVehicleTypeFailure(failure.userMessage));
      },
      (data) {
        if (data.isEmpty) {
          emit(const GetVehicleTypeFailure("Data tipe kendaraan tidak ditemukan."));
        } else {
          emit(GetVehicleTypeSuccess(data));
        }
      },
    );
  }
}



abstract class GetVehicleTypeState extends Equatable {
  const GetVehicleTypeState();
  @override
  List<Object> get props => [];
}

class GetVehicleTypeInitial extends GetVehicleTypeState {}

class GetVehicleTypeLoading extends GetVehicleTypeState {}

class GetVehicleTypeSuccess extends GetVehicleTypeState {
  final List<VehicleTypeModel> vehicleTypes;
  const GetVehicleTypeSuccess(this.vehicleTypes);
  @override
  List<Object> get props => [vehicleTypes];
}

class GetVehicleTypeFailure extends GetVehicleTypeState {
  final String message;
  const GetVehicleTypeFailure(this.message);
  @override
  List<Object> get props => [message];
}
