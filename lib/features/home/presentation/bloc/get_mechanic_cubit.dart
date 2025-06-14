import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kalla_u_pro_bengkel/core/error/error_message_resolver.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/mechanic_model.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/repositories/home_repository.dart';



class GetMechanicsCubit extends Cubit<GetMechanicsState> {
  final HomeRepository homeRepository;

  GetMechanicsCubit({required this.homeRepository}) : super(GetMechanicsInitial());

  Future<void> fetchMechanics() async {
    emit(GetMechanicsLoading());
    final result = await homeRepository.getMechanics();
    result.fold(
      (failure) => emit(GetMechanicsFailure(ErrorMessageResolver.getMessage(failure))),
      (data) => emit(GetMechanicsSuccess(data)),
    );
  }
}

abstract class GetMechanicsState extends Equatable {
  const GetMechanicsState();
  @override
  List<Object> get props => [];
}

class GetMechanicsInitial extends GetMechanicsState {}
class GetMechanicsLoading extends GetMechanicsState {}
class GetMechanicsSuccess extends GetMechanicsState {
  final List<MechanicModel> mechanics;
  const GetMechanicsSuccess(this.mechanics);
  @override
  List<Object> get props => [mechanics];
}
class GetMechanicsFailure extends GetMechanicsState {
  final String message;
  const GetMechanicsFailure(this.message);
  @override
  List<Object> get props => [message];
}