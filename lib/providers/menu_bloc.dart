import 'package:flutter/material.dart';

class MenuBloc extends ChangeNotifier {
  String _search = "";
  String get search => _search;
  set search(String val) {
    _search = val;
    notifyListeners();
  }

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

  List<dynamic> _data = [];
  List<dynamic> get data => _data;
  set data(List<dynamic> val) {
    _data = val;
    notifyListeners();
  }

  bool _loading = false;
  bool get loading => _loading;
  set loading(bool val) {
    _loading = val;
    notifyListeners();
  }

  int _activeTab = 0;
  int get activeTab => _activeTab;
  set activeTab(int val) {
    _activeTab = val;
    notifyListeners();
  }
}
