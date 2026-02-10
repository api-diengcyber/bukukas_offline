import 'package:keuangan/components/models/data_summary_model.dart';
import 'package:keuangan/db/tb_menu.dart';
import 'package:keuangan/db/tb_transaksi.dart';
import 'package:keuangan/providers/global_bloc.dart'; // Import GlobalBloc
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

  // Fungsi untuk mengambil list menu agar indikator titik warna muncul
  Future<void> _fetchAvailableMenuTypes(BuildContext context) async {
    final reportBloc = Provider.of<ReportBloc>(context, listen: false);
    final globalBloc = Provider.of<GlobalBloc>(context, listen: false); // Ambil ID Buku
    
    reportBloc.loadingMenus = true;
    
    // PERBAIKAN: Kirim null (untuk semua tipe) dan activeBukukasId
    var menus = await TbMenu().getData(null, globalBloc.activeBukukasId);
    reportBloc.listAvailableMenuType = menus;
    
    reportBloc.loadingMenus = false;
  }

  Future<void> getSummaryReport(BuildContext context) async {
    final reportBloc = Provider.of<ReportBloc>(context, listen: false);
    final globalBloc = Provider.of<GlobalBloc>(context, listen: false); // Ambil ID Buku
    
    reportBloc.loadingSummary = true;

    // 1. Ambil data transaksi dari SQLite dengan filter Buku Kas
    var listTransaksi = await TbTransaksi().getData(reportBloc.activeMenuTab, globalBloc.activeBukukasId);

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
      // PERBAIKAN: Tambahkan ID Buku Kas saat ambil data menu
      var menus = await TbMenu().getData(reportBloc.activeMenuTab, globalBloc.activeBukukasId);
      for (var m in menus) {
        // Gunakan pembanding yang aman (sesuaikan dengan isi database "1" atau "Lunas")
        if (m.statusPaidOff == "1" || m.statusPaidOff == "Lunas") {
          countLunas++;
        } else {
          countBelum++;
        }
      }
    }

    // 4. Hitung hasil bersih
    int totalBersih = tIn - tOut;
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
    final globalBloc = Provider.of<GlobalBloc>(context, listen: false); // Ambil ID Buku

    reportBloc.loadingData = true;

    // PERBAIKAN: Ambil data transaksi dengan filter Buku Kas aktif
    var listTransaksi = await TbTransaksi().getData(reportBloc.activeMenuTab, globalBloc.activeBukukasId);
    
    reportBloc.data = {"list": listTransaksi};

    reportBloc.loadingData = false;
  }

  Future<bool> deleteTransaction(BuildContext context, int id) async {
    // Logika hapus transaksi biasanya dihandle oleh TbTransaksi
    // await TbTransaksi().delete(id); 
    return true;
  }
}