import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalla_u_pro_bengkel/common/app_routes.dart';
import 'package:kalla_u_pro_bengkel/common/app_themes.dart';
import 'package:kalla_u_pro_bengkel/di/service_locator.dart';
import 'package:kalla_u_pro_bengkel/features/auth/presentation/bloc/login_cubit.dart';

void main()  async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupServiceLocator();
  runApp(
    MultiBlocProvider(
      providers: [
        // Daftarkan LoginCubit di sini agar tersedia secara global
        BlocProvider<LoginCubit>(
          create: (context) => locator<LoginCubit>(),
        ),
      ],
      child: const MyApp(), // MyApp sekarang menjadi child dari MultiBlocProvider
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'U Pro Bengkel',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRoutes.router,
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

