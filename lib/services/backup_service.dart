import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../db/db.dart';

class BackupService {
  final Dio _dio = Dio();
  // Sesuaikan URL API backend Anda
  final String _baseUrl = "https://backup.aipos.id/api/bukukas/backup"; 

  /// Fungsi untuk mengunggah seluruh database (Berisi SEMUA Buku Kas)
  Future<void> uploadDatabase(String email, String password) async {
    try {
      // 1. Dapatkan lokasi folder database yang benar
      final dbDir = await getDatabasesPath(); 
      final dbPath = p.join(dbDir, 'bukukas.db'); 
      
      File dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        throw Exception("Database tidak ditemukan. Pastikan Anda sudah membuat transaksi.");
      }

      // 2. Siapkan data untuk dikirim
      // Tips: Nama file ditambahkan timestamp agar tidak bentrok di server
      FormData formData = FormData.fromMap({
        "email": email,
        "password": password,
        "backup_file": await MultipartFile.fromFile(
          dbFile.path,
          filename: "all_bukukas_${DateTime.now().millisecondsSinceEpoch}.db",
        ),
      });

      // 3. Proses Upload
      Response response = await _dio.post("$_baseUrl/upload", data: formData);
      
      if (response.statusCode != 200 && response.statusCode != 201) {
         throw Exception("Gagal mengunggah: Server merespon ${response.statusCode}");
      }
    } catch (e) {
      print("Backup Error: $e");
      rethrow;
    }
  }

  /// Mengambil riwayat backup dari server
  Future<List<dynamic>> fetchHistory(String email, String password) async {
    try {
      Response response = await _dio.post("$_baseUrl/history", data: {
        "email": email,
        "password": password,
      });
      return response.data['status'] == true ? response.data['data'] : [];
    } catch (e) {
      return [];
    }
  }

  /// Mengunduh dan menimpa database lokal dengan hasil backup
  Future<void> restoreDatabase(int backupId) async {
    try {
      // 1. Tentukan path database tujuan (Harus sama dengan lokasi DB aktif)
      final dbDir = await getDatabasesPath();
      final dbPath = p.join(dbDir, 'bukukas.db');

      // 2. WAJIB: Tutup koneksi database sebelum file ditimpa
      // Jika tidak ditutup, aplikasi akan crash atau data korup
      await DB.instance.closeDatabase();

      // 3. Download file dari server dan langsung simpan ke path database
      await _dio.download(
        "$_baseUrl/download/$backupId", 
        dbPath, 
        deleteOnError: true,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print("Restore Progress: ${(received / total * 100).toStringAsFixed(0)}%");
          }
        }
      );

      // 4. Inisialisasi ulang tabel setelah restore selesai
      // Ini memastikan kolom-kolom baru tetap ada jika file restore adalah versi lama
      await DB.instance.initTables();
      
    } catch (e) {
      print("Restore Error: $e");
      rethrow;
    }
  }
}