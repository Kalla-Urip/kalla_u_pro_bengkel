import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:kalla_u_pro_bengkel/common/app_colors.dart';
import 'package:kalla_u_pro_bengkel/common/app_routes.dart';
import 'package:kalla_u_pro_bengkel/common/image_resources.dart';
import 'package:kalla_u_pro_bengkel/core/services/auth_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = GetIt.instance<AuthService>();
  
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Simulate loading time
    await Future.delayed(const Duration(seconds: 2));
    
    // Check if user is logged in
    final isLoggedIn = await _authService.isLoggedIn();
    
    if (mounted) {
      if (isLoggedIn) {
        context.go(AppRoutes.main);
      } else {
        context.go(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Pattern SVG di background, posisi fit di bawah
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              ImageResources.patternPng,
              fit: BoxFit.contain,
            ),
          ),
          
          // Content layout dengan 2 bagian utama
          Column(
            children: [
              // Bagian tengah - App Icon dan U-pro text
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        ImageResources.appIconPng,
                        width: 100,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "U-pro",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bagian bawah - Powered by dan Logo
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Powered by:",
                      style: TextStyle(
                        color: AppColors.textGrey800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Image.asset(
                      ImageResources.kallaToyotaLogopng,
                      width: 200,
                      height: 80,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}