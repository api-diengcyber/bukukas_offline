import 'dart:async';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; 
import 'package:keuangan/db/tb_transaksi.dart';
import 'package:keuangan/db/model/tb_transaksi_model.dart';

class DashboardController extends GetxController {
  final _loading = false.obs;
  bool get loading => _loading.value;
  set loading(bool value) => _loading.value = value;

  final RxMap _dataDashboard = {}.obs;
  dynamic get dataDashboard => _dataDashboard;
  
  // Kita hapus getDashboard dari onInit karena onInit tidak bisa menerima context 
  // untuk mengambil data dari GlobalBloc. Kita akan panggil manual dari UI.
  @override
  void onInit() {
    super.onInit();
  }

  // PERBAIKAN: Tambahkan parameter bukukasId
  Future<void> getDashboard(int bukukasId) async {
    try {
      loading = true;
      
      // PERBAIKAN: Kirim 2 argumen ke getData (Type dan ID Buku Kas aktif)
      List<TbTransaksiModel> listTransaksi = await TbTransaksi().getData("Semua", bukukasId);
      
      print("DEBUG: BukuKas ID = $bukukasId | Jumlah Transaksi = ${listTransaksi.length}");

      int totalBalance = 0;
      int totalToday = 0; 
      Map<String, int> chartMap = {};

      String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      for (var item in listTransaksi) {
        int vIn = int.tryParse(item.valueIn ?? "0") ?? 0;
        int vOut = int.tryParse(item.valueOut ?? "0") ?? 0;
        int net = vIn - vOut;

        totalBalance += net;

        if (item.transactionDate != null && item.transactionDate!.startsWith(todayStr)) {
          totalToday += net;
        }

        String menuName = item.menuName ?? "Tanpa Kategori";
        chartMap[menuName] = (chartMap[menuName] ?? 0) + (vIn != 0 ? vIn : vOut);
      }

      List listChart = chartMap.entries.map((e) => {
        "name": e.key,
        "total": e.value
      }).toList();

      _dataDashboard.assignAll({
        "total": totalBalance,
        "totalToday": totalToday,
        "totalByMenus": listChart,
        "dataTransaction": listTransaksi,
      });
    } catch (e) {
      print("DEBUG ERROR DASHBOARD: $e");
    } finally {
      loading = false;
    }
  }
}