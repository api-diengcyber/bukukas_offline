import 'package:flutter/material.dart';
import 'package:keuangan/components/models/cart_model.dart';
import 'package:keuangan/db/model/tb_menu_model.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Tambahkan ini untuk simpan pilihan user

class GlobalBloc extends ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;
  set loading(bool val) {
    _loading = val;
    notifyListeners();
  }

  // --- LOGIKA MULTI BUKUKAS ---
  int _activeBukukasId = 1;
  String _activeBukukasName = "Bukukas 1";
  List<dynamic> _listBukukas = [];

  int get activeBukukasId => _activeBukukasId;
  String get activeBukukasName => _activeBukukasName;
  List<dynamic> get listBukukas => _listBukukas;

  // Fungsi untuk set Buku Kas yang aktif
  void setActiveBukukas(int id, String name) async {
    _activeBukukasId = id;
    _activeBukukasName = name;
    
    // Simpan ke SharedPreferences agar saat buka aplikasi lagi tetap di buku ini
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('active_bukukas_id', id);
    await prefs.setString('active_bukukas_name', name);
    
    notifyListeners();
  }

  // Fungsi untuk update list buku dari DB ke Bloc
  set listBukukas(List<dynamic> val) {
    _listBukukas = val;
    notifyListeners();
  }

  // Fungsi dipanggil saat pertama kali aplikasi buka
  Future<void> loadSavedBukukas() async {
    final prefs = await SharedPreferences.getInstance();
    _activeBukukasId = prefs.getInt('active_bukukas_id') ?? 1;
    _activeBukukasName = prefs.getString('active_bukukas_name') ?? "Bukukas 1";
    notifyListeners();
  }
  // -----------------------------

  String _tabMenuTransaction = "Pemasukan";
  String get tabMenuTransaction => _tabMenuTransaction;
  set tabMenuTransaction(String val) {
    _tabMenuTransaction = val;
    notifyListeners();
  }

  String _debtType = "Bayar";
  String get debtType => _debtType;
  set debtType(String val) {
    _debtType = val;
    notifyListeners();
  }

  bool _loadingMenus = false;
  bool get loadingMenus => _loadingMenus;
  set loadingMenus(bool val) {
    _loadingMenus = val;
    notifyListeners();
  }

  List<TbMenuModel> _menus = [];
  List<TbMenuModel> get menus => _menus;
  set menus(List<TbMenuModel> val) {
    _menus = val;
    notifyListeners();
  }

  double _totalCartNominal = 0;
  double get totalCartNominal => _totalCartNominal;
  set totalCartNominal(double val) {
    _totalCartNominal = val;
    notifyListeners();
  }

  List<CartModel> _cart = [];
  List<CartModel> get cart => _cart;
  set cart(List<CartModel> val) {
    _cart = val;
    notifyListeners();
  }
}