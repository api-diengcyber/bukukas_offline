import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:keuangan/components/panel/panel_dashboard.dart';
import 'package:keuangan/components/panel/panel_menu_button.dart';
import 'package:keuangan/components/panel/panel_chart.dart';
import 'package:keuangan/components/panel/panel_transaction.dart';
import 'package:flutter/material.dart';
import 'package:keuangan/pages/dashboard/dashboard_controller.dart';
import 'package:keuangan/pages/paywall/paywall_page.dart';
import 'package:url_launcher/url_launcher.dart'; // Import ini untuk membuka website
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

  // --- FUNGSI DIALOG BANTUAN TEKNIS ---
  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Row(
            children: [
              Icon(Icons.support_agent, color: Colors.blue),
              SizedBox(width: 10),
              Text("Bantuan Teknis"),
            ],
          ),
          content: const Text(
            "Anda akan diarahkan ke website Dieng Cyber untuk mendapatkan bantuan teknis. Lanjutkan?",
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(context);
                final Uri url = Uri.parse('https://diengcyber.com');
                if (!await launchUrl(url,
                    mode: LaunchMode.externalApplication)) {
                  Get.snackbar("Error", "Tidak dapat membuka website");
                }
              },
              child: const Text("Kunjungi Website"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: const Color(0x00000000),
      elevation: 0,
      centerTitle: true,
      // --- TAMBAHKAN ICON BANTUAN DI SINI ---
      leading: IconButton(
        icon: const Icon(Icons.help_outline, color: Colors.black),
        tooltip: 'Bantuan Teknis',
        onPressed: () => _showSupportDialog(context),
      ),
      title: const Text(
        'BukuKas',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.workspace_premium,
              color: Colors.amber, size: 28),
          tooltip: 'Fitur Pro',
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
