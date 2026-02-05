import 'package:keuangan/db/tb_installed.dart';
import 'package:keuangan/db/tb_menu.dart';
import 'package:keuangan/db/tb_transaksi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DB {
  // 1. Definisikan static instance
  static final DB instance = DB._init();

  // 2. Buat internal database variable
  static Database? _database;

  // 3. Private constructor
  DB._init();

  // Getter untuk mendapatkan database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('bukukas.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
    );
  }

  // Method untuk inisialisasi semua tabel
  Future<void> initTables() async {
    await TbInstalled().init();
    await TbMenu().init();
    await TbTransaksi().init();
    
    // Logika data awal
    await TbMenu().initData();
    await TbInstalled().create();
  }
  
  // Helper agar code lama kamu tetap jalan
  Future<Database> getDB() async {
    return await database;
  }
  // Di dalam class DB di file lib/db/db.dart
Future<void> closeDatabase() async {
  if (_database != null) {
    await _database!.close();
    _database = null; // Reset instance agar bisa di-init ulang
  }
}
}