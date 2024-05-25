import 'dart:async';
import 'package:get/get.dart';
import 'package:keuangan/services/report_service.dart';

class DashboardController extends GetxController {
  final _loading = false.obs;
  bool get loading => _loading.value;
  set loading(bool value) => _loading.value = value;

  final _isLogin = false.obs;
  bool get isLogin => _isLogin.value;
  set isLogin(bool value) => _isLogin.value = value;

  final _dataDashboard = {}.obs;
  dynamic get dataDashboard => _dataDashboard;
  set dataDashboard(dynamic value) => _dataDashboard.assignAll(value);

  @override
  void onInit() async {
    // await checkUser();
    super.onInit();
  }

  // Future<void> checkUser() async {
  //   loading = true;
  //   await AuthService().verifyToken(Get.context!);
  //   const storage = FlutterSecureStorage();
  //   String? value = await storage.read(key: 'id');
  //   if (value != null) {
  //     if (value.isNotEmpty) {
  //       isLogin = true;
  //       await getDashboard();
  //     } else {
  //       loading = false;
  //       isLogin = false;
  //     }
  //   } else {
  //     loading = false;
  //     isLogin = false;
  //   }
  // }

  Future<void> getDashboard() async {
    if (!loading) {
      loading = true;
    }
    final resp = await ReportService().getDashboard(Get.context!);
    Future.delayed(const Duration(milliseconds: 200), () {
      loading = false;
      dataDashboard = resp;
    });
  }
}
