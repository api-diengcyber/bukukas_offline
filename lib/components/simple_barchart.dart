import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SimpleBarChart extends StatelessWidget {
  final List data; // Menerima data [{name: ..., total: ...}]
  
  const SimpleBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp');

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        // 1. Tambahkan Max Y agar grafik punya ruang di atas
        maxY: _getMaxY(), 
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          // Judul bawah (Nama Menu)
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
  if (value.toInt() >= 0 && value.toInt() < data.length) {
    return SideTitleWidget(
      // PERBAIKAN: Masukkan objek meta secara utuh
      meta: meta, 
      child: Text(
        // Menampilkan nama menu, potong jika terlalu panjang
        data[value.toInt()]['name'].toString().length > 6 
            ? "${data[value.toInt()]['name'].toString().substring(0, 5)}.."
            : data[value.toInt()]['name'].toString(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
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
        // 2. Loop data untuk membuat batang grafik
        barGroups: data.asMap().entries.map((entry) {
          int index = entry.key;
          var item = entry.value;
          double total = double.tryParse(item['total'].toString()) ?? 0;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: total,
                color: _getColor(index),
                width: 18,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                // Tambahkan background jika ingin terlihat lebih modern
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: _getMaxY(),
                  color: Colors.grey.shade100,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  double _getMaxY() {
    double max = 0;
    for (var item in data) {
      double total = double.tryParse(item['total'].toString()) ?? 0;
      if (total > max) max = total;
    }
    return max == 0 ? 100 : max * 1.2; // Tambah margin 20%
  }

  Color _getColor(int index) {
    List<Color> colors = [Colors.blue, Colors.green, Colors.amber, Colors.pink, Colors.purple];
    return colors[index % colors.length];
  }
}