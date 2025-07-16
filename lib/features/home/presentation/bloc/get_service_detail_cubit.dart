import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/service_detail_model.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/repositories/home_repository.dart';

// States
abstract class GetServiceDetailState extends Equatable {
  const GetServiceDetailState();
  @override
  List<Object> get props => [];
}

class GetServiceDetailInitial extends GetServiceDetailState {}
class GetServiceDetailLoading extends GetServiceDetailState {}
class GetServiceDetailSuccess extends GetServiceDetailState {
  final ServiceDetailModel serviceDetail;
  const GetServiceDetailSuccess(this.serviceDetail);
  @override
  List<Object> get props => [serviceDetail];
}
class GetServiceDetailFailure extends GetServiceDetailState {
  final String message;
  const GetServiceDetailFailure(this.message);
  @override
  List<Object> get props => [message];
}

// Cubit
class GetServiceDetailCubit extends Cubit<GetServiceDetailState> {
  final HomeRepository homeRepository;

  GetServiceDetailCubit({required this.homeRepository}) : super(GetServiceDetailInitial());

  Future<void> fetchServiceDetail(int id) async {
    emit(GetServiceDetailLoading());
    final result = await homeRepository.getServiceDetail(id);
    result.fold(
      (failure) => emit(GetServiceDetailFailure(failure.userMessage)),
      (data) => emit(GetServiceDetailSuccess(data)),
    );
  }
}
