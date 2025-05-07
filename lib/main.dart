import 'package:flutter/material.dart';
import 'package:kalla_u_pro_bengkel/common/app_routes.dart';
import 'package:kalla_u_pro_bengkel/common/app_themes.dart';
import 'package:kalla_u_pro_bengkel/di/service_locator.dart';

void main()  async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const MyApp());
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

