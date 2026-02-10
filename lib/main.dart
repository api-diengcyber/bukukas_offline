import 'package:keuangan/db/db.dart';
import 'package:keuangan/pages/splash/splash_page.dart';
import 'package:keuangan/providers/create_bloc.dart';
import 'package:keuangan/providers/global_bloc.dart';
import 'package:keuangan/providers/report_bloc.dart';
import 'package:keuangan/providers/report_menu_detail_bloc.dart';
import 'package:keuangan/providers/splashscreen_bloc.dart';
import 'package:keuangan/providers/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/localization/l10n.dart';
import 'package:get/get.dart';
import 'package:keuangan/services/revenue_cat_service.dart';
import 'package:provider/provider.dart';
import 'providers/menu_bloc.dart';

void main() async {
  // WAJIB ditambahkan jika ada proses async sebelum runApp
  WidgetsFlutterBinding.ensureInitialized();
  await RevenueCatService.initialize();

  // 1. Inisialisasi database (Termasuk pembuatan tabel 'bukukas' dan kolom baru)
  await DB.instance.initTables();

  // 2. Inisialisasi GlobalBloc secara manual untuk memuat data BukuKas yang tersimpan
  final globalBloc = GlobalBloc();
  await globalBloc.loadSavedBukukas(); // Memuat activeBukukasId dari SharedPreferences

  runApp(
    MultiProvider(
      providers: [
        // 3. Gunakan instance globalBloc yang sudah di-load tadi
        ChangeNotifierProvider<GlobalBloc>.value(value: globalBloc),
        ChangeNotifierProvider<CreateBloc>.value(value: CreateBloc()),
        ChangeNotifierProvider<SplashscreenBloc>.value(
            value: SplashscreenBloc()),
        ChangeNotifierProvider<MenuBloc>.value(value: MenuBloc()),
        ChangeNotifierProvider<TransactionBloc>.value(value: TransactionBloc()),
        ChangeNotifierProvider<ReportBloc>.value(value: ReportBloc()),
        ChangeNotifierProvider<ReportMenuDetailBloc>.value(
            value: ReportMenuDetailBloc()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BukuKas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
        fontFamily: 'Plus Jakarta Sans',
        useMaterial3: true,
      ),
      supportedLocales: const [
        Locale('id'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FormBuilderLocalizations.delegate,
      ],
      home: const SplashPage(),
    );
  }
}