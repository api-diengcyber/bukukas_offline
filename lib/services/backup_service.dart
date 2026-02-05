import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../db/db.dart';
import 'package:sqflite/sqflite.dart';
import '../utils/pref_helper.dart';

class BackupService {
  final Dio _dio = Dio();
  final String _baseUrl = "https://backup.aipos.id/api/bukukas/backup"; // Sesuaikan URL CI4 kamu

  Future<void> uploadDatabase(String email, String password) async {
    try {
      // PERBAIKAN: Gunakan getDatabasesPath() bukan getApplicationDocumentsDirectory()
      final dbDir = await getDatabasesPath(); 
      final dbPath = p.join(dbDir, 'bukukas.db'); // Nama file harus sama dengan di DB Singleton
      
      File dbFile = File(dbPath);

      // Cek apakah file benar-benar ada di sana
      if (!await dbFile.exists()) {
        throw Exception("Database tidak ditemukan di: $dbPath");
      }

      FormData formData = FormData.fromMap({
        "email": email,
        "password": password,
        "backup_file": await MultipartFile.fromFile(
          dbFile.path,
          filename: "bukukas_${DateTime.now().millisecondsSinceEpoch}.db",
        ),
      });

      Response response = await _dio.post("$_baseUrl/upload", data: formData);
      
      if (response.statusCode != 200 && response.statusCode != 201) {
         throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> fetchHistory(String email, String password) async {
    Response response = await _dio.post("$_baseUrl/history", data: {
      "email": email,
      "password": password,
    });
    return response.data['status'] == true ? response.data['data'] : [];
  }

  Future<void> restoreDatabase(int id) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = p.join(documentsDirectory.path, 'bukukas.db');

    // WAJIB: Tutup koneksi sebelum menimpa file
    await DB.instance.closeDatabase();

    await _dio.download("$_baseUrl/download/$id", dbPath, deleteOnError: true);
  }
}