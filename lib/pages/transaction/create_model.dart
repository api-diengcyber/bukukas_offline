import 'package:flutter/material.dart';
import 'package:keuangan/db/model/tb_transaksi_model.dart';
import 'package:keuangan/db/tb_transaksi.dart';
import 'package:keuangan/providers/create_bloc.dart';
import 'package:keuangan/providers/global_bloc.dart';
import 'package:provider/provider.dart';

class CreateModel {
  void init(BuildContext context) async {
    await getData(context);
  }

  Future<void> getData(BuildContext context) async {
    final globalBloc = Provider.of<GlobalBloc>(context, listen: false);
    final createBloc = Provider.of<CreateBloc>(context, listen: false);
    List<TbTransaksiModel> listData =
        await TbTransaksi().getData(globalBloc.tabMenuTransaction);
    createBloc.data = listData;
    createBloc.loading = false;
    createBloc.totalPage = 1;
  }
}
