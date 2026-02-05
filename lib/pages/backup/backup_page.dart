import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restart_app/restart_app.dart';
import '../../utils/pref_helper.dart';
import '../../services/backup_service.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  bool _isPremium = false;
  bool _isLoading = false;
  String _lastBackup = "Belum pernah";
  List<dynamic> _history = [];

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  // Fungsi untuk mengecek status premium dan load history lokal jika ada
  Future<void> _checkStatus() async {
    bool premium = await PrefHelper.isPremium();
    String last = await PrefHelper.getLastBackup();
    String email = await PrefHelper.getUserEmail();
    
    setState(() {
      _isPremium = premium;
      _lastBackup = last;
    });

    if (premium && email.isNotEmpty) {
      _loadHistory();
    }
  }

  // Mengambil history dari server berdasarkan email & pass yang tersimpan
  Future<void> _loadHistory() async {
    try {
      String email = await PrefHelper.getUserEmail();
      String pass = await PrefHelper.getUserPass();
      if (email.isEmpty || pass.isEmpty) return;

      var data = await BackupService().fetchHistory(email, pass); 
      if (mounted) setState(() => _history = data);
    } catch (e) {
      debugPrint("Error History: $e");
    }
  }

  // --- FITUR BARU: LOGIN UNTUK TARIK DATA (GANTI HP) ---
  Future<void> _handleLoginRestore() async {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Login Akun Backup"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Masukkan email dan password lama untuk menarik data backup Anda."),
            const SizedBox(height: 15),
            TextField(
              controller: emailController, 
              decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passController, 
              decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("BATAL")),
          ElevatedButton(
            onPressed: () async {
              String email = emailController.text.trim();
              String pass = passController.text.trim();
              if (email.isEmpty || pass.isEmpty) return;

              Navigator.pop(context);
              setState(() => _isLoading = true);
              
              try {
                // Panggil history untuk memvalidasi apakah akun ada
                var data = await BackupService().fetchHistory(email, pass);
                
                if (data.isNotEmpty) {
                  // Jika ada data, simpan kredensial ke pref agar sinkron
                  await PrefHelper.saveUserEmail(email);
                  await PrefHelper.saveUserPass(pass);
                  
                  if (mounted) {
                    setState(() {
                      _history = data;
                      _isPremium = true; // Otomatis aktifkan fitur jika data ditemukan
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Berhasil masuk! Riwayat backup ditemukan."), backgroundColor: Colors.green)
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Akun ditemukan, tapi belum ada riwayat backup."), backgroundColor: Colors.orange)
                  );
                }
                _checkStatus();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Gagal menarik data: Email/Password mungkin salah"), backgroundColor: Colors.red)
                );
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: const Text("MASUK & TARIK DATA"),
          ),
        ],
      ),
    );
  }

  // Handler Proses Backup
  Future<void> _handleBackup() async {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passController = TextEditingController();
    emailController.text = await PrefHelper.getUserEmail();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Backup"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: passController, decoration: const InputDecoration(labelText: "Password Backup"), obscureText: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("BATAL")),
          ElevatedButton(
            onPressed: () async {
              String email = emailController.text.trim();
              String pass = passController.text.trim();
              if (email.isEmpty || pass.isEmpty) return;

              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                await BackupService().uploadDatabase(email, pass);
                await PrefHelper.saveUserEmail(email);
                await PrefHelper.saveUserPass(pass);
                await PrefHelper.saveLastBackup(DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now()));
                
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Backup Berhasil!"), backgroundColor: Colors.green));
                _checkStatus();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red));
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: const Text("MULAI BACKUP"),
          ),
        ],
      ),
    );
  }

  // Handler Proses Restore
  Future<void> _handleRestore(int id) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Restore Data?"),
        content: const Text("Data lokal akan ditimpa dengan data backup ini. Lanjutkan?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("BATAL")),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("YA, RESTORE"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await BackupService().restoreDatabase(id);
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text("Berhasil"),
              content: const Text("Data telah direstore. Aplikasi harus dimulai ulang."),
              actions: [ElevatedButton(onPressed: () => Restart.restartApp(), child: const Text("RESTART"))],
            ),
          );
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Backup & Restore Cloud"),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          // TOMBOL LOGIN / TARIK DATA RAHASIA (ICON DOWNLOAD)
          IconButton(
            icon: const Icon(Icons.cloud_download), 
            tooltip: 'Tarik data dari HP lama',
            onPressed: _handleLoginRestore,
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadHistory),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : (_isPremium ? _buildHistoryList() : _buildLockedFitur()),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.blue.withOpacity(0.05),
      child: Row(
        children: [
          const Icon(Icons.cloud_done, size: 50, color: Colors.blue),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Status Terakhir:", style: TextStyle(color: Colors.grey)),
                Text(_lastBackup, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isPremium ? Colors.amber : Colors.grey,
              borderRadius: BorderRadius.circular(20)
            ),
            child: Text(_isPremium ? "PREMIUM" : "FREE", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_history.isEmpty) return const Center(child: Text("Belum ada riwayat backup di cloud."));
    return ListView.builder(
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        return ListTile(
          leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
          title: Text(item['filename'] ?? "Backup File"),
          subtitle: Text("${item['created_at']} • ${item['file_size']}"),
          trailing: IconButton(
            icon: const Icon(Icons.settings_backup_restore, color: Colors.green),
            onPressed: () => _handleRestore(int.parse(item['id'].toString())),
          ),
        );
      },
    );
  }

  Widget _buildLockedFitur() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock, size: 60, color: Colors.grey),
          const SizedBox(height: 10),
          const Text("Fitur Cloud Backup khusus Premium", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () {}, child: const Text("Upgrade Sekarang"))
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: _isPremium ? _handleBackup : null,
          icon: const Icon(Icons.cloud_upload),
          label: const Text("BACKUP DATA SEKARANG"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}