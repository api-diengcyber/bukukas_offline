import 'package:get/get.dart';
import 'package:keuangan/db/tb_bukukas.dart'; // Import TbBukukas
import 'package:keuangan/db/tb_transaksi.dart'; // Import TbTransaksi
import 'package:keuangan/pages/dashboard/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keuangan/pages/backup/backup_page.dart';
import 'package:keuangan/pages/paywall/paywall_page.dart';
import 'package:keuangan/services/revenue_cat_service.dart';
import 'package:keuangan/utils/pref_helper.dart';
import 'package:keuangan/helpers/export_service.dart'; 
import 'package:keuangan/db/model/tb_transaksi_model.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:share_plus/share_plus.dart';

class PanelDashboard extends StatefulWidget {
  const PanelDashboard({super.key});

  @override
  State<PanelDashboard> createState() => _PanelDashboardState();
}

class _PanelDashboardState extends State<PanelDashboard> {
  final formatCurrency = NumberFormat.simpleCurrency(
    locale: 'id_ID',
    decimalDigits: 0,
  );

  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _checkPremium();
  }

  Future<void> _checkPremium() async {
    bool status = await RevenueCatService.isUserPremium();
    if (mounted) {
      setState(() {
        _isPremium = status;
      });
    }
  }

  // --- 1. MODAL PILIH BUKUKAS UNTUK EXPORT ---
  void _showExportOptions(BuildContext context) async {
    // Ambil daftar semua buku kas yang tersedia
    List<Map<String, dynamic>> allBukukas = await TbBukukas().getAll();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Pilih Buku Kas untuk di Export",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              ListView.builder(
                shrinkWrap: true,
                itemCount: allBukukas.length,
                itemBuilder: (context, index) {
                  var buku = allBukukas[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.amber,
                      child: Icon(Icons.book, color: Colors.white, size: 20),
                    ),
                    title: Text(buku['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text("Klik untuk pilih format laporan"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pop(context);
                      // Lanjut ke pemilihan format file
                      _showFormatSelection(context, buku['id'], buku['name']);
                    },
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // --- 2. MODAL PILIH FORMAT (PDF / EXCEL) ---
  void _showFormatSelection(BuildContext context, int bukukasId, String bukukasName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Export Laporan: $bukukasName",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  title: const Text("Export ke PDF"),
                  onTap: () async {
                    Navigator.pop(context);
                    _processExport(bukukasId, "PDF");
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.table_chart, color: Colors.green),
                  title: const Text("Export ke Excel"),
                  onTap: () async {
                    Navigator.pop(context);
                    _processExport(bukukasId, "EXCEL");
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- 3. PROSES AMBIL DATA & EXPORT ---
  void _processExport(int bukukasId, String format) async {
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    // Ambil data transaksi khusus untuk Buku Kas yang dipilih
    List<TbTransaksiModel> dataToExport = await TbTransaksi().getData("Semua", bukukasId);

    Get.back(); // Tutup loading

    if (dataToExport.isEmpty) {
      Get.snackbar("Gagal", "Tidak ada data transaksi di buku kas ini.",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (format == "PDF") {
      ExportService().exportToPdf(dataToExport);
    } else {
      ExportService().exportToExcel(dataToExport);
    }
  }

  void _sendTextToWA(DashboardController controller) {
    String total = formatCurrency.format(controller.dataDashboard['total'] ?? 0);
    String today = formatCurrency.format(controller.dataDashboard['totalToday'] ?? 0);
    String message = "*LAPORAN RINGKAS BUKUKAS*\n\n"
        "📅 Tanggal: ${DateFormat('dd MMM yyyy').format(DateTime.now())}\n"
        "💰 Total Saldo: $total\n"
        "📈 Hari Ini: $today\n\n"
        "Dikirim otomatis dari aplikasi BukuKas.";

    Share.share(message);
  }

  void _showLockedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock, color: Colors.amber),
            SizedBox(width: 10),
            Text("Fitur Premium"),
          ],
        ),
        content: const Text("Fitur ini hanya tersedia untuk pengguna Premium."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("TUTUP")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PaywallPage()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700),
            child: const Text("UPGRADE"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.find<DashboardController>();

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        image: const DecorationImage(
          image: AssetImage("assets/images/lead.png"),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 0.2,
            offset: const Offset(0, 0.1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Text(
              "Dashboard Keuangan",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Column(
              children: [
                Obx(() => Row(
                      children: <Widget>[
                        _buildSaldoItem(
                            "Total Saldo",
                            dashboardController.dataDashboard['total'] ?? 0,
                            dashboardController.loading),
                        const SizedBox(width: 10),
                        _buildSaldoItem(
                            "Hari Ini",
                            dashboardController.dataDashboard['totalToday'] ?? 0,
                            dashboardController.loading),
                      ],
                    )),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, thickness: 0.5),
                ),
                Row(
                  children: [
                    _buildMenuItem(
                      label: "Export Laporan",
                      icon: Icons.picture_as_pdf,
                      color: Colors.red.shade400,
                      onTap: _isPremium
                          ? () => _showExportOptions(context) // Alur baru
                          : _showLockedDialog,
                    ),
                    const SizedBox(width: 12),
                    _buildMenuItem(
                      label: "Backup Cloud",
                      icon: Icons.cloud_upload,
                      color: Colors.blue.shade400,
                      onTap: _isPremium
                          ? () => Get.to(() => const BackupPage())
                          : _showLockedDialog,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaldoItem(String title, dynamic value, bool isLoading) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          isLoading
              ? SkeletonAnimation(
                  child: Container(
                      height: 20, width: 100, color: Colors.grey[200]))
              : Text(
                  formatCurrency.format(value),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      {required String label,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              if (!_isPremium) ...[
                const SizedBox(width: 4),
                const Icon(Icons.lock, size: 12, color: Colors.orange),
              ]
            ],
          ),
        ),
      ),
    );
  }
}