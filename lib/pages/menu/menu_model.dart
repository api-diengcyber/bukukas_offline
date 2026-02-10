import 'dart:async';
import 'package:keuangan/db/model/tb_menu_model.dart';
import 'package:keuangan/db/tb_menu.dart';
import 'package:keuangan/providers/global_bloc.dart'; // Tambahkan import GlobalBloc
import 'package:keuangan/providers/menu_bloc.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart' as g;

class MenuModel {
  void init(BuildContext context) async {
    await getMenu(context);
  }

  Future<bool> delete(BuildContext context, int id) async {
    await TbMenu().delete(id);
    g.Get.snackbar(
      "Terhapus!",
      "Menu berhasil dihapus",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      icon: const Icon(Icons.delete, color: Colors.red),
      duration: const Duration(seconds: 1),
    );
    return true;
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
    // 1. Ambil activeBukukasId dari GlobalBloc
    final globalBloc = Provider.of<GlobalBloc>(context, listen: false); 
    
    menuBloc.loading = true;

    // 2. Kirim 2 argumen: string tipe dan ID Buku Kas aktif
    List<TbMenuModel> data = await TbMenu().getData(
      _activeTab2Str(menuBloc.activeTab), 
      globalBloc.activeBukukasId // Argumen kedua
    );

    Future.delayed(const Duration(milliseconds: 200), () async {
      menuBloc.data = data;
      menuBloc.totalPages = 1;
      menuBloc.loading = false;
    });
  }
}