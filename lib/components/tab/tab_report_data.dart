import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:keuangan/db/model/tb_transaksi_model.dart'; // Wajib import model
import 'package:keuangan/helpers/set_menus.dart';
import 'package:keuangan/pages/report/report_model.dart';
import 'package:keuangan/providers/report_bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keuangan/utils/currency.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../pages/report/detail/report_menu_detail_page.dart';

class TabReportData extends StatefulWidget {
  const TabReportData({super.key});

  @override
  State<TabReportData> createState() => _TabReportDataState();
}

class _TabReportDataState extends State<TabReportData> {
  final formatCurrency = NumberFormat.simpleCurrency(
    locale: 'id_ID',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final reportBloc = context.watch<ReportBloc>();

    // 1. Ambil list dari bloc data (pastikan sinkron dengan ReportModel)
    // Kita asumsikan reportBloc.data['list'] berisi List<TbTransaksiModel>
    final List<TbTransaksiModel> listData = (reportBloc.data != null && reportBloc.data['list'] != null)
        ? reportBloc.data['list']
        : [];

    onDeleteMenu(TbTransaksiModel data) async {
      // Parsing tanggal dari string model
      DateTime tempDate = DateFormat("yyyy-MM-dd").parse(data.transactionDate ?? DateTime.now().toString());
      
      // Hitung nominal bersih
      int valIn = int.tryParse(data.valueIn ?? "0") ?? 0;
      int valOut = int.tryParse(data.valueOut ?? "0") ?? 0;
      int jml = valIn - valOut;

      String desc = "${data.menuName} (${data.menuType})";
      desc += "\n ${DateFormat("yyyy-MM-dd HH:mm:ss").format(tempDate)}";
      if (data.notes != null && data.notes != "") {
        desc += "\n ${data.notes}";
      }
      desc += "\n ${formatCurrency.format(jml)}";

      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        headerAnimationLoop: false,
        animType: AnimType.bottomSlide,
        title: 'Hapus transaksi ini',
        desc: desc,
        buttonsTextStyle: const TextStyle(color: Colors.white),
        showCloseIcon: true,
        btnCancelColor: Colors.grey,
        btnOkColor: Colors.red,
        btnOkText: "Hapus transaksi",
        btnCancelOnPress: () {},
        btnOkOnPress: () async {
          var resp = await ReportModel().deleteTransaction(context, data.id ?? 0);
          if (resp) {
            await ReportModel().getTabsData(context);
            await ReportModel().getSummaryReport(context);
          }
        },
      ).show();
    }

    Color colorT = _getThemeColor(reportBloc.activeMenuTab);

    // Tampilan loading
    if (reportBloc.loadingSummary || reportBloc.loadingData) {
      return _buildLoading(colorT);
    }

    // Tampilan jika data kosong
    if (listData.isEmpty) {
      return _buildEmptyState();
    }

    return SizedBox(
      height: double.infinity,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(0),
              itemCount: listData.length,
              itemBuilder: (context, index) {
                // MAPPING DATA DARI MODEL (Bukan Map lagi)
                TbTransaksiModel item = listData[index];
                
                DateTime tempDate = DateTime.tryParse(item.transactionDate ?? "") ?? DateTime.now();
                int vIn = int.tryParse(item.valueIn ?? "0") ?? 0;
                int vOut = int.tryParse(item.valueOut ?? "0") ?? 0;

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                  margin: const EdgeInsets.only(bottom: 8, left: 12, right: 12),
                  decoration: BoxDecoration(
                    color: activeTabColor(item.menuType ?? "", labelsColor),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: activeTabColor(item.menuType ?? "", chipsColor),
                        spreadRadius: 0,
                        blurRadius: 0.2,
                        offset: const Offset(0, 0.1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.menuName ?? "Tanpa Nama",
                        style: TextStyle(
                          color: activeTabColor(item.menuType ?? "", reportActiveTabColor),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (item.menuNotes != null && item.menuNotes != "")
                        Text(
                          item.menuNotes!,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      Text(
                        DateFormat("yyyy-MM-dd HH:mm:ss").format(tempDate),
                        style: const TextStyle(color: Colors.black87, fontSize: 14),
                      ),
                      if (item.notes != null && item.notes != "")
                        Text(
                          item.notes!,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      Row(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 0.2,
                                  offset: const Offset(0, 0.2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            child: Text(
                              formatCurrency.format(vIn - vOut),
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                          if (item.debtType != "NON" && item.debtType != null)
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              decoration: BoxDecoration(
                                color: Colors.white54,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              child: Text(
                                "${item.debtType} ${item.menuType?.toLowerCase()}",
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: <Widget>[
                          _buildActionButton(
                            icon: Icons.content_paste_search,
                            label: "Detail",
                            onTap: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.bottomToTop,
                                  child: ReportMenuDetailPage(
                                    menuId: item.menuId ?? 0,
                                    type: item.menuType ?? "",
                                  ),
                                ),
                              );
                            },
                          ),
                          // Logika Hapus (Ganti String "1" atau int 1 sesuai model)
                          if (item.allowDelete == "1" || item.allowDelete == "true")
                            _buildActionButton(
                              icon: Icons.delete,
                              label: "Hapus",
                              color: Colors.red,
                              onTap: () => onDeleteMenu(item),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildActionButton({required IconData icon, required String label, Color color = Colors.black87, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 13, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_symbols, color: Colors.grey, size: 50),
          Text("Data kosong", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLoading(Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list, color: color, size: 50),
          Text("Memuat data...", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _getThemeColor(String tab) {
    switch (tab) {
      case "Pemasukan": return Colors.green.shade300;
      case "Pengeluaran": return Colors.pink.shade300;
      case "Hutang": return Colors.amber.shade300;
      case "Piutang": return Colors.blue.shade300;
      default: return Colors.grey;
    }
  }
}