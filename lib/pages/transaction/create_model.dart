import 'package:flutter/material.dart';
import 'package:keuangan/providers/create_bloc.dart';
import 'package:keuangan/providers/global_bloc.dart';
import 'package:keuangan/services/report_service.dart';
import 'package:provider/provider.dart';

class CreateModel {
  void init(BuildContext context) async {
    await getData(context);
  }

  Future<void> getData(BuildContext context) async {
    final _globalBloc = Provider.of<GlobalBloc>(context, listen: false);
    final _createBloc = Provider.of<CreateBloc>(context, listen: false);
    var data = {
      'type': _globalBloc.tabMenuTransaction,
      'reportType': "Semua",
      'startDate': "",
      'endDate': "",
      'limit': 10,
      'page': _createBloc.page,
    };
    _createBloc.loading = true;
    final _resp = await ReportService().getData(context, data);
    _createBloc.data = _resp['data'] ?? {};
    _createBloc.loading = false;
    _createBloc.totalPage = _resp['totalPage'] ?? 1;
  }
}
