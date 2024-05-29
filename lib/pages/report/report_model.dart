import 'package:keuangan/providers/report_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportModel {
  void init(BuildContext context) async {
    await getSummaryReport(context);
    await getTabsData(context);
  }

  Future<bool> deleteTransaction(BuildContext context, int id) async {
    // final resp = await TransactionService().delete(context, id);
    // return resp;
    return true;
  }

  Future<void> _getMenu(BuildContext context) async {
    final reportBloc = Provider.of<ReportBloc>(context, listen: false);
    var data = {
      'type': reportBloc.activeMenuTab,
      'reportType': reportBloc.activeChipTab,
      'startDate':
          reportBloc.activeChipTab == "Semua" ? "" : reportBloc.startDate,
      'endDate': reportBloc.activeChipTab == "Semua" ? "" : reportBloc.endDate,
    };
    if (reportBloc.activeChipTab == "Periode" &&
        (reportBloc.startDate == "" || reportBloc.endDate == "")) {
    } else {
      reportBloc.menus = {};
      reportBloc.loadingMenus = true;
      // final resp = await ReportService().getMenu(context, data);
      // reportBloc.menus = resp;
      await Future.delayed(const Duration(milliseconds: 500), () {
        reportBloc.loadingMenus = false;
      });
    }
  }

  Future<void> _getData(BuildContext context) async {
    final reportBloc = Provider.of<ReportBloc>(context, listen: false);
    var data = {
      'type': reportBloc.activeMenuTab,
      'reportType': reportBloc.activeChipTab,
      'startDate':
          reportBloc.activeChipTab == "Semua" ? "" : reportBloc.startDate,
      'endDate': reportBloc.activeChipTab == "Semua" ? "" : reportBloc.endDate,
      'limit': 50,
      'page': 1,
    };
    if (reportBloc.activeChipTab == "Periode" &&
        (reportBloc.startDate == "" || reportBloc.endDate == "")) {
    } else {
      reportBloc.data = {};
      reportBloc.loadingData = true;
      // final resp = await ReportService().getData(context, data);
      // reportBloc.data = resp['data'] ?? {};
      await Future.delayed(const Duration(milliseconds: 500), () {
        reportBloc.loadingData = false;
      });
    }
  }

  Future<void> getTabsData(BuildContext context) async {
    final reportBloc = Provider.of<ReportBloc>(context, listen: false);
    if (reportBloc.reportIndexActiveTab == 0) {
      // Data
      await _getData(context);
    } else if (reportBloc.reportIndexActiveTab == 1) {
      if (reportBloc.activeMenuTab == "Semua") {
        // Graph
      } else {
        // Menu
        await _getMenu(context);
      }
    } else if (reportBloc.reportIndexActiveTab == 2) {
      // Graph
    }
  }

  Future<void> getSummaryReport(BuildContext context) async {
    final reportBloc = Provider.of<ReportBloc>(context, listen: false);
    var data = {
      'type': reportBloc.activeMenuTab,
      'reportType': reportBloc.activeChipTab,
      'startDate':
          reportBloc.activeChipTab == "Semua" ? "" : reportBloc.startDate,
      'endDate': reportBloc.activeChipTab == "Semua" ? "" : reportBloc.endDate,
    };
    if (reportBloc.activeChipTab == "Periode" &&
        (reportBloc.startDate == "" || reportBloc.endDate == "")) {
    } else {
      reportBloc.dataSummary = {};
      reportBloc.loadingSummary = true;
      // final resp = await ReportService().getSummary(context, data);
      // reportBloc.dataSummary = resp;
      // reportBloc.totalReport = resp["total"];
      // reportBloc.listAvailableMenuType = resp['listAvailableMenuType'];

      // if (reportBloc.activeMenuTab != "Semua") {
      //   int indexExists = resp['listAvailableMenuType'].indexWhere(
      //       (element) => element['name'] == reportBloc.activeMenuTab);
      //   if (resp['listAvailableMenuType'].isEmpty || indexExists == -1) {
      //     reportBloc.activeMenuTab = "Semua";
      //   }
      // }

      await Future.delayed(const Duration(milliseconds: 500), () {
        reportBloc.loadingSummary = false;
      });
    }
  }
}
