import 'package:keuangan/db/model/tb_menu_model.dart';

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
  TbMenuModel? menuDetail;

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
