import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/stall_model.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/repositories/home_repository.dart';

class GetStallsCubit extends Cubit<GetStallsState> {
  final HomeRepository homeRepository;

  GetStallsCubit({required this.homeRepository}) : super(GetStallsInitial());

  Future<void> fetchStalls() async {
    emit(GetStallsLoading());
    final result = await homeRepository.getStalls();
    result.fold(
      (failure) => emit(GetStallsFailure(failure.userMessage)),
      (data) => emit(GetStallsSuccess(data)),
    );
  }
}

abstract class GetStallsState extends Equatable {
  const GetStallsState();
  @override
  List<Object> get props => [];
}

class GetStallsInitial extends GetStallsState {}
class GetStallsLoading extends GetStallsState {}
class GetStallsSuccess extends GetStallsState {
  final List<StallModel> stalls;
  const GetStallsSuccess(this.stalls);
  @override
  List<Object> get props => [stalls];
}
class GetStallsFailure extends GetStallsState {
  final String message;
  const GetStallsFailure(this.message);
  @override
  List<Object> get props => [message];
}