import 'package:get/get.dart';
import 'package:keuangan/components/simple_barchart.dart';
import 'package:flutter/material.dart';
import 'package:keuangan/pages/dashboard/dashboard_controller.dart';

// ignore: must_be_immutable
class PanelChart extends StatefulWidget {
  const PanelChart({super.key});

  @override
  State<PanelChart> createState() => _PanelChartState();
}

class _PanelChartState extends State<PanelChart> {
  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => DashboardController());
    final dashboardController = Get.find<DashboardController>();

    return Container(
      height: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
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
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            child: const Text(
              "Grafik terbaru",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: !dashboardController.loading
                ? (dashboardController.dataDashboard["totalByMenus"] ?? "")
                            .length >
                        0
                    ? SimpleBarChart(
                        data:
                            dashboardController.dataDashboard["totalByMenus"] ??
                                "",
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.bar_chart,
                              color: Colors.grey,
                              size: 40,
                            ),
                            Text(
                              "Data tidak ditemukan",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                : const Center(
                    child: Text(
                      "Memuat...",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
