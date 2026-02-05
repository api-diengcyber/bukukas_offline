import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:keuangan/db/model/tb_transaksi_model.dart';
import 'package:keuangan/providers/report_bloc.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
    
    // 1. Ambil data dari Bloc
    final List<TbTransaksiModel> listData = (reportBloc.data != null && reportBloc.data['list'] != null)
        ? reportBloc.data['list']
        : [];

    // 2. Hitung Total In & Out untuk Grafik
    double totalIn = 0;
    double totalOut = 0;

    for (var item in listData) {
      totalIn += double.tryParse(item.valueIn ?? "0") ?? 0;
      totalOut += double.tryParse(item.valueOut ?? "0") ?? 0;
    }

    if (listData.isEmpty) {
      return const Center(child: Text("Tidak ada data untuk grafik"));
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Text(
            "Perbandingan Arus Kas",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (totalIn > totalOut ? totalIn : totalOut) * 1.2, // Beri jarak 20% di atas
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.blueGrey,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        formatCurrency.format(rod.toY),
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0: return const Text('Masuk', style: TextStyle(fontWeight: FontWeight.bold));
                          case 1: return const Text('Keluar', style: TextStyle(fontWeight: FontWeight.bold));
                          default: return const Text('');
                        }
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  // Batang Pemasukan (Hijau)
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: totalIn,
                        color: Colors.green,
                        width: 40,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                  // Batang Pengeluaran (Pink/Merah)
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: totalOut,
                        color: Colors.pink,
                        width: 40,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Legend Sederhana
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(Colors.green, "Pemasukan"),
              const SizedBox(width: 20),
              _buildLegend(Colors.pink, "Pengeluaran"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}