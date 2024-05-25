import 'package:flutter/material.dart';

class GlobalBloc extends ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;
  set loading(bool val) {
    _loading = val;
    notifyListeners();
  }

  String _tabMenuTransaction = "Pemasukan";
  String get tabMenuTransaction => _tabMenuTransaction;
  set tabMenuTransaction(String val) {
    _tabMenuTransaction = val;
    notifyListeners();
  }

  String _debtType = "Bayar";
  String get debtType => _debtType;
  set debtType(String val) {
    _debtType = val;
    notifyListeners();
  }

  bool _loadingMenus = false;
  bool get loadingMenus => _loadingMenus;
  set loadingMenus(bool val) {
    _loadingMenus = val;
    notifyListeners();
  }

  List<dynamic> _menus = [];
  List<dynamic> get menus => _menus;
  set menus(List<dynamic> val) {
    _menus = val;
    notifyListeners();
    notifyListeners();
  }

  double _totalCartNominal = 0;
  double get totalCartNominal => _totalCartNominal;
  set totalCartNominal(double val) {
    _totalCartNominal = val;
    notifyListeners();
  }

  List<dynamic> _cart = [];
  List<dynamic> get cart => _cart;
  set cart(List<dynamic> val) {
    _cart = val;
    notifyListeners();
  }
}
