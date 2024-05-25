import 'package:keuangan/providers/report_bloc.dart';
import 'package:keuangan/services/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/report_service.dart';

class ReportModel {
  void init(BuildContext context) async {
    await getSummaryReport(context);
    await getTabsData(context);
  }

  Future<bool> deleteTransaction(BuildContext context, int id) async {
    final _resp = await TransactionService().delete(context, id);
    return _resp;
  }

  Future<void> _getMenu(BuildContext context) async {
    final _reportBloc = Provider.of<ReportBloc>(context, listen: false);
    var data = {
      'type': _reportBloc.activeMenuTab,
      'reportType': _reportBloc.activeChipTab,
      'startDate':
          _reportBloc.activeChipTab == "Semua" ? "" : _reportBloc.startDate,
      'endDate':
          _reportBloc.activeChipTab == "Semua" ? "" : _reportBloc.endDate,
    };
    if (_reportBloc.activeChipTab == "Periode" &&
        (_reportBloc.startDate == "" || _reportBloc.endDate == "")) {
    } else {
      _reportBloc.menus = {};
      _reportBloc.loadingMenus = true;
      final _resp = await ReportService().getMenu(context, data);
      _reportBloc.menus = _resp;
      await Future.delayed(const Duration(milliseconds: 500), () {
        _reportBloc.loadingMenus = false;
      });
    }
  }

  Future<void> _getData(BuildContext context) async {
    final _reportBloc = Provider.of<ReportBloc>(context, listen: false);
    var data = {
      'type': _reportBloc.activeMenuTab,
      'reportType': _reportBloc.activeChipTab,
      'startDate':
          _reportBloc.activeChipTab == "Semua" ? "" : _reportBloc.startDate,
      'endDate':
          _reportBloc.activeChipTab == "Semua" ? "" : _reportBloc.endDate,
      'limit': 50,
      'page': 1,
    };
    if (_reportBloc.activeChipTab == "Periode" &&
        (_reportBloc.startDate == "" || _reportBloc.endDate == "")) {
    } else {
      _reportBloc.data = {};
      _reportBloc.loadingData = true;
      final _resp = await ReportService().getData(context, data);
      _reportBloc.data = _resp['data'] ?? {};
      await Future.delayed(const Duration(milliseconds: 500), () {
        _reportBloc.loadingData = false;
      });
    }
  }

  Future<void> getTabsData(BuildContext context) async {
    final _reportBloc = Provider.of<ReportBloc>(context, listen: false);
    if (_reportBloc.reportIndexActiveTab == 0) {
      // Data
      await _getData(context);
    } else if (_reportBloc.reportIndexActiveTab == 1) {
      if (_reportBloc.activeMenuTab == "Semua") {
        // Graph
      } else {
        // Menu
        await _getMenu(context);
      }
    } else if (_reportBloc.reportIndexActiveTab == 2) {
      // Graph
    }
  }

  Future<void> getSummaryReport(BuildContext context) async {
    final _reportBloc = Provider.of<ReportBloc>(context, listen: false);
    var data = {
      'type': _reportBloc.activeMenuTab,
      'reportType': _reportBloc.activeChipTab,
      'startDate':
          _reportBloc.activeChipTab == "Semua" ? "" : _reportBloc.startDate,
      'endDate':
          _reportBloc.activeChipTab == "Semua" ? "" : _reportBloc.endDate,
    };
    if (_reportBloc.activeChipTab == "Periode" &&
        (_reportBloc.startDate == "" || _reportBloc.endDate == "")) {
    } else {
      _reportBloc.dataSummary = {};
      _reportBloc.loadingSummary = true;
      final _resp = await ReportService().getSummary(context, data);
      _reportBloc.dataSummary = _resp;
      _reportBloc.totalReport = _resp["total"];
      _reportBloc.listAvailableMenuType = _resp['listAvailableMenuType'];

      if (_reportBloc.activeMenuTab != "Semua") {
        int _indexExists = _resp['listAvailableMenuType'].indexWhere(
            (element) => element['name'] == _reportBloc.activeMenuTab);
        if (_resp['listAvailableMenuType'].isEmpty || _indexExists == -1) {
          _reportBloc.activeMenuTab = "Semua";
        }
      }

      await Future.delayed(const Duration(milliseconds: 500), () {
        _reportBloc.loadingSummary = false;
      });
    }
  }
}
