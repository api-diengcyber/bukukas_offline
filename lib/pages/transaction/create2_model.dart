import 'dart:async';
import 'package:keuangan/db/tb_menu.dart';
import 'package:keuangan/providers/transaction_bloc.dart';
import 'package:keuangan/services/menu_service.dart';
import 'package:keuangan/services/transaction_service.dart';
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
    final resp = await TransactionService().save(context, globalBloc.cart);
    if (resp) {
      await Future.delayed(const Duration(milliseconds: 900), () {
        transactionBloc.loading = false;
        globalBloc.cart.clear();
      });
    } else {
      transactionBloc.loading = false;
      // globalBloc.cart.clear();
    }
  }

  Future<void> getMenu(BuildContext context) async {
    final globalBloc = Provider.of<GlobalBloc>(context, listen: false);
    final transactionBloc =
        Provider.of<TransactionBloc>(context, listen: false);
    globalBloc.loadingMenus = true;
    final resp = await MenuService().getByType4Transaction(
        context, globalBloc.tabMenuTransaction, transactionBloc.page);
    globalBloc.menus = resp['data'];
    transactionBloc.totalPages = resp['totalPage'];
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
