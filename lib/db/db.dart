import 'package:keuangan/db/tb_installed.dart';
import 'package:keuangan/db/tb_menu.dart';
import 'package:keuangan/db/tb_transaksi.dart';
import 'package:sqflite/sqflite.dart';

class DB {
  String name = 'bukukas.db';

  Future<String> getPath() async {
    var databasesPath = await getDatabasesPath();
    return "$databasesPath$name";
  }

  Future<Database> getDB() async {
    return await openDatabase(await getPath(), version: 1);
  }

  Future<void> initTables() async {
    await TbInstalled().init();
    await TbMenu().init();
    await TbTransaksi().init();
    await TbMenu().initData();
    await TbInstalled().create();
  }
}
