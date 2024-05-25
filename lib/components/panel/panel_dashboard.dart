import 'package:get/get.dart';
import 'package:keuangan/pages/dashboard/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skeleton_text/skeleton_text.dart';

// ignore: must_be_immutable
class PanelDashboard extends StatefulWidget {
  const PanelDashboard({Key? key}) : super(key: key);

  @override
  State<PanelDashboard> createState() => _PanelDashboardState();
}

class _PanelDashboardState extends State<PanelDashboard> {
  final formatCurrency = NumberFormat.simpleCurrency(
    locale: 'id_ID',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => DashboardController());
    final dashboardController = Get.find<DashboardController>();

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
        image: const DecorationImage(
          image: AssetImage("assets/images/lead.png"),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 0.2,
            offset: const Offset(0, 0.1), // changes position of shadow
          ),
        ],
      ),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
              child: Row(
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      "Dashboard",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: !dashboardController.loading
                        ? () async {
                            dashboardController.getDashboard();
                          }
                        : () {},
                    child: !dashboardController.loading
                        ? const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 20,
                          )
                        : const Icon(
                            Icons.r_mobiledata,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.09,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: !dashboardController.loading
                        ? Column(
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.only(bottom: 2),
                                child: const Text(
                                  "Total",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  formatCurrency.format(dashboardController
                                          .dataDashboard['total'] ??
                                      0),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: SkeletonAnimation(
                              borderRadius: BorderRadius.circular(10.0),
                              shimmerColor: Colors.white54,
                              child: Container(
                                height: 30,
                                width: MediaQuery.of(context).size.width * 0.35,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: Colors.grey[300],
                                ),
                              ),
                            ),
                          ),
                  ),
                  Expanded(
                    child: !dashboardController.loading
                        ? Column(
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.only(bottom: 2),
                                child: const Text(
                                  "Hari ini",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  formatCurrency.format(dashboardController
                                          .dataDashboard['totalToday'] ??
                                      0),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: SkeletonAnimation(
                              borderRadius: BorderRadius.circular(10.0),
                              shimmerColor: Colors.white54,
                              child: Container(
                                height: 30,
                                width: MediaQuery.of(context).size.width * 0.35,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: Colors.grey[300],
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
