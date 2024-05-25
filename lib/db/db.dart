import 'package:keuangan/providers/global_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class DB {
  Database db;

  Future<void> init(context) async {
    // final globalBloc = Provider.of<GlobalBloc>(context, listen: false);
    var databasesPath = await getDatabasesPath();
    String path = "${databasesPath}bukukas.db";
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE installed (id INTEGER)");
      await db.execute(
          "CREATE TABLE menu (id INTEGER PRIMARY KEY, name TEXT, type TEXT, notes TEXT, defaultValue TEXT, total TEXT, paid TEXT, deadline TEXT, statusPaidOff TEXT, createdOn TEXT)");
      await db.execute(
          "CREATE TABLE transaksi (id INTEGER PRIMARY KEY, transactionDate TEXT, notes TEXT, valueIn TEXT, valueOut TEXT, debtType TEXT, createdOn TEXT, allowDelete TEXT)");
    });
    // globalBloc.db = db;
  }

  Future<void> installed(context) async {
    // final globalBloc = Provider.of<GlobalBloc>(context, listen: false);
    await db.transaction((txn) async {
      int id1 = await txn.rawInsert('INSERT INTO installed(id) VALUES(2)');
      print('inserted1: $id1');
    });
  }
}
