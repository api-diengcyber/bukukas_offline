import 'package:get/get.dart';
import 'package:keuangan/components/end_drawer.dart';
import 'package:keuangan/components/panel/panel_dashboard.dart';
import 'package:keuangan/components/panel/panel_menu_button.dart';
import 'package:keuangan/components/panel/panel_chart.dart';
import 'package:keuangan/components/panel/panel_transaction.dart';
import 'package:flutter/material.dart';
import 'package:keuangan/pages/dashboard/dashboard_controller.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late TutorialCoachMark tutorialCoachMark;
  late DashboardController dashboardController;
  List<TargetFocus> targets = <TargetFocus>[];

  GlobalKey keyAddButton = GlobalKey();

  @override
  void initState() {
    super.initState();
    dashboardController = Get.put(DashboardController());
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      backgroundColor: const Color(0x00000000),
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'KEUANGAN',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () {
            _scaffoldKey.currentState!.openEndDrawer();
          },
          icon: const Icon(
            Icons.person_outline,
            color: Colors.black,
          ),
        ),
      ],
    );

    double marginTopScreen = appBar.preferredSize.height +
        MediaQuery.of(context).viewPadding.top +
        8;

    return Obx(
      () => dashboardController.loading
          ? const Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          : Scaffold(
              key: _scaffoldKey,
              extendBodyBehindAppBar: true,
              appBar: appBar,
              endDrawer: const EndDrawer(),
              body: Container(
                constraints: const BoxConstraints.expand(),
                color: Colors.grey.shade100,
                padding: EdgeInsets.only(
                  top: marginTopScreen,
                  left: 10,
                  right: 10,
                  bottom: 12,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      const PanelDashboard(),
                      // const SizedBox(height: 10),
                      // const PanelInfo(),
                      const SizedBox(height: 10),
                      const SizedBox(
                        height: 180,
                        child: PanelChart(),
                      ),
                      const SizedBox(height: 10),
                      PanelMenuButton(
                        buttonAddKey: keyAddButton,
                      ),
                      const SizedBox(height: 10),
                      const PanelTransaction(),
                      const SizedBox(height: 2),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
