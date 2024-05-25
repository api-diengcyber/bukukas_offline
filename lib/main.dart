import 'package:keuangan/db/db.dart';
import 'package:keuangan/pages/dashboard/dashboard_page.dart';
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
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/menu_bloc.dart';

void main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<GlobalBloc>.value(value: GlobalBloc()),
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    DB().init(context);
    return GetMaterialApp(
      title: 'BukuKas',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        fontFamily: GoogleFonts.rubik().fontFamily,
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
      home: const DashboardPage(),
    );
  }
}
