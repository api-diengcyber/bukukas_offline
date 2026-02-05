import 'package:get/get.dart';
import 'package:keuangan/components/simple_barchart.dart';
import 'package:flutter/material.dart';
import 'package:keuangan/pages/dashboard/dashboard_controller.dart';

class PanelChart extends StatefulWidget {
  const PanelChart({super.key});

  @override
  State<PanelChart> createState() => _PanelChartState();
}

class _PanelChartState extends State<PanelChart> {
  @override
  Widget build(BuildContext context) {
    // Gunakan Get.find (Controller sudah di-put di dashboard_page)
    final dashboardController = Get.find<DashboardController>();

    return Container(
      height: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 0.2,
            offset: const Offset(0, 0.1),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          const SizedBox(
            width: double.infinity,
            child: Text(
              "Grafik terbaru",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            // WAJIB PAKAI OBX DI SINI
            child: Obx(() {
              if (dashboardController.loading) {
                return const Center(child: Text("Memuat..."));
              }

              final List chartData = dashboardController.dataDashboard["totalByMenus"] ?? [];

              if (chartData.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart, color: Colors.grey, size: 40),
                      Text("Data tidak ditemukan", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return SimpleBarChart(data: chartData);
            }),
          ),
        ],
      ),
    );
  }
}