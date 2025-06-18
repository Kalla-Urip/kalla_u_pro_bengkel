// kalla_u_pro_bengkel/core/services/fcm_service.dart
import 'dart:convert'; // Untuk jsonDecode jika payload data adalah string JSON
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Untuk Navigasi atau menampilkan dialog
import 'package:go_router/go_router.dart'; // Jika Anda menggunakan GoRouter untuk navigasi
// import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Jika ingin kustomisasi foreground

import 'package:kalla_u_pro_bengkel/core/services/auth_services.dart'; // Untuk cek status login
import 'package:kalla_u_pro_bengkel/di/service_locator.dart';
import 'package:kalla_u_pro_bengkel/core/util/constants.dart'; // Untuk ApiConstants

class FcmService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final Dio _dio = locator<Dio>(); // Ambil Dio dari service locator Anda
  final AuthService _authService = locator<AuthService>(); // Ambil AuthService

  // (Opsional) Jika Anda ingin kustomisasi notifikasi foreground di Android
  // final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


  Future<void> initialize(BuildContext navigatorContext) async {
    // --- 1. Minta Izin Notifikasi ---
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false, // false = pengguna harus eksplisit setuju
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission for notifications');
      }
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('User granted provisional permission for notifications');
      }
    } else {
      if (kDebugMode) {
        print('User declined or has not accepted permission for notifications');
      }
      // Anda mungkin ingin menampilkan dialog yang menjelaskan mengapa notifikasi penting
    }

    // --- (Opsional) Konfigurasi Flutter Local Notifications untuk Foreground Android ---
    // const AndroidInitializationSettings initializationSettingsAndroid =
    //     AndroidInitializationSettings('@mipmap/ic_launcher'); // atau @drawable/ic_notification
    // final DarwinInitializationSettings initializationSettingsDarwin =
    //     DarwinInitializationSettings(
    //   onDidReceiveLocalNotification: (id, title, body, payload) {
    //     // Handle iOS < 10 local notification tap
    //   },
    // );
    // final InitializationSettings initializationSettings = InitializationSettings(
    //   android: initializationSettingsAndroid,
    //   iOS: initializationSettingsDarwin,
    // );
    // await _flutterLocalNotificationsPlugin.initialize(
    //   initializationSettings,
    //   onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
    //     if (notificationResponse.payload != null) {
    //       _handleNotificationTap(navigatorContext, jsonDecode(notificationResponse.payload!));
    //     }
    //   },
    // );

    // --- 2. Dapatkan FCM Token Awal & Kirim ke Backend (jika sudah login) ---
    // Kita akan memanggil sendTokenToBackend secara eksplisit setelah login berhasil.
    // Namun, Anda bisa mendapatkan token di sini dan menyimpannya jika perlu.
    String? token = await getFcmToken();
    if (kDebugMode) {
      print("FCM Token Awal: $token");
    }
    // Jika sudah login saat inisialisasi, kirim token
    if (await _authService.getAccessToken() != null && token != null) {
       sendTokenToBackend(token); // Tidak perlu await di sini, biarkan berjalan di background
    }


    // --- 3. Listener untuk Refresh Token ---
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      if (kDebugMode) {
        print("FCM Token Refreshed: $newToken");
      }
      // Kirim token baru ke backend jika pengguna sudah login
      _authService.getAccessToken().then((accessToken) {
        if (accessToken != null && accessToken.isNotEmpty) {
          sendTokenToBackend(newToken);
        }
      });
    }).onError((err) {
      if (kDebugMode) {
        print("Error onTokenRefresh: $err");
      }
    });

    // --- 4. Listener untuk Pesan Foreground ---
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
      }

      if (message.notification != null) {
        if (kDebugMode) {
          print('Message also contained a notification: ${message.notification?.title}, ${message.notification?.body}');
        }
        // Di Android, notifikasi foreground tidak otomatis muncul.
        // Anda perlu menggunakan flutter_local_notifications untuk menampilkannya.
        // Di iOS, notifikasi foreground muncul secara default.

        // (Opsional) Tampilkan notifikasi lokal untuk Android foreground
        // if (Platform.isAndroid) {
        //   _showLocalNotification(message);
        // }

        // Atau tampilkan dialog/snackbar kustom
        ScaffoldMessenger.of(navigatorContext).showSnackBar(
          SnackBar(
            content: Text(message.notification?.title ?? "Notifikasi Baru"),
            action: SnackBarAction(
              label: "Lihat",
              onPressed: () => _handleNotificationTap(navigatorContext, message.data),
            ),
          ),
        );
      }
    });

    // --- 5. Listener untuk Notifikasi yang Dibuka (App dari Background) ---
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('A new onMessageOpenedApp event was published!');
        print('Message data: ${message.data}');
      }
      _handleNotificationTap(navigatorContext, message.data);
    });

    // --- 6. Cek jika App Dibuka dari Notifikasi (App dari Terminated) ---
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      if (kDebugMode) {
        print('App opened from terminated state via notification');
        print('Initial message data: ${initialMessage.data}');
      }
      // Tunggu sebentar agar UI siap sebelum navigasi
      Future.delayed(const Duration(milliseconds: 500), () {
         _handleNotificationTap(navigatorContext, initialMessage.data);
      });
    }
  }

  Future<String?> getFcmToken() async {
    try {
      // Untuk APNS token di iOS (jika diperlukan secara eksplisit, biasanya tidak)
      // if (Platform.isIOS) {
      //   String? apnsToken = await _firebaseMessaging.getAPNSToken();
      //   if (kDebugMode) print("APNS Token: $apnsToken");
      // }
      return await _firebaseMessaging.getToken();
    } catch (e) {
      if (kDebugMode) {
        print("Error getting FCM token: $e");
      }
      return null;
    }
  }

  // (Opsional) Method untuk menampilkan notifikasi lokal
  // Future<void> _showLocalNotification(RemoteMessage message) async {
  //   RemoteNotification? notification = message.notification;
  //   AndroidNotification? android = message.notification?.android;

  //   if (notification != null && android != null) {
  //     const AndroidNotificationDetails androidNotificationDetails =
  //         AndroidNotificationDetails(
  //       'your_channel_id', // sesuaikan dengan channel ID yang Anda buat di AndroidManifest
  //       'Your Channel Name',
  //       channelDescription: 'Your channel description',
  //       importance: Importance.max,
  //       priority: Priority.high,
  //       // icon: '@drawable/ic_notification', // pastikan icon ini ada
  //       // color: Colors.blue, // opsional
  //       playSound: true,
  //     );
  //     const NotificationDetails notificationDetails =
  //         NotificationDetails(android: androidNotificationDetails);

  //     await _flutterLocalNotificationsPlugin.show(
  //       notification.hashCode,
  //       notification.title,
  //       notification.body,
  //       notificationDetails,
  //       payload: jsonEncode(message.data), // Kirim data payload
  //     );
  //   }
  // }

  void _handleNotificationTap(BuildContext context, Map<String, dynamic> data) {
    if (kDebugMode) {
      print("Handling notification tap with data: $data");
    }
    // Logika navigasi berdasarkan data notifikasi
    // Contoh: jika data payload notifikasi dari backend berisi:
    // { "screen": "/order_detail", "order_id": "123" }
    final String? screen = data['screen'] as String?;
    final String? orderId = data['order_id'] as String?; // Atau tipe data lain

    if (screen != null) {
      // Gunakan GoRouter untuk navigasi
      // Pastikan route Anda sudah terdefinisi di AppRoutes
      if (orderId != null) {
        context.go('$screen/$orderId'); // Contoh: /order_detail/123
      } else {
        context.go(screen); // Contoh: /notifications_page
      }
    } else {
      // Navigasi default jika tidak ada informasi screen
      // context.go(AppRoutes.main); // Ganti dengan route default Anda
    }
  }

  Future<void> sendTokenToBackend(String? token) async {
    if (token == null) {
      if (kDebugMode) {
        print("FCM token is null, cannot send to backend.");
      }
      return;
    }

    // Cek apakah user sudah login (memiliki access token)
    final accessToken = await _authService.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      if (kDebugMode) {
        print("User not logged in, cannot send FCM token to backend.");
      }
      return;
    }

    const String url = ApiConstants.baseUrl + "/auth/fcm"; // Gabungkan baseUrl dan endpoint
    if (kDebugMode) {
      print("Sending FCM token to backend: $token at $url");
    }

    try {
      // Sesuai dengan curl Anda, Content-Type adalah application/x-www-form-urlencoded
      // Dio akan otomatis mengatur Authorization header via interceptor Anda
      final response = await _dio.post(
        url,
        data: {'token': token}, // Dio akan mengurus encoding untuk form-urlencoded jika header diset
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (kDebugMode) {
          print('FCM token successfully sent to backend: ${response.data}');
        }
      } else {
        if (kDebugMode) {
          print('Failed to send FCM token. Status: ${response.statusCode}, Response: ${response.data}');
        }
        // Pertimbangkan mekanisme retry atau logging error yang lebih persisten
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('DioException when sending FCM token: ${e.message}');
        if (e.response != null) {
          print('DioException response: ${e.response?.data}');
        }
      }
      // Handle error (misalnya, jika 401 karena token auth expired, interceptor Dio Anda mungkin sudah handle logout)
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error when sending FCM token: $e');
      }
    }
  }

  Future<void> deleteFcmToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      if (kDebugMode) {
        print("FCM token deleted.");
      }
      // Anda mungkin juga ingin memberi tahu backend bahwa token ini tidak valid lagi
      // (misalnya dengan mengirim request ke endpoint logout token FCM jika ada)
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting FCM token: $e");
      }
    }
  }
}