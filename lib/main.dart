import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalla_u_pro_bengkel/common/app_routes.dart';
import 'package:kalla_u_pro_bengkel/common/app_themes.dart';
import 'package:kalla_u_pro_bengkel/di/service_locator.dart';
import 'package:kalla_u_pro_bengkel/features/auth/presentation/bloc/login_cubit.dart';
import 'package:kalla_u_pro_bengkel/firebase_options.dart';
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Jika Anda menggunakan package lain seperti flutter_local_notifications di sini,
  // pastikan untuk memanggil `setupFlutterNotifications()` terlebih dahulu.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await setupFlutterNotifications(); // Jika Anda menggunakan flutter_local_notifications

  print('Handling a background message ${message.messageId}');
  // Anda bisa melakukan apa pun di sini, misal menyimpan notifikasi ke local storage
  // atau menampilkan notifikasi lokal jika diperlukan (meskipun FCM otomatis menampilkannya)
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

