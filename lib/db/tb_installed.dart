import 'package:keuangan/db/db.dart';
import 'package:sqflite/sqflite.dart';

class TbInstalled extends DB {
  Future<void> init() async {
    Database database = await getDB();
    await database.execute("CREATE TABLE IF NOT EXISTS installed (id INTEGER)");
    // await database.rawDelete("DELETE FROM installed");
  }

  Future<void> create() async {
    if (await countAll() == 0) {
      Database database = await getDB();
      int id1 = await database.rawInsert('INSERT INTO installed(id) VALUES(2)');
      print('inserted1: $id1');
    }
  }

  Future<int> countAll() async {
    Database database = await getDB();
    return Sqflite.firstIntValue(
            await database.rawQuery('SELECT COUNT(*) FROM installed')) ??
        0;
  }
}
