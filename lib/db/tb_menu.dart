import 'dart:convert';
import 'package:keuangan/db/db.dart';
import 'package:keuangan/db/model/tb_menu_model.dart';
import 'package:keuangan/db/tb_installed.dart';
import 'package:keuangan/utils/currency.dart';
import 'package:sqflite/sqflite.dart';

class TbMenu {
  Future<void> init() async {
    Database database = await DB.instance.getDB();
    // Memastikan kolom bukukasId ada di tabel menu
    await database.execute(
        "CREATE TABLE IF NOT EXISTS menu (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, type TEXT, notes TEXT, defaultValue TEXT, total TEXT, paid TEXT, deadline TEXT, statusPaidOff TEXT, createdOn TEXT, bukukasId INTEGER)");
  }

  Future<void> create(List<TbMenuModel> listData, int bukukasId) async {
    Database database = await DB.instance.getDB();
    await database.transaction((txn) async {
      for (int i = 0; i < listData.length; i++) {
        await txn.rawInsert(
            'INSERT INTO menu(name,type,notes,defaultValue,total,paid,deadline,statusPaidOff,createdOn,bukukasId) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [
              listData[i].name,
              listData[i].type,
              listData[i].notes,
              currencyToDoubleString(listData[i].defaultValue ?? ""),
              currencyToDoubleString(listData[i].total ?? ""),
              listData[i].paid,
              listData[i].deadline,
              listData[i].statusPaidOff,
              listData[i].createdOn,
              bukukasId // SIMPAN ID BUKU KAS AKTIF
            ]);
      }
    });
  }

  Future<void> initData() async {
    int countInstall = await TbInstalled().countAll();
    if (countInstall == 0) {
      await reset();
      List<TbMenuModel> data = [
        TbMenuModel(
          name: 'Hasil Usaha',
          type: MenuType.Pemasukan.toString().split('.').last,
          notes: '',
          defaultValue: '',
          total: '',
          paid: '',
          deadline: '',
          statusPaidOff: '',
          createdOn: DateTime.now().toString(),
          bukukasId: 1, // Default ke Buku 1
        ),
      ];
      await create(data, 1); 
    }
  }

  Future<List<TbMenuModel>> getData(String? type, int bukukasId) async {
    Database database = await DB.instance.getDB();
    String whereStr = " WHERE a.bukukasId = $bukukasId";
    if (type != null && type != 'Semua') {
      whereStr += " AND a.type='$type'";
    }

    // Menggunakan SUM dan CAST karena valueIn/Out disimpan sebagai TEXT
    List<Map<String, dynamic>> list = await database.rawQuery('''
      SELECT 
        a.*, 
        COUNT(b.id) AS totalTransaction,
        SUM(CASE WHEN b.valueIn IS NOT NULL THEN CAST(b.valueIn AS REAL) ELSE 0 END) as totalIn,
        SUM(CASE WHEN b.valueOut IS NOT NULL THEN CAST(b.valueOut AS REAL) ELSE 0 END) as totalOut
      FROM menu a 
      LEFT JOIN transaksi b ON a.id = b.menuId 
      $whereStr 
      GROUP BY a.id
    ''');

    return list.map((e) {
      // 1. Hitung selisih nominal (Pemasukan - Pengeluaran)
      double tIn = double.tryParse(e['totalIn']?.toString() ?? "0") ?? 0;
      double tOut = double.tryParse(e['totalOut']?.toString() ?? "0") ?? 0;
      double balance = tIn - tOut;

      // 2. Map data ke model
      var dataMap = Map<String, dynamic>.from(e);
      
      // Jika balance negatif (misal Pengeluaran), kita jadikan positif untuk tampilan list per kategori
      dataMap['total'] = balance.abs().toString(); 
      dataMap['totalIn'] = tIn.toString();
      dataMap['totalOut'] = tOut.toString();

      return TbMenuModel.fromJson(dataMap);
    }).toList();
  }

  Future<TbMenuModel> getDataById(int? id) async {
    Database database = await DB.instance.getDB();
    List<Map<String, dynamic>> list = await database.rawQuery('''
        SELECT 
          a.*, 
          COUNT(b.id) AS totalTransaction,
          SUM(CASE WHEN b.valueIn IS NOT NULL THEN CAST(b.valueIn AS REAL) ELSE 0 END) as totalIn,
          SUM(CASE WHEN b.valueOut IS NOT NULL THEN CAST(b.valueOut AS REAL) ELSE 0 END) as totalOut
        FROM menu a 
        LEFT JOIN transaksi b ON a.id = b.menuId 
        WHERE a.id = ? 
        GROUP BY a.id 
        LIMIT 1
    ''', [id]);

    if (list.isEmpty) return TbMenuModel();

    double tIn = double.tryParse(list.first['totalIn']?.toString() ?? "0") ?? 0;
    double tOut = double.tryParse(list.first['totalOut']?.toString() ?? "0") ?? 0;
    
    var dataMap = Map<String, dynamic>.from(list.first);
    dataMap['total'] = (tIn - tOut).abs().toString();

    return TbMenuModel.fromJson(dataMap);
  }

  Future<void> update(int id, String type, Map<String, dynamic> data) async {
    Database database = await DB.instance.getDB();
    TbMenuModel d = TbMenuModel.fromJson(data);
    await database.rawUpdate(
        "UPDATE menu SET name=?, notes=?, defaultValue=? WHERE id=?",
        [d.name, d.notes ?? "", currencyToDoubleString(d.defaultValue ?? ""), id]);
  }

  Future<void> delete(int id) async {
    Database database = await DB.instance.getDB();
    await database.rawDelete("DELETE FROM menu WHERE id=?", [id]);
  }

  Future<void> reset() async {
    Database database = await DB.instance.getDB();
    await database.rawDelete("DELETE FROM menu");
  }
}