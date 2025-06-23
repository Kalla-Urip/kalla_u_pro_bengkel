import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kalla_u_pro_bengkel/core/error/failures.dart';
import 'package:kalla_u_pro_bengkel/core/services/auth_services.dart';
import 'package:kalla_u_pro_bengkel/core/services/fcm_service.dart';
import 'package:kalla_u_pro_bengkel/features/auth/data/models/login_response_model.dart';
import 'package:kalla_u_pro_bengkel/features/auth/data/repositories/auth_repositories.dart';

// States
abstract class LoginState extends Equatable {
  const LoginState();
  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}
class LoginLoading extends LoginState {}
class LoginSuccess extends LoginState {
  final LoginResponseModel loginResponse;
  const LoginSuccess({required this.loginResponse});
  @override
  List<Object?> get props => [loginResponse];
}
class LoginFailure extends LoginState {
  final String message;
  const LoginFailure({required this.message});
  @override
  List<Object?> get props => [message];
}

// Cubit
class LoginCubit extends Cubit<LoginState> {
  final AuthRepository authRepository;
  final AuthService authService;
  final FcmService _fcmService;

  LoginCubit({
    required this.authRepository,
    required this.authService,
    required FcmService fcmService,
  })  : _fcmService = fcmService,
        super(LoginInitial());

  Future<void> attemptLogin({required String nik, required String password}) async {
    emit(LoginLoading());
    final result = await authRepository.login(nik, password);

    result.fold(
      (failure) {
        // PERUBAHAN: Gunakan failure.userMessage secara langsung.
        emit(LoginFailure(message: failure.userMessage));
      },
      (loginResponse) async {
        try {
          await authService.login(
            loginResponse.user.name,
            loginResponse.user.nik,
            loginResponse.accessToken,
          );
          emit(LoginSuccess(loginResponse: loginResponse));
        } catch (e) {
          emit(LoginFailure(message: 'Gagal menyimpan sesi login: ${e.toString()}'));
        }
      },
    );
  }

  Future<void> logout() async {
    emit(LoginLoading());
    try {
      await authService.logout();
      await _fcmService.deleteFcmToken();
      emit(LoginInitial());
    } catch (e) {
      emit(LoginFailure(message: "Logout gagal: ${e.toString()}"));
    }
  }
}
