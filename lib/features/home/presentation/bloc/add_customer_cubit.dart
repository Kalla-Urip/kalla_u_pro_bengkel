// features/home/presentation/bloc/add_customer_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kalla_u_pro_bengkel/core/error/error_message_resolver.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/repositories/home_repository.dart';

// States
abstract class AddCustomerState extends Equatable {
  const AddCustomerState();
  @override
  List<Object> get props => [];
}

class AddCustomerInitial extends AddCustomerState {}

class AddCustomerLoading extends AddCustomerState {}

class AddCustomerSuccess extends AddCustomerState {}

class AddCustomerFailure extends AddCustomerState {
  final String message;
  const AddCustomerFailure(this.message);
  @override
  List<Object> get props => [message];
}

// Cubit
class AddCustomerCubit extends Cubit<AddCustomerState> {
  final HomeRepository homeRepository;

  AddCustomerCubit({required this.homeRepository}) : super(AddCustomerInitial());

  Future<void> submitCustomerData(Map<String, dynamic> data) async {
    emit(AddCustomerLoading());
    final result = await homeRepository.addCustomer(data);
    result.fold(
      (failure) {
        final errorMessage = ErrorMessageResolver.getMessage(failure);
        emit(AddCustomerFailure(errorMessage));
      },
      (_) {
        // Success
        emit(AddCustomerSuccess());
      },
    );
  }
}