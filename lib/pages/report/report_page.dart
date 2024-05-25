import 'package:flutter/services.dart';
import 'package:keuangan/components/circle_custom.dart';
import 'package:keuangan/components/panel/panel_report_swiper.dart';
import 'package:keuangan/helpers/set_menus.dart';
import 'package:keuangan/pages/report/report_model.dart';
import 'package:keuangan/providers/report_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../components/panel/panel_report_tabs.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final formatCurrency = NumberFormat.simpleCurrency(
    locale: 'id_ID',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ReportModel().init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final _reportBloc = context.watch<ReportBloc>();

    AppBar appBar = AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: const Color(0x00000000),
      elevation: 0,
      centerTitle: true,
      leading: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back, color: Colors.black),
      ),
      title: const Text(
        'Laporan',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    double marginTopScreen =
        appBar.preferredSize.height + MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: Container(
        color: _reportBloc.activeMenuTab == "Semua"
            ? Colors.grey.shade100
            : _reportBloc.activeMenuTab == "Pemasukan"
                ? Colors.green.shade100
                : _reportBloc.activeMenuTab == "Pengeluaran"
                    ? Colors.pink.shade100
                    : _reportBloc.activeMenuTab == "Hutang"
                        ? Colors.amber.shade100
                        : _reportBloc.activeMenuTab == "Piutang"
                            ? Colors.blue.shade100
                            : Colors.grey.shade100,
        constraints: const BoxConstraints.expand(),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                height: marginTopScreen,
              ),
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    children: <Widget>[
                      _reportBloc.activeMenuTab != "Semua"
                          ? Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(
                                bottom: 8,
                                left: 16,
                                right: 16,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        const Text(
                                          "Total",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        Text(
                                          formatCurrency
                                              .format(_reportBloc.totalReport),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    color: Colors.white,
                                    padding: const EdgeInsets.only(
                                      left: 8,
                                      right: 4,
                                      top: 5,
                                      bottom: 5,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        for (var item in _reportBloc
                                            .listAvailableMenuType)
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 4),
                                            child: CircleCustom(
                                              height: 8,
                                              gradient: item["name"] ==
                                                      "Pemasukan"
                                                  ? gradientActiveDMenu[0]
                                                  : (item["name"] ==
                                                          "Pengeluaran"
                                                      ? gradientActiveDMenu[1]
                                                      : (item["name"] ==
                                                              "Hutang")
                                                          ? gradientActiveDMenu[
                                                              2]
                                                          : gradientActiveDMenu[
                                                              3]),
                                              active: true,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              !_reportBloc.loadingSummary &&
                                      (_reportBloc.activeMenuTab == "Hutang" ||
                                          _reportBloc.activeMenuTab ==
                                              "Piutang")
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                        horizontal: 12,
                                      ),
                                      margin: const EdgeInsets.only(
                                        bottom: 8,
                                        left: 16,
                                        right: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.white54,
                                      ),
                                      child: IntrinsicHeight(
                                        child: Row(
                                          children: <Widget>[
                                            const Expanded(
                                              child: SizedBox(),
                                            ),
                                            int.parse(_reportBloc.dataSummary[
                                                            "debtMenuStatus"]
                                                        ["Belum"]) !=
                                                    0
                                                ? Text(
                                                    "Belum lunas: " +
                                                        _reportBloc.dataSummary[
                                                                "debtMenuStatus"]
                                                            ["Belum"],
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                : const SizedBox(),
                                            (int.parse(_reportBloc.dataSummary[
                                                                "debtMenuStatus"]
                                                            ["Belum"]) !=
                                                        0 &&
                                                    int.parse(_reportBloc
                                                                    .dataSummary[
                                                                "debtMenuStatus"]
                                                            ["Lunas"]) !=
                                                        0)
                                                ? const VerticalDivider(
                                                    color: Colors.black,
                                                    thickness: 1,
                                                  )
                                                : const SizedBox(),
                                            int.parse(_reportBloc.dataSummary[
                                                            "debtMenuStatus"]
                                                        ["Lunas"]) !=
                                                    0
                                                ? Text(
                                                    "Lunas: " +
                                                        _reportBloc.dataSummary[
                                                                "debtMenuStatus"]
                                                            ["Lunas"],
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                : const SizedBox(),
                                            const Expanded(
                                              child: SizedBox(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                              const PanelReportSwiper(),
                              const SizedBox(
                                height: 8,
                              ),
                              const PanelReportTabs(),
                              const SizedBox(
                                height: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
