
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kalla_u_pro_bengkel/core/error/error_message_resolver.dart';
import 'package:kalla_u_pro_bengkel/core/services/auth_services.dart';
import 'package:kalla_u_pro_bengkel/core/services/fcm_service.dart';
import 'package:kalla_u_pro_bengkel/features/auth/data/models/login_response_model.dart';
import 'package:kalla_u_pro_bengkel/features/auth/data/repositories/auth_repositories.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository authRepository;
  final AuthService authService;
  final FcmService _fcmService; // Inject FcmService

  LoginCubit({
    required this.authRepository,
    required this.authService,
    required FcmService fcmService, // Tambahkan parameter
  }) : _fcmService = fcmService, // Inisialisasi
       super(LoginInitial());

  Future<void> attemptLogin({required String nik, required String password}) async {
    emit(LoginLoading());
    final result = await authRepository.login(nik, password);

    result.fold(
      (failure) {
        // Gunakan ErrorMessageResolver untuk mendapatkan pesan yang sesuai
        final userFriendlyMessage = ErrorMessageResolver.getMessage(failure);
        emit(LoginFailure(message: userFriendlyMessage));
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
    emit(LoginLoading()); // Opsional: emit state loading jika perlu
    try {
      await authService.logout(); // Hapus data sesi lokal dari AuthService
      await _fcmService.deleteFcmToken(); // Hapus FCM token
      emit(LoginInitial()); // Kembali ke state awal (atau state logged out khusus)
    } catch (e) {
      // Tangani error jika ada, mungkin emit LoginFailure
      emit(LoginFailure(message: "Logout gagal: ${e.toString()}"));
    }
  }
}
abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  // You might not need to pass the whole response to UI, 
  // but it can be useful.
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