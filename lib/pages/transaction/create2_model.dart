import 'dart:async';
import 'package:keuangan/components/models/cart_model.dart';
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
    final transactionBloc = Provider.of<TransactionBloc>(context, listen: false);
    
    transactionBloc.loading = true;

    // PERBAIKAN: Kirim ID Buku Kas aktif saat menyimpan transaksi dari keranjang
    // Pastikan di tb_transaksi.dart, fungsi createByCart sudah menerima parameter bukukasId
    await TbTransaksi().createByCart(globalBloc.cart, globalBloc.activeBukukasId);

    await Future.delayed(const Duration(milliseconds: 900), () {
      transactionBloc.loading = false;
      globalBloc.cart.clear();
    });
  }

  Future<void> getMenu(BuildContext context) async {
    final globalBloc = Provider.of<GlobalBloc>(context, listen: false);
    final transactionBloc = Provider.of<TransactionBloc>(context, listen: false);
    
    globalBloc.loadingMenus = true;

    // PERBAIKAN: Kirim 2 argumen: Tipe menu dan ID Buku Kas aktif
    List<TbMenuModel> listData = await TbMenu().getData(
      globalBloc.tabMenuTransaction, 
      globalBloc.activeBukukasId
    );

    globalBloc.menus = listData;
    transactionBloc.totalPages = 1;
    globalBloc.loadingMenus = false;
  }

  Stream<List<TbMenuModel>> getMenuStream(BuildContext context) async* {
    final globalBloc = Provider.of<GlobalBloc>(context, listen: false);
    yield globalBloc.menus;
  }

  Stream<List<CartModel>> getCartStream(BuildContext context) async* {
    final globalBloc = Provider.of<GlobalBloc>(context, listen: false);
    yield globalBloc.cart;
  }
}