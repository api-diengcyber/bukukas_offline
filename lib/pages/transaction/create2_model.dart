import 'dart:async';
import 'package:keuangan/db/model/tb_menu_model.dart';
import 'package:keuangan/db/tb_menu.dart';
import 'package:keuangan/db/tb_transaksi.dart';
import 'package:keuangan/providers/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/global_bloc.dart';

class CreateModel2 {
  void init(BuildContext context) async {
    await getMenu(context);
  }

  Future<void> saveTransaction(BuildContext context) async {
    final globalBloc = Provider.of<GlobalBloc>(context, listen: false);
    final transactionBloc =
        Provider.of<TransactionBloc>(context, listen: false);
    transactionBloc.loading = true;
    await TbTransaksi().createByCart(globalBloc.cart);
    await Future.delayed(const Duration(milliseconds: 900), () {
      transactionBloc.loading = false;
      globalBloc.cart.clear();
    });
  }

  Future<void> getMenu(BuildContext context) async {
    final globalBloc = Provider.of<GlobalBloc>(context, listen: false);
    final transactionBloc =
        Provider.of<TransactionBloc>(context, listen: false);
    globalBloc.loadingMenus = true;
    List<TbMenuModel> listData =
        await TbMenu().getData(globalBloc.tabMenuTransaction);
    globalBloc.menus = listData;
    transactionBloc.totalPages = 1;
    globalBloc.loadingMenus = false;
  }

  Stream<List<dynamic>> getMenuStream(BuildContext context) async* {
    final globalBloc = Provider.of<GlobalBloc>(context, listen: false);
    yield globalBloc.menus;
  }

  Stream<List<dynamic>> getCartStream(BuildContext context) async* {
    final globalBloc = Provider.of<GlobalBloc>(context, listen: false);
    yield globalBloc.cart;
  }
}
