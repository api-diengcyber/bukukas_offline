import 'package:keuangan/db/tb_menu.dart';

class CartModel {
  int? index;
  String? tgl;
  String? gin;
  String? gout;
  String? notes;
  String? deadline;
  String? debtType;
  String? type;
  int? menuId;
  TbMenu? menuDetail;

  CartModel({
    this.index,
    this.tgl,
    this.gin,
    this.gout,
    this.notes,
    this.deadline,
    this.debtType,
    this.type,
    this.menuId,
    this.menuDetail,
  });
}
