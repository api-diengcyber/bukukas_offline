import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:keuangan/db/model/tb_transaksi_model.dart';
import 'package:keuangan/providers/report_bloc.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:keuangan/helpers/set_menus.dart'; // Import untuk warna tab

class TabReportGraph extends StatefulWidget {
  const TabReportGraph({super.key});

  @override
  State<TabReportGraph> createState() => _TabReportGraphState();
}

class _TabReportGraphState extends State<TabReportGraph> {
  final formatCurrency = NumberFormat.simpleCurrency(locale: 'id_ID', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final reportBloc = context.watch<ReportBloc>();
    
    final List<TbTransaksiModel> listData = (reportBloc.data != null && reportBloc.data['list'] != null)
        ? List<TbTransaksiModel>.from(reportBloc.data['list'])
        : [];

    // 1. LOGIKA PENGELOMPOKAN DATA PER MENU
    Map<String, double> menuTotals = {};
    for (var item in listData) {
      String name = item.menuName ?? "Lainnya";
      double valIn = double.tryParse(item.valueIn ?? "0") ?? 0;
      double valOut = double.tryParse(item.valueOut ?? "0") ?? 0;
      
      // Hitung nilai absolut (besaran arus kas) per menu
      double magnitude = (valIn != 0) ? valIn : valOut;
      
      menuTotals[name] = (menuTotals[name] ?? 0) + magnitude;
    }

    if (menuTotals.isEmpty) {
      return const Center(child: Text("Tidak ada data untuk grafik"));
    }

    // Persiapkan list nama menu untuk label sumbu X
    List<String> menuNames = menuTotals.keys.toList();
    double maxVal = menuTotals.values.isNotEmpty 
        ? menuTotals.values.reduce((a, b) => a > b ? a : b) 
        : 0;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Text(
            "Statistik per Kategori (${reportBloc.activeMenuTab})",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                // Lebar dinamis: jika menu banyak, grafik bisa di-scroll ke samping
                width: menuNames.length * 80.0 > MediaQuery.of(context).size.width 
                    ? menuNames.length * 80.0 
                    : MediaQuery.of(context).size.width - 40,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxVal * 1.3, // Beri space ekstra di atas untuk tooltip
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) => Colors.blueGrey.withOpacity(0.8),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            "${menuNames[groupIndex]}\n",
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            children: [
                              TextSpan(
                                text: formatCurrency.format(rod.toY),
                                style: const TextStyle(color: Colors.yellowAccent, fontSize: 11),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();
                            if (index >= 0 && index < menuNames.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Transform.rotate(
                                  angle: -0.3, // Miringkan sedikit agar tidak tabrakan
                                  child: Text(
                                    menuNames[index],
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(menuNames.length, (index) {
                      String currentMenu = menuNames[index];
                      // Cari tipe menu dari data asli untuk menentukan warna
                      String? type = listData.firstWhere((element) => element.menuName == currentMenu).menuType;

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: menuTotals[currentMenu]!,
                            color: _getMenuColor(type),
                            width: 25,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: maxVal * 1.3,
                              color: Colors.grey.shade100,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text("Geser horizontal jika kategori penuh ↔", 
            style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  // Helper warna batang berdasarkan tipe kategori
  Color _getMenuColor(String? type) {
    switch (type) {
      case "Pemasukan": return Colors.green.shade400;
      case "Pengeluaran": return Colors.pink.shade400;
      case "Hutang": return Colors.amber.shade600;
      case "Piutang": return Colors.blue.shade600;
      default: return Colors.blueGrey;
    }
  }
}