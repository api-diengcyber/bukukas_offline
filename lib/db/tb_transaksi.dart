import 'package:keuangan/db/db.dart';
import 'package:sqflite/sqflite.dart';

class TbTransaksi extends DB {
  Future<void> init() async {
    Database database = await getDB();
    await database.execute(
        "CREATE TABLE IF NOT EXISTS transaksi (id INTEGER PRIMARY KEY, transactionDate TEXT, notes TEXT, valueIn TEXT, valueOut TEXT, debtType TEXT, createdOn TEXT, allowDelete TEXT, menuId INTEGER)");
  }
}
