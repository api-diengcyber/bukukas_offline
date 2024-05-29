import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as g;
import 'package:keuangan/pages/dashboard/dashboard_page.dart';
import 'package:keuangan/providers/splashscreen_bloc.dart';
import 'package:provider/provider.dart';

class SplashModel {
  void initApp(BuildContext context) async {
    final splashscreenBloc =
        Provider.of<SplashscreenBloc>(context, listen: false);
    Timer(const Duration(milliseconds: 2500), () async {
      splashscreenBloc.splashIndex = 2;
      Timer(
        const Duration(milliseconds: 1000),
        () => g.Get.offAll(
          () => const DashboardPage(),
        ),
      );
    });
  }
}
