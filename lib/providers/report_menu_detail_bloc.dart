import 'package:flutter/material.dart';

class ReportMenuDetailBloc extends ChangeNotifier {
  List<dynamic> _data = [];
  List<dynamic> get data => _data;
  set data(List<dynamic> val) {
    _data = val;
    notifyListeners();
  }

  dynamic _detail = {};
  dynamic get detail => _detail;
  set detail(dynamic val) {
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
