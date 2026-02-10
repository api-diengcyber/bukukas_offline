import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:keuangan/db/model/tb_transaksi_model.dart'; 
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

    final List<TbTransaksiModel> listData = (reportBloc.data != null && reportBloc.data['list'] != null)
        ? reportBloc.data['list']
        : [];

    onDeleteMenu(TbTransaksiModel data) async {
      // PERBAIKAN 1: Gunakan DateTime.tryParse agar fleksibel (Bebas error 'T')
      DateTime tempDate = DateTime.tryParse(data.transactionDate ?? "") ?? DateTime.now();
      
      // PERBAIKAN 2: Gunakan int.tryParse (Bebas error isNegative)
      int valIn = int.tryParse(data.valueIn?.toString() ?? "0") ?? 0;
      int valOut = int.tryParse(data.valueOut?.toString() ?? "0") ?? 0;
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
            // Refresh data setelah hapus
            await ReportModel().getTabsData(context);
            await ReportModel().getSummaryReport(context);
          }
        },
      ).show();
    }

    Color colorT = _getThemeColor(reportBloc.activeMenuTab);

    if (reportBloc.loadingSummary || reportBloc.loadingData) {
      return _buildLoading(colorT);
    }

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
                TbTransaksiModel item = listData[index];
                
                // PERBAIKAN 3: Proteksi tryParse di dalam list
                DateTime itemDate = DateTime.tryParse(item.transactionDate ?? "") ?? DateTime.now();
                int vIn = int.tryParse(item.valueIn?.toString() ?? "0") ?? 0;
                int vOut = int.tryParse(item.valueOut?.toString() ?? "0") ?? 0;

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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.menuName ?? "Tanpa Nama",
                              style: TextStyle(
                                color: activeTabColor(item.menuType ?? "", reportActiveTabColor),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          // Indikator Jenis Transaksi
                          Text(
                            item.menuType ?? "",
                            style: const TextStyle(fontSize: 10, color: Colors.black38, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      if (item.menuNotes != null && item.menuNotes != "")
                        Text(
                          item.menuNotes!,
                          style: const TextStyle(fontWeight: 
                          FontWeight.bold, 
                          fontSize: 13, 
                          color: Colors.black54),
                        ),
                      Text(
                        DateFormat("dd MMM yyyy, HH:mm").format(itemDate),
                        style: const TextStyle(color: Colors.black45, fontSize: 12),
                      ),
                      if (item.notes != null && item.notes != "")
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            "Catatan: ${item.notes}",
                            style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 1,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text(
                              formatCurrency.format(vIn - vOut),
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (item.debtType != "NON" && item.debtType != null)
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              decoration: BoxDecoration(
                                color: Colors.white54,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              child: Text(
                                "${item.debtType} ${item.menuType?.toLowerCase()}",
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Divider(height: 20),
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

  Widget _buildActionButton({required IconData icon, required String label, Color color = Colors.black87, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
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
          Icon(Icons.insert_chart_outlined, color: Colors.grey, size: 60),
          SizedBox(height: 10),
          Text("Belum ada transaksi", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLoading(Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: color),
          const SizedBox(height: 10),
          Text("Menyusun laporan...", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _getThemeColor(String tab) {
    switch (tab) {
      case "Pemasukan": return Colors.green;
      case "Pengeluaran": return Colors.pink;
      case "Hutang": return Colors.amber;
      case "Piutang": return Colors.blue;
      default: return Colors.blueGrey;
    }
  }
}