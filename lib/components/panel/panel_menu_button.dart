import 'package:get/get.dart';
import 'package:keuangan/helpers/set_menus.dart';
import 'package:keuangan/pages/dashboard/dashboard_controller.dart';
import 'package:keuangan/pages/menu/menu_page.dart';
import 'package:keuangan/pages/report/report_page.dart';
import 'package:keuangan/pages/transaction/create_page.dart';
import 'package:keuangan/providers/global_bloc.dart';
import 'package:keuangan/providers/menu_bloc.dart';
import 'package:keuangan/providers/report_bloc.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class PanelMenuButton extends StatefulWidget {
  PanelMenuButton({
    Key? key,
    this.buttonAddKey,
  }) : super(key: key);

  Key? buttonAddKey;

  @override
  State<PanelMenuButton> createState() => _PanelMenuButtonState();
}

class _PanelMenuButtonState extends State<PanelMenuButton> {
  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => DashboardController());
    final dashboardController = Get.find<DashboardController>();

    final _globalBloc = context.watch<GlobalBloc>();
    final _reportBloc = context.watch<ReportBloc>();
    final _menuBloc = context.watch<MenuBloc>();

    return SizedBox(
      height: 70,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 0,
                    blurRadius: 0.2,
                    offset: const Offset(0, 0.1), // changes position of shadow
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
                child: InkWell(
                  splashColor: Colors.amber,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                  onTap: () {
                    _menuBloc.page = 1;
                    _menuBloc.search = '';
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.fade,
                        child: const MenuPage(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const <Widget>[
                        Icon(
                          Icons.app_registration,
                          color: Colors.black87,
                          size: 30,
                        ),
                        Text(
                          "Kelola menu",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              key: widget.buttonAddKey,
              child: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: _globalBloc.tabMenuTransaction == "Pemasukan"
                      ? gradientActiveDMenu[0]
                      : (_globalBloc.tabMenuTransaction == "Pengeluaran"
                          ? gradientActiveDMenu[1]
                          : (_globalBloc.tabMenuTransaction == "Hutang")
                              ? gradientActiveDMenu[2]
                              : gradientActiveDMenu[3]),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const <Widget>[
                    Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                      size: 30,
                    ),
                    Text(
                      "Tambah Baru",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: const CreateTransactionPage(),
                  ),
                ).then((value) async {
                  if (value != null) {
                    if (value == 'load') {
                      dashboardController.getDashboard();
                    }
                  }
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 0,
                    blurRadius: 0.2,
                    offset: const Offset(0, 0.1), // changes position of shadow
                  ),
                ],
              ),
              child: Material(
                color: Colors.white,
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
                child: InkWell(
                  splashColor: Colors.amber,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.fade,
                        child: const ReportPage(),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                      image: DecorationImage(
                        image: AssetImage(_reportBloc.activeMenuTab == "Semua"
                            ? miniGradImages[0]
                            : _reportBloc.activeMenuTab == "Pemasukan"
                                ? miniGradImages[1]
                                : _reportBloc.activeMenuTab == "Pengeluaran"
                                    ? miniGradImages[2]
                                    : _reportBloc.activeMenuTab == "Hutang"
                                        ? miniGradImages[3]
                                        : _reportBloc.activeMenuTab == "Piutang"
                                            ? miniGradImages[4]
                                            : miniGradImages[0]),
                        fit: BoxFit.cover,
                      ),
                    ),
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Icon(
                          Icons.graphic_eq_outlined,
                          color: _reportBloc.activeMenuTab == "Semua"
                              ? Colors.black87
                              : Colors.white,
                          size: 30,
                        ),
                        Text(
                          "Laporan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _reportBloc.activeMenuTab == "Semua"
                                ? Colors.black87
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
