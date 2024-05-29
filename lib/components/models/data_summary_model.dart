import 'package:keuangan/db/tb_menu.dart';

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
  List<TbMenu>? listAvailableMenuType;
  DebtMenuStatusModel? debtMenuStatus;

  DataSummaryModel({
    this.total,
    this.totalByType,
    this.listAvailableMenuType,
    this.debtMenuStatus,
  });
}
