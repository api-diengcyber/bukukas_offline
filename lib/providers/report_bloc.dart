import 'package:flutter/material.dart';
import 'package:keuangan/components/models/data_summary_model.dart';
import 'package:keuangan/db/model/tb_menu_model.dart'; // Import modelnya di sini
import 'package:keuangan/db/tb_menu.dart';

class ReportBloc extends ChangeNotifier {
  bool _loadingMenus = false;
  bool get loadingMenus => _loadingMenus;
  set loadingMenus(bool val) {
    _loadingMenus = val;
    notifyListeners();
  }

  dynamic _menus = {};
  dynamic get menus => _menus;
  set menus(dynamic val) {
    _menus = val;
    notifyListeners();
  }

  bool _loadingData = false;
  bool get loadingData => _loadingData;
  set loadingData(bool val) {
    _loadingData = val;
    notifyListeners();
  }

  dynamic _data = {};
  dynamic get data => _data;
  set data(dynamic val) {
    _data = val;
    notifyListeners();
  }

  // PERBAIKAN: Ganti dari List<TbMenu> menjadi List<TbMenuModel>
  List<TbMenuModel> _listAvailableMenuType = [];
  List<TbMenuModel> get listAvailableMenuType => _listAvailableMenuType;
  set listAvailableMenuType(List<TbMenuModel> val) {
    _listAvailableMenuType = val;
    notifyListeners();
  }

  int _totalReport = 0;
  int get totalReport => _totalReport;
  set totalReport(int val) {
    _totalReport = val;
    notifyListeners();
  }

  DataSummaryModel _dataSummary = DataSummaryModel();
  DataSummaryModel get dataSummary => _dataSummary;
  set dataSummary(DataSummaryModel val) {
    _dataSummary = val;
    notifyListeners();
  }

  String _startDate = "";
  String get startDate => _startDate;
  set startDate(String val) {
    _startDate = val;
    notifyListeners();
  }

  String _endDate = "";
  String get endDate => _endDate;
  set endDate(String val) {
    _endDate = val;
    notifyListeners();
  }

  bool _loadingSummary = false;
  bool get loadingSummary => _loadingSummary;
  set loadingSummary(bool val) {
    _loadingSummary = val;
    notifyListeners();
  }

  int _reportIndexActiveTab = 0;
  int get reportIndexActiveTab => _reportIndexActiveTab;
  set reportIndexActiveTab(int val) {
    _reportIndexActiveTab = val;
    notifyListeners();
  }

  String _activeChipTab = "Semua";
  String get activeChipTab => _activeChipTab;
  set activeChipTab(String val) {
    _activeChipTab = val;
    notifyListeners();
  }

  String _activeMenuTab = "Semua";
  String get activeMenuTab => _activeMenuTab;
  set activeMenuTab(String val) {
    _activeMenuTab = val;
    notifyListeners();
  }
}