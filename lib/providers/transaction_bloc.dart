import 'package:flutter/material.dart';

class TransactionBloc extends ChangeNotifier {
  int _totalPages = 0;
  int get totalPages => _totalPages;
  set totalPages(int val) {
    _totalPages = val;
    notifyListeners();
  }

  int _page = 1;
  int get page => _page;
  set page(int val) {
    _page = val;
    notifyListeners();
  }

  bool _loading = false;
  bool get loading => _loading;
  set loading(bool val) {
    _loading = val;
    notifyListeners();
  }
}
