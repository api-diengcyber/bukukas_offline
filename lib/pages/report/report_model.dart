import 'package:keuangan/components/models/data_summary_model.dart';
import 'package:keuangan/db/tb_menu.dart';
import 'package:keuangan/db/tb_transaksi.dart';
import 'package:keuangan/providers/report_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportModel {
  // Inisialisasi data laporan
  void init(BuildContext context) async {
    await _fetchAvailableMenuTypes(context); // Ambil kategori menu dulu
    await getSummaryReport(context);
    await getTabsData(context);
  }

  // Fungsi baru untuk mengambil list menu agar indikator titik warna muncul
  Future<void> _fetchAvailableMenuTypes(BuildContext context) async {
    final reportBloc = Provider.of<ReportBloc>(context, listen: false);
    reportBloc.loadingMenus = true;
    
    // Ambil semua data menu dari database
    var menus = await TbMenu().getData(null);
    reportBloc.listAvailableMenuType = menus;
    
    reportBloc.loadingMenus = false;
  }

  Future<void> getSummaryReport(BuildContext context) async {
  final reportBloc = Provider.of<ReportBloc>(context, listen: false);
  reportBloc.loadingSummary = true;

  // 1. Ambil data transaksi dari SQLite
  var listTransaksi = await TbTransaksi().getData(reportBloc.activeMenuTab);

  int tIn = 0;
  int tOut = 0;
  int countLunas = 0;
  int countBelum = 0;

  // 2. Hitung nominal
  for (var item in listTransaksi) {
    tIn += int.tryParse(item.valueIn ?? "0") ?? 0;
    tOut += int.tryParse(item.valueOut ?? "0") ?? 0;
  }

  // 3. Hitung status Hutang/Piutang jika tab aktif adalah Hutang/Piutang
  if (reportBloc.activeMenuTab == "Hutang" || reportBloc.activeMenuTab == "Piutang") {
    // Ambil data menu untuk mengecek status lunas
    var menus = await TbMenu().getData(reportBloc.activeMenuTab);
    for (var m in menus) {
      if (m.statusPaidOff == "Lunas") {
        countLunas++;
      } else {
        countBelum++;
      }
    }
  }

  // 4. Sinkronisasi dengan DataSummaryModel milikmu
  // Gunakan total untuk menyimpan hasil bersih (Pemasukan - Pengeluaran)
  int totalBersih = tIn - tOut;
  
  // Tentukan totalByType berdasarkan tab yang aktif
  int totalByType = totalBersih;
  if (reportBloc.activeMenuTab == "Pemasukan") totalByType = tIn;
  if (reportBloc.activeMenuTab == "Pengeluaran") totalByType = tOut;

  DataSummaryModel summary = DataSummaryModel(
    total: totalBersih,
    totalByType: totalByType,
    debtMenuStatus: DebtMenuStatusModel(
      lunas: countLunas,
      belum: countBelum,
    ),
    listAvailableMenuType: reportBloc.listAvailableMenuType,
  );

  // 5. Update Bloc
  reportBloc.dataSummary = summary;
  reportBloc.totalReport = totalByType;

  reportBloc.loadingSummary = false;
}

  Future<void> getTabsData(BuildContext context) async {
    final reportBloc = Provider.of<ReportBloc>(context, listen: false);
    reportBloc.loadingData = true;

    // Ambil data untuk ditampilkan di list tab bawah
    var listTransaksi = await TbTransaksi().getData(reportBloc.activeMenuTab);
    
    // Simpan ke bloc (asumsi data summary menggunakan map 'list')
    reportBloc.data = {"list": listTransaksi};

    reportBloc.loadingData = false;
  }

  Future<bool> deleteTransaction(BuildContext context, int id) async {
    // Tambahkan logika hapus beneran ke database
    // await TbTransaksi().delete(id); 
    return true;
  }
}