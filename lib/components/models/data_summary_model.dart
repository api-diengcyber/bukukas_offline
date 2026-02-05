import 'package:keuangan/db/tb_menu.dart';
import 'package:keuangan/db/model/tb_menu_model.dart'; // Tambahkan import ini

class DebtMenuStatusModel {
  int? belum;
  int? lunas;

  DebtMenuStatusModel({
    this.belum,
    this.lunas,
  });
}

class DataSummaryModel {
  int? total;
  int? totalByType;
  // PERBAIKAN: Ganti dari TbMenu menjadi TbMenuModel
  List<TbMenuModel>? listAvailableMenuType; 
  DebtMenuStatusModel? debtMenuStatus;

  DataSummaryModel({
    this.total,
    this.totalByType,
    this.listAvailableMenuType,
    this.debtMenuStatus,
  });
}
