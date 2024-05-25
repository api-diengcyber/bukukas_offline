import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashOutModel {
  void initApp(BuildContext context) async {
    Get.offAllNamed('/splash');
    // Timer(
    //   const Duration(milliseconds: 50),
    //   () => Get.offAllNamed('/splash'),
    // );
  }
}
