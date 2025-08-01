import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kalla_u_pro_bengkel/core/util/global_navigator.dart';
import 'package:kalla_u_pro_bengkel/features/auth/presentation/pages/login_screen.dart';
import 'package:kalla_u_pro_bengkel/features/auth/presentation/pages/splash_screen.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/pages/add_customer_screen.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/pages/main_screen.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/pages/service_detail_screen.dart';
import 'package:kalla_u_pro_bengkel/features/profile/presentation/pages/profile_screen.dart';
import 'package:kalla_u_pro_bengkel/main.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String main = '/main';
  static const String profile = '/profile';
  static const String addCustomer = '/add-customer';
  static const String serviceDetail = '/service-detail';


  // GoRouter configuration
  static final router = GoRouter(
    navigatorKey: GlobalNavigator.navigatorKey,
    initialLocation: splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) =>  const LoginScreen(),
      ),
      GoRoute(
        path: main,
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: profile,
        builder: (context, state) => const ProfileScreen(),
      ),
       GoRoute(
        path: addCustomer,
        builder: (context, state) => const AddCustomerScreen(),
      ),
      GoRoute(
        path: '$serviceDetail/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return ServiceDetailScreen(serviceId: id);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );



}