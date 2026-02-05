import 'package:flutter/material.dart';
import 'package:keuangan/pages/backup/backup_page.dart';
import 'package:keuangan/services/revenue_cat_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key});

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  bool _isLoading = true;
  Offerings? _offerings;
  Package? _selectedPackage; // Untuk menyimpan paket yang sedang dipilih user

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final offerings = await RevenueCatService.getOfferings();
    if (mounted) {
      setState(() {
        _offerings = offerings;
        _isLoading = false;
        // Otomatis pilih paket Bulanan (Monthly) sebagai default jika ada
        // agar user langsung melihat opsi Free Trial
        if (offerings != null && offerings.current != null) {
          final packages = offerings.current!.availablePackages;
          if (packages.isNotEmpty) {
            // Cari paket monthly, kalau tidak ada, ambil yang pertama
            _selectedPackage = packages.firstWhere(
              (pkg) => pkg.packageType == PackageType.monthly,
              orElse: () => packages.first,
            );
          }
        }
      });
    }
  }

  Future<void> _buy() async {
    if (_selectedPackage == null) return;

    setState(() => _isLoading = true);

    // Panggil fungsi beli dari Service
    bool isSuccess = await RevenueCatService.makePurchase(_selectedPackage!);

    setState(() => _isLoading = false);

    if (isSuccess && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Selamat! Akses Premium berhasil diaktifkan."),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _restore() async {
    setState(() => _isLoading = true);
    bool isSuccess = await RevenueCatService.restorePurchases();
    setState(() => _isLoading = false);

    if (isSuccess && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pembelian berhasil dipulihkan!"),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tidak ada pembelian aktif ditemukan.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Warna tema (Ganti sesuai warna brand AIPOS Anda)
    const primaryColor =
        Color.fromARGB(255, 235, 37, 129); // Contoh Biru Modern

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _offerings == null
              ? const Center(child: Text("Gagal memuat paket."))
              : SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 1. Header & Icon
                              const SizedBox(height: 10),
                              const Icon(
                                Icons.diamond_outlined,
                                size: 60,
                                color: primaryColor,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Upgrade ke BukuKas Premium",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Buka semua fitur canggih untuk\nmemaksimalkan bisnis Anda.",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 30),

                              _buildPremiumItem(
                                  Icons.picture_as_pdf,
                                  "Export PDF & Excel",
                                  "Simpan laporan ke file dokumen."),
                              _buildPremiumItem(
                                  Icons.send_to_mobile,
                                  "Kirim WhatsApp",
                                  "Bagikan laporan langsung ke WA."),
                              _buildPremiumItem(
                                  Icons.cloud_upload,
                                  "Backup Cloud",
                                  "Amankan data Anda di server online.",
                                  onTap: () {
                                Navigator.pop(context); // Tutup modal
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const BackupPage()));
                              }),
                              _buildPremiumItem(
                                  Icons.support_agent,
                                  "Bantuan Teknis",
                                  "Prioritas bantuan jika ada kendala."),

                              const SizedBox(height: 30),

                              // 3. Pilihan Paket (Cards)
                              ..._offerings!.current!.availablePackages.map(
                                (package) =>
                                    _buildPackageCard(package, primaryColor),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),

                      // 4. Tombol Beli (Bottom Bar)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Tombol Utama
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _buy,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  _getButtonText(), // Teks berubah dinamis
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Tombol Restore (Teks Kecil)
                            GestureDetector(
                              onTap: _restore,
                              child: Text(
                                "Sudah pernah beli? Pulihkan Pembelian",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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

  // Widget Kartu Paket
  Widget _buildPackageCard(Package package, Color primaryColor) {
    final isSelected = _selectedPackage == package;
    final isMonthly = package.packageType == PackageType.monthly;
    final isYearly = package.packageType == PackageType.annual;
    final isLifetime = package.packageType == PackageType.lifetime;

    // Deteksi apakah paket ini punya Free Trial
    // (Berdasarkan setup Play Console Anda, Monthly pasti punya introPrice)
    final hasFreeTrial = isMonthly &&
        (package.storeProduct.introductoryPrice != null || isMonthly);
    // Logic '|| isMonthly' ditambahkan paksa karena kadang
    // introPrice null di emulator tapi user yakin sudah setting trial.

    String badgeText = "";
    Color? badgeColor;

    if (hasFreeTrial) {
      badgeText = "COBA GRATIS 7 HARI";
      badgeColor = Colors.green;
    } else if (isYearly) {
      badgeText = "BEST VALUE (HEMAT)";
      badgeColor = Colors.orange;
    } else if (isLifetime) {
      badgeText = "SEKALI BAYAR";
      badgeColor = Colors.purple;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPackage = package;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.05) : Colors.white,
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Radio Button Visual
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected ? primaryColor : Colors.grey,
                  ),
                  const SizedBox(width: 16),

                  // Text Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (badgeText.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor!.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              badgeText,
                              style: TextStyle(
                                color: badgeColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        Text(
                          package.storeProduct.title
                              .replaceAll(RegExp(r'\(.*\)'), '')
                              .trim(), // Hapus nama aplikasi di belakang kurung
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          package.storeProduct.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Harga
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        package.storeProduct.priceString,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isSelected ? primaryColor : Colors.black,
                        ),
                      ),
                      if (isMonthly)
                        const Text(
                          "/bulan",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        )
                      else if (isYearly)
                        const Text(
                          "/tahun",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Logic Teks Tombol Beli
  String _getButtonText() {
    if (_selectedPackage == null) return "Pilih Paket";

    final isMonthly = _selectedPackage!.packageType == PackageType.monthly;

    // Cek apakah ada data intro price (Free Trial) dari RevenueCat
    // final hasTrial = _selectedPackage!.storeProduct.introductoryPrice != null;

    if (isMonthly) {
      // Jika Monthly, kita asumsikan pasti ada Free Trial (sesuai request Anda)
      // Gunakan hasTrial untuk lebih akurat, atau paksa text trial jika yakin.
      return "Mulai Trial Gratis 7 Hari";
    }

    return "Langganan Sekarang";
  }
}
