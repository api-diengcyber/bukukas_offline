import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:keuangan/components/panel/panel_dashboard.dart';
import 'package:keuangan/components/panel/panel_menu_button.dart';
import 'package:keuangan/components/panel/panel_chart.dart';
import 'package:keuangan/components/panel/panel_transaction.dart';
import 'package:flutter/material.dart';
import 'package:keuangan/pages/dashboard/dashboard_controller.dart';
import 'package:keuangan/pages/paywall/paywall_page.dart';
import 'package:provider/provider.dart'; // Tambahkan ini
import 'package:url_launcher/url_launcher.dart';
import '../../components/modal/modal_manage_bukukas.dart'; // Import modal baru
import '../../providers/global_bloc.dart'; // Import GlobalBloc
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
    
    // Inisialisasi data berdasarkan ID Buku Kas yang tersimpan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final globalBloc = Provider.of<GlobalBloc>(context, listen: false);
      dashboardController.getDashboard(globalBloc.activeBukukasId);
    });
  }

  // --- FUNGSI UNTUK MEMBUKA PENGELOLA BUKU KAS ---
  void _openManageBukukas() {
    showDialog(
      context: context,
      builder: (context) => const ManageBukukasModal(),
    ).then((value) {
      if (value == 'changed') {
        // Jika user pindah buku, refresh data dashboard berdasarkan ID baru
        final globalBloc = Provider.of<GlobalBloc>(context, listen: false);
        dashboardController.getDashboard(globalBloc.activeBukukasId);
      }
    });
  }

  // --- FUNGSI DIALOG BANTUAN TEKNIS ---
  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
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
    // Ambil data dari GlobalBloc untuk memantau nama buku aktif
    final globalBloc = context.watch<GlobalBloc>();

    AppBar appBar = AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: const Color(0x00000000),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.help_outline, color: Colors.black),
        tooltip: 'Bantuan Teknis',
        onPressed: () => _showSupportDialog(context),
      ),
      // --- JUDUL DIUBAH MENJADI TOMBOL PILIH BUKUKAS ---
      title: InkWell(
        onTap: _openManageBukukas,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_balance_wallet, size: 18, color: Colors.black54),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  globalBloc.activeBukukasName, // Menampilkan nama buku aktif
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.black54),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.workspace_premium, color: Colors.amber, size: 28),
          tooltip: 'Fitur Pro',
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PaywallPage()));
          },
        ),
        const SizedBox(width: 8),
      ],
    );

    double marginTopScreen = appBar.preferredSize.height + MediaQuery.of(context).viewPadding.top;
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
          child: RefreshIndicator(
            onRefresh: () => dashboardController.getDashboard(globalBloc.activeBukukasId),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  if (dashboardController.loading)
                    const LinearProgressIndicator(minHeight: 2, color: Colors.amber),
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
      ),
    );
  }
}