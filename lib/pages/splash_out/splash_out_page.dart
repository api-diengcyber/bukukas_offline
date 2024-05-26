import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:keuangan/pages/splash_out/splash_out_model.dart';

class SplashOutPage extends StatefulWidget {
  const SplashOutPage({super.key});

  @override
  SplashOutPageState createState() => SplashOutPageState();
}

class SplashOutPageState extends State<SplashOutPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent,
    // ));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      SplashOutModel().initApp(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                image: DecorationImage(
                  image: AssetImage('assets/bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
              child: const Center(
                child: SpinKitChasingDots(
                  color: Colors.amber,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
