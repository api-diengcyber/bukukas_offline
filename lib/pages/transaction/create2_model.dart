import 'dart:async';
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
    final _globalBloc = Provider.of<GlobalBloc>(context, listen: false);
    final _transactionBloc =
        Provider.of<TransactionBloc>(context, listen: false);
    _transactionBloc.loading = true;
    final _resp = await TransactionService().save(context, _globalBloc.cart);
    if (_resp) {
      await Future.delayed(const Duration(milliseconds: 900), () {
        _transactionBloc.loading = false;
        _globalBloc.cart.clear();
      });
    } else {
      _transactionBloc.loading = false;
      // _globalBloc.cart.clear();
    }
  }

  Future<void> getMenu(BuildContext context) async {
    final _globalBloc = Provider.of<GlobalBloc>(context, listen: false);
    final _transactionBloc =
        Provider.of<TransactionBloc>(context, listen: false);
    _globalBloc.loadingMenus = true;
    final _resp = await MenuService().getByType4Transaction(
        context, _globalBloc.tabMenuTransaction, _transactionBloc.page);
    _globalBloc.menus = _resp['data'];
    _transactionBloc.totalPages = _resp['totalPage'];
    _globalBloc.loadingMenus = false;
  }

  Stream<List<dynamic>> getMenuStream(BuildContext context) async* {
    final _globalBloc = Provider.of<GlobalBloc>(context, listen: false);
    yield _globalBloc.menus;
  }

  Stream<List<dynamic>> getCartStream(BuildContext context) async* {
    final _globalBloc = Provider.of<GlobalBloc>(context, listen: false);
    yield _globalBloc.cart;
  }
}
