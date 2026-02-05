import 'package:keuangan/db/db.dart';
import 'package:sqflite/sqflite.dart';

class TbInstalled {
  Future<void> init() async {
    Database database = await DB.instance.getDB();
    await database.execute("CREATE TABLE IF NOT EXISTS installed (id INTEGER)");
  }

  Future<void> create() async {
    if (await countAll() == 0) {
      Database database = await DB.instance.getDB();
      int id1 = await database.rawInsert('INSERT INTO installed(id) VALUES(2)');
      print('inserted1: $id1');
    }
  }

  Future<int> countAll() async {
    Database database = await DB.instance.getDB();
    return Sqflite.firstIntValue(
            await database.rawQuery('SELECT COUNT(*) FROM installed')) ??
        0;
  }
}