import 'package:get/get.dart';
import 'package:keuangan/components/circle_custom.dart';
import 'package:keuangan/db/model/tb_transaksi_model.dart'; // Import model
import 'package:keuangan/helpers/set_menus.dart';
import 'package:flutter/material.dart';
import 'package:keuangan/pages/dashboard/dashboard_controller.dart';
import 'package:intl/intl.dart';

class PanelTransaction extends StatefulWidget {
  const PanelTransaction({super.key});

  @override
  State<PanelTransaction> createState() => _PanelTransactionState();
}

class _PanelTransactionState extends State<PanelTransaction> {
  final formatCurrency = NumberFormat.simpleCurrency(locale: 'id_ID', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    // Cari controller yang sudah di-put di DashboardPage
    final dashboardController = Get.find<DashboardController>();

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 0.2,
            offset: const Offset(0, 0.1),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            width: double.infinity,
            child: const Text(
              "Transaksi Terbaru",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          // WAJIB PAKAI OBX AGAR LOADING BERHENTI SAAT DATA SIAP
          Obx(() {
            if (dashboardController.loading) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 26),
                child: Center(child: Text("Memuat...")),
              );
            }

            final List<TbTransaksiModel> list = dashboardController.dataDashboard["dataTransaction"] ?? [];

            if (list.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 26),
                child: Center(child: Text("Transaksi kosong", style: TextStyle(color: Colors.grey))),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length > 5 ? 5 : list.length, // Tampilkan 5 terbaru saja di dashboard
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                TbTransaksiModel item = list[index];
                
                // Parsing tanggal
                DateTime tempDate = DateTime.tryParse(item.transactionDate ?? "") ?? DateTime.now();
                int vIn = int.tryParse(item.valueIn ?? "0") ?? 0;
                int vOut = int.tryParse(item.valueOut ?? "0") ?? 0;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(178, 235, 235, 235),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        child: CircleCustom(
                          height: 10,
                          gradient: _getGradient(item.menuType),
                          active: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              item.menuName ?? "Tanpa Nama",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            if (item.notes != null && item.notes != "")
                              Text(item.notes!, style: const TextStyle(fontSize: 13)),
                            Text(
                              DateFormat("yyyy-MM-dd HH:mm").format(tempDate),
                              style: const TextStyle(color: Colors.black54, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    formatCurrency.format(vIn - vOut),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                                const Spacer(),
                                if (item.debtType != null && item.debtType != "NON")
                                  Text(
                                    "${item.debtType} ${item.menuType?.toLowerCase()}",
                                    style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                                  )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  // Helper untuk warna titik
  LinearGradient _getGradient(String? type) {
    if (type == "Pemasukan") return gradientActiveDMenu[0];
    if (type == "Pengeluaran") return gradientActiveDMenu[1];
    if (type == "Hutang") return gradientActiveDMenu[2];
    return gradientActiveDMenu[3];
  }
}