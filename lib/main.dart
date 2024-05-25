import 'package:keuangan/pages/dashboard/dashboard_page.dart';
import 'package:keuangan/providers/create_bloc.dart';
import 'package:keuangan/providers/global_bloc.dart';
import 'package:keuangan/providers/report_bloc.dart';
import 'package:keuangan/providers/report_menu_detail_bloc.dart';
import 'package:keuangan/providers/splashscreen_bloc.dart';
import 'package:keuangan/providers/transaction_bloc.dart';
import 'package:keuangan/utils/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/localization/l10n.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/menu_bloc.dart';

void main() {
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
  DependencyInjection.init();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Keuangan',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        fontFamily: GoogleFonts.rubik().fontFamily,
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
