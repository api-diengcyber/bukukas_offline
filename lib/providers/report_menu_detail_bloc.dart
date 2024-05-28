import 'package:flutter/material.dart';
import 'package:keuangan/db/model/tb_menu_model.dart';
import 'package:keuangan/db/model/tb_transaksi_model.dart';

class ReportMenuDetailBloc extends ChangeNotifier {
  List<TbTransaksiModel> _data = [];
  List<TbTransaksiModel> get data => _data;
  set data(List<TbTransaksiModel> val) {
    _data = val;
    notifyListeners();
  }

  TbMenuModel _detail = TbMenuModel();
  TbMenuModel get detail => _detail;
  set detail(TbMenuModel val) {
    _detail = val;
    notifyListeners();
  }

  bool _loading = false;
  bool get loading => _loading;
  set loading(bool val) {
    _loading = val;
    notifyListeners();
  }
}
