import 'package:keuangan/db/db.dart';
import 'package:keuangan/db/model/tb_menu_model.dart';
import 'package:keuangan/db/tb_installed.dart';
import 'package:sqflite/sqflite.dart';

class TbMenu extends DB {
  Future<void> init() async {
    Database database = await getDB();
    await database.execute(
        "CREATE TABLE IF NOT EXISTS menu (id INTEGER PRIMARY KEY, name TEXT, type TEXT, notes TEXT, defaultValue TEXT, total TEXT, paid TEXT, deadline TEXT, statusPaidOff TEXT, createdOn TEXT)");
  }

  Future<void> create(List<TbMenuModel> listData) async {
    Database database = await getDB();
    await database.transaction((txn) async {
      listData.map((data) async {
        await txn.rawInsert(
            'INSERT INTO menu(name,type,notes,defaultValue,total,paid,deadline,statusPaidOff,createdOn) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [
              data.name,
              data.type,
              data.notes,
              data.defaultValue,
              data.total,
              data.paid,
              data.deadline,
              data.statusPaidOff,
              data.createdOn
            ]);
      });
    });
  }

  Future<void> initData() async {
    int countInstall = await TbInstalled().countAll();
    if (countInstall == 0) {
      reset();
      List<TbMenuModel> data = [
        TbMenuModel(
          name: 'Test',
          type: MenuType.pemasukan,
          notes: '',
          defaultValue: '',
          total: '',
          paid: '',
          deadline: '',
          statusPaidOff: '',
          createdOn: '',
        ),
      ];
      create(data);
    }
  }

  Future<void> reset() async {
    Database database = await getDB();
    await database.rawDelete("DELETE FROM transaksi");
  }
}
