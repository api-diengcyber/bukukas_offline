import 'dart:async';
import 'package:keuangan/providers/menu_bloc.dart';
import 'package:keuangan/services/menu_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart' as g;

class MenuModel {
  void init(BuildContext context) async {
    await getMenu(context);
  }

  Future<bool> delete(BuildContext context, int id) async {
    final resp = await MenuService().delete(context, id);
    if (resp) {
      g.Get.snackbar(
        "Terhapus!",
        "Menu berhasil dihapus",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        icon: const Icon(Icons.delete, color: Colors.red),
        duration: const Duration(seconds: 1),
      );
    }
    return resp;
  }

  String _activeTab2Str(activeTab) {
    switch (activeTab) {
      case 0:
        return 'Semua';
      case 1:
        return 'Pemasukan';
      case 2:
        return 'Pengeluaran';
      case 3:
        return 'Hutang';
      case 4:
        return 'Piutang';
      default:
        return '';
    }
  }

  Future<void> getMenu(BuildContext context) async {
    final menuBloc = Provider.of<MenuBloc>(context, listen: false);
    menuBloc.loading = true;
    final resp = await MenuService()
        .getByType(context, _activeTab2Str(menuBloc.activeTab), menuBloc.page);
    if (menuBloc.page > resp['totalPage']) {
      menuBloc.page = resp['totalPage'];
      await getMenu(context);
    } else {
      Future.delayed(const Duration(milliseconds: 800), () async {
        menuBloc.data = resp['data'];
        menuBloc.totalPages = resp['totalPage'];
        menuBloc.loading = false;
      });
    }
  }
}
