import 'package:keuangan/db/tb_menu.dart';
import 'package:keuangan/db/tb_transaksi.dart';
import 'package:keuangan/providers/report_menu_detail_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportMenuDetailModel {
  void init(BuildContext context, int id) async {
    await getMenuDetail(context, id);
  }

  Future<void> getMenuDetail(BuildContext context, int id) async {
    final reportMenuDetailBloc =
        Provider.of<ReportMenuDetailBloc>(context, listen: false);
    reportMenuDetailBloc.loading = true;
    reportMenuDetailBloc.detail = await TbMenu().getDataById(id);
    reportMenuDetailBloc.data = await TbTransaksi().getDataByMenuId(id);
    await Future.delayed(const Duration(milliseconds: 500), () {
      reportMenuDetailBloc.loading = false;
    });
  }
}
