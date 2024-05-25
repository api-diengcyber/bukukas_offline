import 'package:flutter/material.dart';

class SimpleBarChart extends StatelessWidget {
  const SimpleBarChart({
    Key? key,
    required this.data,
  }) : super(key: key);

  final dynamic data;

  @override
  Widget build(BuildContext context) {
    return Container();
    // return charts.BarChart(
    //   _generateData(data),
    //   animate: true,
    // );
  }

  // static List<charts.Series<OrdinalBar, String>> _generateData(dynamic _data) {
  //   List<OrdinalBar> data = [];

  //   _data.forEach((key, value) {
  //     String name = key;
  //     charts.Color chartColor = charts.ColorUtil.fromDartColor(Colors.green);
  //     if (key == "Pemasukan") {
  //       name = "Masuk";
  //       chartColor = charts.ColorUtil.fromDartColor(Colors.green);
  //     } else if (key == "Pengeluaran") {
  //       name = "Keluar";
  //       chartColor = charts.ColorUtil.fromDartColor(Colors.pink);
  //     } else if (key == "Hutang") {
  //       chartColor = charts.ColorUtil.fromDartColor(Colors.amber);
  //     } else if (key == "Piutang") {
  //       chartColor = charts.ColorUtil.fromDartColor(Colors.blue);
  //     }
  //     if (value != 0) {
  //       data.add(OrdinalBar(name, value, chartColor));
  //     }
  //   });

  //   return [
  //     charts.Series<OrdinalBar, String>(
  //       id: 'Data',
  //       colorFn: (OrdinalBar item, _) => item.palette,
  //       domainFn: (OrdinalBar item, _) => item.year,
  //       measureFn: (OrdinalBar item, _) => item.sales,
  //       data: data,
  //     )
  //   ];
  // }
}

// class OrdinalBar {
//   final String year;
//   final int sales;
//   final charts.Color palette;

//   OrdinalBar(this.year, this.sales, this.palette);
// }
