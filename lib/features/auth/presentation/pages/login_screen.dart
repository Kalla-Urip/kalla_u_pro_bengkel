import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Masih diperlukan untuk context.read dan BlocConsumer
import 'package:go_router/go_router.dart';
import 'package:kalla_u_pro_bengkel/common/app_colors.dart';

import 'package:kalla_u_pro_bengkel/common/app_routes.dart';
import 'package:kalla_u_pro_bengkel/common/app_text_styles.dart';
import 'package:kalla_u_pro_bengkel/common/image_resources.dart';
import 'package:kalla_u_pro_bengkel/core/services/fcm_service.dart';
import 'package:kalla_u_pro_bengkel/di/service_locator.dart';
import 'package:kalla_u_pro_bengkel/features/auth/presentation/bloc/login_cubit.dart';
import 'package:kalla_u_pro_bengkel/core/util/utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nikController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nikController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _performLogin(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // Akses LoginCubit masih sama, karena sudah disediakan dari atas (main.dart)
    context.read<LoginCubit>().attemptLogin(
          nik: _nikController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    // BlocProvider<LoginCubit> yang sebelumnya ada di sini, DIHAPUS.
    // Scaffold sekarang menjadi root widget dari build method ini.
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: BlocConsumer<LoginCubit, LoginState>(
          // Tetap menggunakan BlocConsumer
          listener: (context, state) async {
            if (state is LoginSuccess) {
              final fcmService = locator<FcmService>();
              String? fcmToken = await fcmService.getFcmToken();

              // 2. Kirim ke Backend (jika token ada)
              if (fcmToken != null) {
                await fcmService.sendTokenToBackend(
                    fcmToken); // await agar selesai sebelum lanjut
              } else {
                if (kDebugMode)
                  print("Gagal mendapatkan FCM token setelah login.");
                // Pertimbangkan untuk mencoba lagi nanti atau memberitahu pengguna
              }

              // 3. Inisialisasi listener notifikasi FCM (foreground, background tap, terminated tap)
              // Berikan context dari navigator utama jika memungkinkan, atau context saat ini
              // Ini penting agar _handleNotificationTap bisa melakukan navigasi
              final rootContext =
                  AppRoutes.router.routerDelegate.navigatorKey.currentContext;
              if (rootContext != null) {
                await fcmService.initialize(rootContext);
              } else {
                await fcmService
                    .initialize(context); // fallback ke context saat ini
                if (kDebugMode)
                  print(
                      "Root context not available for FCM init, using LoginScreen context.");
              }

              // 4. Lanjutkan navigasi
              if (mounted) {
                // Pastikan widget masih ada di tree
                context.go(AppRoutes.main);
              }
            } else if (state is LoginFailure) {
              Utils.showErrorSnackBar(context, 'Login gagal: ${state.message}');
            }
          },
          builder: (context, state) {
            final isLoading = state is LoginLoading;

            return Stack(
              fit: StackFit.expand,
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                Image.asset(ImageResources.appIconPng,
                                    height: 45),
                                const SizedBox(height: 2),
                                const Text("U-pro",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text('Login',
                              style: AppTextStyles.headline1,
                              textAlign: TextAlign.center),
                          const SizedBox(height: 8),
                          const Text('Silahkan masukkan NIK dan password Anda',
                              style: AppTextStyles.body2,
                              textAlign: TextAlign.center),
                          const SizedBox(height: 24),
                          // NIK Input
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('NIK Karyawan',
                                  style: AppTextStyles.body2),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _nikController,
                                cursorColor: AppColors.primary,
                                decoration: const InputDecoration(
                                    hintText: 'Masukkan NIK Karyawan'),
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'NIK tidak boleh kosong';
                                  return null;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Password Input
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Password',
                                  style: AppTextStyles.body2),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                cursorColor: AppColors.primary,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan Password',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.grey),
                                    onPressed: _togglePasswordVisibility,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Password tidak boleh kosong';
                                  return null;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => _performLogin(context),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : const Text('Masuk'),
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.white,
                    padding: const EdgeInsets.only(bottom: 16, top: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Powered by:",
                            style:
                                TextStyle(color: Colors.black, fontSize: 12)),
                        const SizedBox(height: 4),
                        Image.asset(ImageResources.kallaToyotaLogopng,
                            width: 150, height: 50),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
