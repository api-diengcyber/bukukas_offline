import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:keuangan/components/panel/panel_dashboard.dart';
import 'package:keuangan/components/panel/panel_menu_button.dart';
import 'package:keuangan/components/panel/panel_chart.dart';
import 'package:keuangan/components/panel/panel_transaction.dart';
import 'package:flutter/material.dart';
import 'package:keuangan/pages/dashboard/dashboard_controller.dart';
import 'package:keuangan/pages/paywall/paywall_page.dart';
import '../backup/backup_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late DashboardController dashboardController;
  GlobalKey keyAddButton = GlobalKey();

  @override
  void initState() {
    super.initState();
    dashboardController = Get.put(DashboardController());
  }

  // --- FUNGSI POPUP FITUR PREMIUM ---
  void _showPremiumModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.workspace_premium, color: Colors.amber, size: 30),
              SizedBox(width: 10),
              Text("Fitur Premium",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPremiumItem(Icons.picture_as_pdf, "Export PDF & Excel",
                  "Simpan laporan ke file dokumen."),
              _buildPremiumItem(Icons.send_to_mobile, "Kirim WhatsApp",
                  "Bagikan laporan langsung ke WA."),
              _buildPremiumItem(Icons.cloud_upload, "Backup Cloud",
                  "Amankan data Anda di server online.", onTap: () {
                Navigator.pop(context); // Tutup modal
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BackupPage()));
              }),
              _buildPremiumItem(Icons.support_agent, "Bantuan Teknis",
                  "Prioritas bantuan jika ada kendala."),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("DAPATKAN AKSES SEKARANG",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // Widget Helper untuk Baris Item Premium
  Widget _buildPremiumItem(IconData icon, String title, String desc,
      {VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap, // Tambahkan ini
      leading: Icon(icon, color: Colors.blueGrey),
      contentPadding: EdgeInsets.zero,
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(desc, style: const TextStyle(fontSize: 12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: const Color(0x00000000),
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'BukuKas',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      // --- TAMBAHKAN ICON MAHKOTA DI SINI ---
      actions: [
        IconButton(
          icon: const Icon(Icons.workspace_premium,
              color: Colors.amber, size: 28),
          tooltip: 'Premium Fitur',
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const PaywallPage()));
          },
        ),
        const SizedBox(width: 8),
      ],
    );

    double marginTopScreen =
        appBar.preferredSize.height + MediaQuery.of(context).viewPadding.top;
    double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Obx(
      () => Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        appBar: appBar,
        body: Container(
          constraints: const BoxConstraints.expand(),
          color: Colors.grey.shade100,
          padding: EdgeInsets.only(
            top: marginTopScreen,
            left: 10,
            right: 10,
            bottom: bottomPadding > 0 ? bottomPadding : 12,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                SizedBox(
                  height: dashboardController.loading ? 1 : 0,
                ),
                const PanelDashboard(),
                const SizedBox(height: 10),
                const SizedBox(
                  height: 180,
                  child: PanelChart(),
                ),
                const SizedBox(height: 10),
                PanelMenuButton(
                  buttonAddKey: keyAddButton,
                ),
                const SizedBox(height: 10),
                const PanelTransaction(),
                const SizedBox(height: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
