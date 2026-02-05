import 'dart:async';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Wajib untuk filter tanggal hari ini
import 'package:keuangan/db/tb_transaksi.dart';
import 'package:keuangan/db/model/tb_transaksi_model.dart';

class DashboardController extends GetxController {
  final _loading = false.obs;
  bool get loading => _loading.value;
  set loading(bool value) => _loading.value = value;

  // Menggunakan RxMap agar reaktif
  final RxMap _dataDashboard = {}.obs;
  dynamic get dataDashboard => _dataDashboard;
  
  @override
  void onInit() {
    super.onInit();
    getDashboard();
  }

  // dashboard_controller.dart
// dashboard_controller.dart
Future<void> getDashboard() async {
  try {
    loading = true;
    List<TbTransaksiModel> listTransaksi = await TbTransaksi().getData("Semua");
    
    // DEBUG: Cek apakah data dari database ada
    print("DEBUG: Jumlah Transaksi ditemukan = ${listTransaksi.length}");

    int totalBalance = 0;
    Map<String, int> chartMap = {};

    for (var item in listTransaksi) {
      int vIn = int.tryParse(item.valueIn ?? "0") ?? 0;
      int vOut = int.tryParse(item.valueOut ?? "0") ?? 0;
      int net = vIn - vOut;

      totalBalance += net;

      // Ambil nama menu, jika null beri nama 'Tanpa Kategori'
      String menuName = item.menuName ?? "Tanpa Kategori";
      chartMap[menuName] = (chartMap[menuName] ?? 0) + (vIn != 0 ? vIn : vOut);
    }

    List listChart = chartMap.entries.map((e) => {
      "name": e.key,
      "total": e.value
    }).toList();

    // DEBUG: Cek apakah data chart terisi
    print("DEBUG: Data Chart = $listChart");

    _dataDashboard.assignAll({
      "total": totalBalance,
      "totalByMenus": listChart,
      "dataTransaction": listTransaksi,
    });
  } catch (e) {
    print("DEBUG ERROR: $e");
  } finally {
    loading = false;
  }
}
}