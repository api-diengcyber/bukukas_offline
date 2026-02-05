import 'dart:convert';
import 'package:keuangan/components/models/cart_model.dart';
import 'package:keuangan/db/db.dart';
import 'package:keuangan/db/model/tb_transaksi_model.dart';
import 'package:keuangan/utils/currency.dart';
import 'package:sqflite/sqflite.dart';

class TbTransaksi {
  Future<void> init() async {
    // Gunakan DB.instance.getDB()
    Database database = await DB.instance.getDB(); 
    await database.execute(
        "CREATE TABLE IF NOT EXISTS transaksi (id INTEGER PRIMARY KEY AUTOINCREMENT, transactionDate TEXT, notes TEXT, valueIn TEXT, valueOut TEXT, debtType TEXT, createdOn TEXT, allowDelete TEXT, menuId INTEGER)");
  }

 // tb_transaksi.dart
Future<List<TbTransaksiModel>> getData(String? type) async {
    Database database = await DB.instance.getDB(); // Perbarui di sini juga
    String whereStr = "";
    if (type != null && type != 'Semua') {
      whereStr = " WHERE b.type='$type'";
    }
    
    List<Map<String, dynamic>> list = await database.rawQuery(
        'SELECT a.*, b.name AS menuName, b.type AS menuType FROM transaksi a JOIN menu b ON a.menuId=b.id $whereStr');
    return list.map((e) => TbTransaksiModel.fromJson(e)).toList();
  }
  Future<List<TbTransaksiModel>> getDataByMenuId(int? menuId) async {
    Database database = await DB.instance.getDB();
    List<Map<String, dynamic>> list = await database.rawQuery(
        'SELECT a.*, b.name AS menuName, b.type AS menuType FROM transaksi a JOIN menu b ON a.menuId=b.id WHERE a.menuId=?', [menuId]);
    return list.map((e) => TbTransaksiModel.fromJson(e)).toList();
  }

  Future<void> createByCart(List<CartModel> listData) async {
    List<TbTransaksiModel> l = [];
    for (int i = 0; i < listData.length; i++) {
      l.add(TbTransaksiModel(
        transactionDate: listData[i].tgl,
        valueIn: listData[i].gin,
        valueOut: listData[i].gout,
        notes: listData[i].notes,
        debtType: listData[i].debtType,
        menuId: listData[i].menuId,
        menuType: listData[i].type,
        menuDeadline: listData[i].deadline,
      ));
    }
    await create(l);
  }

  Future<void> create(List<TbTransaksiModel> listData) async {
    Database database = await DB.instance.getDB();
    await database.transaction((txn) async {
      for (int i = 0; i < listData.length; i++) {
        await txn.rawInsert(
          'INSERT INTO transaksi(transactionDate,notes,valueIn,valueOut,debtType,createdOn,allowDelete,menuId) VALUES(?, ?, ?, ?, ?, ?, ?, ?)',
          [
            listData[i].transactionDate,
            listData[i].notes,
            currencyToDoubleString(listData[i].valueIn ?? "0"),
            currencyToDoubleString(listData[i].valueOut ?? "0"),
            listData[i].debtType,
            listData[i].createdOn,
            listData[i].allowDelete,
            listData[i].menuId,
          ],
        );
      }
    });
  }
}