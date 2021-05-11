import 'dart:async';
import 'package:connectivity/connectivity.dart';

class ConnectivityProvider {
  Connectivity _connectivity;

  ConnectivityProvider() {
    this._connectivity = Connectivity();
  }

  Future<bool> isConnected() async {
    ConnectivityResult result = await this._connectivity.checkConnectivity();
    if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi)
      return true;
    else
      return false;
  }
}
