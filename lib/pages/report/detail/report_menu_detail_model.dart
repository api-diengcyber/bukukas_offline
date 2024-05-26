import 'package:keuangan/providers/report_menu_detail_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/report_service.dart';

class ReportMenuDetailModel {
  void init(BuildContext context, int id) async {
    await getMenuDetail(context, id);
  }

  Future<void> getMenuDetail(BuildContext context, int id) async {
    final reportMenuDetailBloc =
        Provider.of<ReportMenuDetailBloc>(context, listen: false);
    reportMenuDetailBloc.loading = true;
    final resp = await ReportService().getMenuDetail(context, id);
    reportMenuDetailBloc.detail = resp['detail'];
    reportMenuDetailBloc.data = resp['data'];
    await Future.delayed(const Duration(milliseconds: 500), () {
      reportMenuDetailBloc.loading = false;
    });
  }
}
