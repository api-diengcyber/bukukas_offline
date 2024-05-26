import 'dart:convert';

import 'package:keuangan/db/db.dart';
import 'package:keuangan/db/model/tb_transaksi_model.dart';
import 'package:sqflite/sqflite.dart';

class TbTransaksi extends DB {
  Future<void> init() async {
    Database database = await getDB();
    await database.execute(
        "CREATE TABLE IF NOT EXISTS transaksi (id INTEGER PRIMARY KEY, transactionDate TEXT, notes TEXT, valueIn TEXT, valueOut TEXT, debtType TEXT, createdOn TEXT, allowDelete TEXT, menuId INTEGER)");
  }

  Future<List<TbTransaksiModel>> getData(String? type) async {
    Database database = await getDB();
    String whereStr = "";
    if (type != null && type != 'Semua') {
      whereStr += "WHERE b.type='$type'";
    }
    List<Map> list = await database.rawQuery(
        'SELECT a.*, b.name AS menuName, b.type AS menuType FROM transaksi a JOIN menu b ON a.menuId=b.id $whereStr');
    return tbTransaksiModelFromJson(jsonEncode(list));
  }
}
