import 'package:keuangan/db/model/tb_menu_model.dart';
import 'package:keuangan/helpers/set_menus.dart';
import 'package:keuangan/providers/report_bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../pages/report/detail/report_menu_detail_page.dart';

class TabReportMenu extends StatefulWidget {
  const TabReportMenu({Key? key}) : super(key: key);

  @override
  State<TabReportMenu> createState() => _TabReportMenuState();
}

class _TabReportMenuState extends State<TabReportMenu> {
  final formatCurrency = NumberFormat.simpleCurrency(
    locale: 'id_ID',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final reportBloc = context.watch<ReportBloc>();

    // 1. Ambil data mentah dari Bloc
    final List<TbMenuModel> rawMenus = reportBloc.listAvailableMenuType ?? [];

    // 2. LOGIKA FILTERING: Filter list berdasarkan tab yang aktif
    List<TbMenuModel> listMenu = [];
    if (reportBloc.activeMenuTab == "Semua") {
      listMenu = rawMenus;
    } else {
      // Hanya masukkan menu yang tipenya SAMA dengan tab yang dipilih user
      listMenu = rawMenus.where((m) => m.type == reportBloc.activeMenuTab).toList();
    }

    Color colorT = _getTabColor(reportBloc.activeMenuTab);

    if (reportBloc.loadingSummary || reportBloc.loadingMenus) {
      return _buildLoadingState(colorT);
    }

    // 3. Cek apakah setelah di-filter datanya ada atau tidak
    if (listMenu.isEmpty) {
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
              padding: EdgeInsets.zero,
              itemCount: listMenu.length,
              itemBuilder: (context, index) {
                TbMenuModel data = listMenu[index];
                DateTime? deadlineDate = DateTime.tryParse(data.deadline ?? "");

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                  margin: const EdgeInsets.only(bottom: 8, left: 12, right: 12),
                  decoration: BoxDecoration(
                    color: activeTabColor(data.type ?? "", labelsColor),
                    borderRadius: BorderRadius.circular(20), // Lebih membulat agar modern
                    boxShadow: [
                      BoxShadow(
                        color: activeTabColor(data.type ?? "", chipsColor),
                        blurRadius: 0.2,
                        offset: const Offset(0, 0.1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              data.name ?? "Tanpa Nama",
                              style: TextStyle(
                                color: activeTabColor(data.type ?? "", reportActiveTabColor),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            if (data.notes != null && data.notes != "")
                              Text(
                                data.notes!,
                                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black54),
                              ),
                            const SizedBox(height: 6),
                            Row(
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: _buildValueText(data),
                                ),
                                const Spacer(),
                                // Badge Jatuh Tempo hanya untuk Hutang/Piutang
                                if (deadlineDate != null && (data.type == "Hutang" || data.type == "Piutang"))
                                  _buildDeadlineBadge(data, deadlineDate),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.bottomToTop,
                              child: ReportMenuDetailPage(
                                menuId: data.id ?? 0,
                                type: data.type ?? "",
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.arrow_forward_ios, // Ganti icon agar lebih bersih
                          size: 18,
                          color: activeTabColor(data.type ?? "", reportActiveTabColor),
                        ),
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

  Widget _buildDeadlineBadge(TbMenuModel data, DateTime deadline) {
    bool isLunas = data.statusPaidOff == "Lunas";
    return Container(
      decoration: BoxDecoration(
        color: isLunas ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        DateFormat("dd-MM-yyyy").format(deadline),
        style: TextStyle(
          color: isLunas ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildValueText(TbMenuModel data) {
    double total = double.tryParse(data.total ?? "0") ?? 0;
    if (total == 0 && (data.type == "Hutang" || data.type == "Piutang") && data.statusPaidOff == "Lunas") {
      return const Text("LUNAS", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12));
    }
    return Text(
      formatCurrency.format(total),
      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13),
    );
  }

  Color _getTabColor(String tab) {
    switch (tab) {
      case "Pemasukan": return Colors.green.shade400;
      case "Pengeluaran": return Colors.pink.shade400;
      case "Hutang": return Colors.amber.shade600;
      case "Piutang": return Colors.blue.shade600;
      default: return Colors.grey;
    }
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, color: Colors.grey, size: 50),
          SizedBox(height: 10),
          Text("Tidak ada kategori di tab ini", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLoadingState(Color color) {
    return Center(
      child: CircularProgressIndicator(color: color),
    );
  }
}