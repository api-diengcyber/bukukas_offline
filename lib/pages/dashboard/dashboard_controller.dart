import 'dart:async';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; 
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

  Future<void> getDashboard() async {
    try {
      loading = true;
      List<TbTransaksiModel> listTransaksi = await TbTransaksi().getData("Semua");
      
      // DEBUG: Cek apakah data dari database ada
      print("DEBUG: Jumlah Transaksi ditemukan = ${listTransaksi.length}");

      int totalBalance = 0;
      int totalToday = 0; // Inisialisasi variabel untuk hari ini
      Map<String, int> chartMap = {};

      // Ambil string tanggal hari ini (Format: YYYY-MM-DD)
      String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      for (var item in listTransaksi) {
        int vIn = int.tryParse(item.valueIn ?? "0") ?? 0;
        int vOut = int.tryParse(item.valueOut ?? "0") ?? 0;
        int net = vIn - vOut;

        // Hitung total saldo keseluruhan
        totalBalance += net;

        // LOGIKA BARU: Cek apakah transaksi terjadi hari ini
        // Kita gunakan startsWith karena format DB biasanya "YYYY-MM-DD HH:mm:ss"
        if (item.transactionDate != null && item.transactionDate!.startsWith(todayStr)) {
          totalToday += net;
        }

        // Ambil nama menu untuk grafik
        String menuName = item.menuName ?? "Tanpa Kategori";
        chartMap[menuName] = (chartMap[menuName] ?? 0) + (vIn != 0 ? vIn : vOut);
      }

      List listChart = chartMap.entries.map((e) => {
        "name": e.key,
        "total": e.value
      }).toList();

      // DEBUG: Cek perhitungan hari ini
      print("DEBUG: Total Hari Ini ($todayStr) = $totalToday");
      print("DEBUG: Data Chart = $listChart");

      // Pastikan "totalToday" dimasukkan ke dalam assignAll
      _dataDashboard.assignAll({
        "total": totalBalance,
        "totalToday": totalToday, // Data ini yang akan dibaca UI
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