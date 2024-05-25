import 'package:keuangan/db/db.dart';
import 'package:keuangan/db/tb_installed.dart';
import 'package:sqflite/sqflite.dart';

class TbMenu extends DB {
  Future<void> init() async {
    Database database = await getDB();
    await database.execute(
        "CREATE TABLE IF NOT EXISTS menu (id INTEGER PRIMARY KEY, name TEXT, type TEXT, notes TEXT, defaultValue TEXT, total TEXT, paid TEXT, deadline TEXT, statusPaidOff TEXT, createdOn TEXT)");
  }

  Future<void> initData() async {
    int countInstall = await TbInstalled().countAll();
    if (countInstall == 0) {}
    print('count installed : $countInstall');
  }
}
