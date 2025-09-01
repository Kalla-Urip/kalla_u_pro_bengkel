import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalla_u_pro_bengkel/common/app_routes.dart';
import 'package:kalla_u_pro_bengkel/common/app_themes.dart';
import 'package:kalla_u_pro_bengkel/di/service_locator.dart';
import 'package:kalla_u_pro_bengkel/features/auth/presentation/bloc/login_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/add_customer_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/get_customer_by_chasis_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/get_mechanic_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/get_service_data_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/get_service_detail_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/get_stall_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/get_vehicle_type_cubit.dart';
import 'package:kalla_u_pro_bengkel/firebase_options.dart';
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

}
void main()  async {
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
 
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


  await setupServiceLocator();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<LoginCubit>(
          create: (context) => locator<LoginCubit>(),
        ),
        BlocProvider<GetVehicleTypeCubit>(
          create: (context) => locator<GetVehicleTypeCubit>(),
        ),
        BlocProvider<AddCustomerCubit>(
          create: (context) => locator<AddCustomerCubit>(),
        ),
        BlocProvider<GetStallsCubit>(
          create: (context) => locator<GetStallsCubit>(),
        ),
        BlocProvider<GetMechanicsCubit>(
          create: (context) => locator<GetMechanicsCubit>(),
        ),
         BlocProvider<GetServiceDataCubit>( // New BlocProvider
          create: (context) => locator<GetServiceDataCubit>(),
        ),
        BlocProvider<GetCustomerByChassisCubit>( // New BlocProvider
          create: (context) => locator<GetCustomerByChassisCubit>(),
        ),
        BlocProvider<GetServiceDetailCubit>(
          create: (context) => locator<GetServiceDetailCubit>(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

