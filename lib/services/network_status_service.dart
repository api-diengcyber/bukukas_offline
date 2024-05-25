import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../components/network_error_item.dart';

class NetworkStatusService extends GetxService {
  NetworkStatusService() {
    var isDeviceConnected = false;
    Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
          isDeviceConnected = false;
          if (result != ConnectivityResult.none) {
            isDeviceConnected = await InternetConnectionChecker().hasConnection;
          }
          _getNetworkStatus(isDeviceConnected);
        } as void Function(List<ConnectivityResult> event)?);
  }

  void _getNetworkStatus(bool status) {
    if (status) {
      _validateSession();
    } else {
      Get.dialog(const NetworkErrorItem(), useSafeArea: false);
    }
  }

  void _validateSession() {
    // Get.offAll(() => const DashboardPage());
  }
}
