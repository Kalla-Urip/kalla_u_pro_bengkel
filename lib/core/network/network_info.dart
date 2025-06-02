import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart'; // Untuk kDebugMode

abstract class NetworkInfo {
  Future<bool> isConnected();
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> isConnected() async {
    // connectivity.checkConnectivity() sekarang mengembalikan List<ConnectivityResult>
    final List<ConnectivityResult> connectivityResultList = await connectivity.checkConnectivity();

    if (kDebugMode) {
      print('--- NetworkInfoImpl --- Raw ConnectivityResult List: $connectivityResultList');
    }

    // Periksa apakah daftar tersebut mengandung salah satu jenis koneksi yang valid
    if (connectivityResultList.contains(ConnectivityResult.mobile) ||
        connectivityResultList.contains(ConnectivityResult.wifi) ||
        connectivityResultList.contains(ConnectivityResult.ethernet) ||
        connectivityResultList.contains(ConnectivityResult.vpn) ||
        // Untuk 'other', karena bisa jadi string atau enum tergantung versi/platform:
        connectivityResultList.any((result) =>
            result == ConnectivityResult.other ||
            result.toString() == 'ConnectivityResult.other')) {
      if (kDebugMode) {
        print('--- NetworkInfoImpl --- Reporting: CONNECTED');
      }
      return true;
    }

    if (kDebugMode) {
      print('--- NetworkInfoImpl --- Reporting: NOT CONNECTED (List was: $connectivityResultList)');
    }
    return false;
  }
}