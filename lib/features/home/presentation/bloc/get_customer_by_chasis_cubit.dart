import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/chasis_customer_model.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/repositories/home_repository.dart';


class GetCustomerByChassisCubit extends Cubit<GetCustomerByChassisState> {
  final HomeRepository homeRepository;

  GetCustomerByChassisCubit({required this.homeRepository}) : super(GetCustomerByChassisInitial());

  Future<void> searchCustomerByChassisNumber(String chassisNumber) async {
    emit(GetCustomerByChassisLoading());
    final result = await homeRepository.getCustomerByChassisNumber(chassisNumber);
    result.fold(
      (failure) {
        emit(GetCustomerByChassisFailure(failure.userMessage));
      },
      (data) {
        if (data == null) {
          emit(const GetCustomerByChassisNotFound('Data customer tidak ditemukan.'));
        } else {
          emit(GetCustomerByChassisSuccess(data));
        }
      },
    );
  }
}


abstract class GetCustomerByChassisState extends Equatable {
  const GetCustomerByChassisState();
  @override
  List<Object> get props => [];
}

class GetCustomerByChassisInitial extends GetCustomerByChassisState {}
class GetCustomerByChassisLoading extends GetCustomerByChassisState {}
class GetCustomerByChassisSuccess extends GetCustomerByChassisState {
  final ChassisCustomerModel customer;
  const GetCustomerByChassisSuccess(this.customer);
  @override
  List<Object> get props => [customer];
}
class GetCustomerByChassisNotFound extends GetCustomerByChassisState {
  final String message;
  const GetCustomerByChassisNotFound(this.message);
  @override
  List<Object> get props => [message];
}
class GetCustomerByChassisFailure extends GetCustomerByChassisState {
  final String message;
  const GetCustomerByChassisFailure(this.message);
  @override
  List<Object> get props => [message];
}
