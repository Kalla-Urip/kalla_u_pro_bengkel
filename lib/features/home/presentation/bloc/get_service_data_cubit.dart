import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kalla_u_pro_bengkel/core/error/error_message_resolver.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/service_data_model.dart'; // Import new model
import 'package:kalla_u_pro_bengkel/features/home/data/repositories/home_repository.dart';

class GetServiceDataCubit extends Cubit<GetServiceDataState> {
  final HomeRepository homeRepository;

  GetServiceDataCubit({required this.homeRepository}) : super(GetServiceDataInitial());

  Future<void> fetchServiceData() async {
    emit(GetServiceDataLoading());
    final result = await homeRepository.getServiceData();
    result.fold(
      (failure) => emit(GetServiceDataFailure(ErrorMessageResolver.getMessage(failure))),
      (data) => emit(GetServiceDataSuccess(data)),
    );
  }
}

abstract class GetServiceDataState extends Equatable {
  const GetServiceDataState();
  @override
  List<Object> get props => [];
}

class GetServiceDataInitial extends GetServiceDataState {}
class GetServiceDataLoading extends GetServiceDataState {}
class GetServiceDataSuccess extends GetServiceDataState {
  final List<ServiceDataModel> serviceData;
  const GetServiceDataSuccess(this.serviceData);
  @override
  List<Object> get props => [serviceData];
}
class GetServiceDataFailure extends GetServiceDataState {
  final String message;
  const GetServiceDataFailure(this.message);
  @override
  List<Object> get props => [message];
}
