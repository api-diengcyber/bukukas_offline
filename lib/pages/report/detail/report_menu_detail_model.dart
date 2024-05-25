import 'package:keuangan/providers/report_menu_detail_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/report_service.dart';

class ReportMenuDetailModel {
  void init(BuildContext context, int id) async {
    await getMenuDetail(context, id);
  }

  Future<void> getMenuDetail(BuildContext context, int id) async {
    final _reportMenuDetailBloc =
        Provider.of<ReportMenuDetailBloc>(context, listen: false);
    _reportMenuDetailBloc.loading = true;
    final _resp = await ReportService().getMenuDetail(context, id);
    _reportMenuDetailBloc.detail = _resp['detail'];
    _reportMenuDetailBloc.data = _resp['data'];
    await Future.delayed(const Duration(milliseconds: 500), () {
      _reportMenuDetailBloc.loading = false;
    });
  }
}
