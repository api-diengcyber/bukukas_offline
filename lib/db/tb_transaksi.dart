import 'dart:convert';
import 'package:keuangan/components/models/cart_model.dart';
import 'package:keuangan/db/db.dart';
import 'package:keuangan/db/model/tb_transaksi_model.dart';
import 'package:keuangan/utils/currency.dart';
import 'package:sqflite/sqflite.dart';

class TbTransaksi {
  Future<void> init() async {
    Database database = await DB.instance.getDB();
    // PERBAIKAN: Tambahkan kolom bukukasId pada saat pembuatan tabel
    await database.execute(
        "CREATE TABLE IF NOT EXISTS transaksi (id INTEGER PRIMARY KEY AUTOINCREMENT, transactionDate TEXT, notes TEXT, valueIn TEXT, valueOut TEXT, debtType TEXT, createdOn TEXT, allowDelete TEXT, menuId INTEGER, bukukasId INTEGER)");
  }

 // Cari fungsi getData di file tb_transaksi.dart dan ubah SELECT-nya
Future<List<TbTransaksiModel>> getData(String? type, int bukukasId) async {
  Database database = await DB.instance.getDB();
  String whereStr = " WHERE b.bukukasId = $bukukasId"; 
  if (type != null && type != 'Semua') {
    whereStr += " AND b.type='$type'";
  }
  
  // PERBAIKAN: Tambahkan b.notes AS menuNotes ke dalam query
  List<Map<String, dynamic>> list = await database.rawQuery(
      'SELECT a.*, b.name AS menuName, b.type AS menuType, b.notes AS menuNotes FROM transaksi a JOIN menu b ON a.menuId=b.id $whereStr');
  
  return list.map((e) => TbTransaksiModel.fromJson(e)).toList();
}

  Future<List<TbTransaksiModel>> getDataByMenuId(int? menuId) async {
    Database database = await DB.instance.getDB();
    List<Map<String, dynamic>> list = await database.rawQuery(
        'SELECT a.*, b.name AS menuName, b.type AS menuType FROM transaksi a JOIN menu b ON a.menuId=b.id WHERE a.menuId=?',
        [menuId]);
    return list.map((e) => TbTransaksiModel.fromJson(e)).toList();
  }

  Future<void> createByCart(List<CartModel> listData, int bukukasId) async {
    List<TbTransaksiModel> l = [];
    for (int i = 0; i < listData.length; i++) {
      l.add(TbTransaksiModel(
        transactionDate: listData[i].tgl,
        bukukasId: bukukasId, // Masukkan ID Buku Kas ke model
        valueIn: listData[i].gin,
        valueOut: listData[i].gout,
        notes: listData[i].notes,
        debtType: listData[i].debtType,
        menuId: listData[i].menuId,
        menuType: listData[i].type,
        menuDeadline: listData[i].deadline,
      ));
    }
    // PERBAIKAN: Kirim 2 argumen ke fungsi create
    await create(l, bukukasId);
  }

  // PERBAIKAN: Tambahkan parameter bukukasId di fungsi create
  Future<void> create(List<TbTransaksiModel> listData, int bukukasId) async {
    Database database = await DB.instance.getDB();
    await database.transaction((txn) async {
      for (int i = 0; i < listData.length; i++) {
        // PERBAIKAN: Tambahkan bukukasId ke dalam query INSERT
        await txn.rawInsert(
          'INSERT INTO transaksi(transactionDate,notes,valueIn,valueOut,debtType,createdOn,allowDelete,menuId,bukukasId) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            listData[i].transactionDate,
            listData[i].notes,
            currencyToDoubleString(listData[i].valueIn ?? "0"),
            currencyToDoubleString(listData[i].valueOut ?? "0"),
            listData[i].debtType,
            listData[i].createdOn,
            listData[i].allowDelete,
            listData[i].menuId,
            bukukasId, // Simpan ID Buku Kas aktif
          ],
        );
      }
    });
  }
}