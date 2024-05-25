import 'package:flutter/material.dart';

class CreateBloc extends ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;
  set loading(bool val) {
    _loading = val;
    notifyListeners();
  }

  int _page = 1;
  int get page => _page;
  set page(int val) {
    _page = val;
    notifyListeners();
  }

  int _totalPage = 1;
  int get totalPage => _totalPage;
  set totalPage(int val) {
    _totalPage = val;
    notifyListeners();
  }

  dynamic _data = [];
  dynamic get data => _data;
  set data(dynamic val) {
    _data = val;
    notifyListeners();
  }
}
