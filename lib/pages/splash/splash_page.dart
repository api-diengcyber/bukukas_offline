import 'package:flutter/material.dart';
import 'package:keuangan/components/panel/panel_splash_1.dart';
import 'package:keuangan/components/panel/panel_splash_2.dart';
import 'package:keuangan/pages/splash/splash_model.dart';
import 'package:keuangan/providers/splashscreen_bloc.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      SplashModel().initApp(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final splashscreenBloc = context.watch<SplashscreenBloc>();
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: splashscreenBloc.splashIndex == 1
          ? const PanelSplash1()
          : const PanelSplash2(),
    );
  }
}
