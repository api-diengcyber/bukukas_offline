import 'dart:convert';

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
      for (int i = 0; i < listData.length; i++) {
        await txn.rawInsert(
          'INSERT INTO menu(name,type,notes,defaultValue,total,paid,deadline,statusPaidOff,createdOn) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            listData[i].name,
            listData[i].type,
            listData[i].notes,
            listData[i].defaultValue,
            listData[i].total,
            listData[i].paid,
            listData[i].deadline,
            listData[i].statusPaidOff,
            listData[i].createdOn
          ],
        );
      }
    });
  }

  Future<void> initData() async {
    int countInstall = await TbInstalled().countAll();
    if (countInstall == 0) {
      await reset();
      List<TbMenuModel> data = [
        TbMenuModel(
          name: 'Hasil Usaha',
          type: MenuType.Pemasukan.toString().split('.').last,
          notes: '',
          defaultValue: '',
          total: '',
          paid: '',
          deadline: '',
          statusPaidOff: '',
          createdOn: '',
        ),
      ];
      await create(data);
    }
  }

  Future<List<TbMenuModel>> getData(String? type) async {
    Database database = await getDB();
    String whereStr = "";
    if (type != null && type != 'Semua') {
      whereStr += "WHERE a.type='$type'";
    }
    List<Map> list = await database.rawQuery(
        'SELECT a.*, COUNT(b.id) AS totalTransaction FROM menu a LEFT JOIN transaksi b ON a.id=b.menuId $whereStr GROUP BY a.id');
    return tbMenuModelFromJson(jsonEncode(list));
  }

  Future<void> update(int id, String type, Map<String, dynamic> data) async {
    Database database = await getDB();
    TbMenuModel d = TbMenuModel.fromJson(data);
    await database.rawUpdate(
        "UPDATE menu SET name='${d.name}', notes='${d.notes ?? ""}', defaultValue='${d.defaultValue ?? ""}' WHERE id='$id'");
  }

  Future<void> delete(int id) async {
    Database database = await getDB();
    await database.rawDelete("DELETE FROM menu WHERE id=$id");
  }

  Future<void> reset() async {
    Database database = await getDB();
    await database.rawDelete("DELETE FROM menu");
  }
}
