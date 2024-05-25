import 'package:keuangan/helpers/set_menus.dart';
import 'package:keuangan/providers/report_bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../pages/report/detail/report_menu_detail_page.dart';

class TabReportMenu extends StatefulWidget {
  const TabReportMenu({Key? key}) : super(key: key);

  @override
  State<TabReportMenu> createState() => _TabReportMenuState();
}

class _TabReportMenuState extends State<TabReportMenu> {
  final formatCurrency = NumberFormat.simpleCurrency(
    locale: 'id_ID',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final _reportBloc = context.watch<ReportBloc>();

    Color colorT = _reportBloc.activeMenuTab == "Semua"
        ? Colors.grey
        : _reportBloc.activeMenuTab == "Pemasukan"
            ? Colors.green.shade300
            : _reportBloc.activeMenuTab == "Pengeluaran"
                ? Colors.pink.shade300
                : _reportBloc.activeMenuTab == "Hutang"
                    ? Colors.amber.shade300
                    : _reportBloc.activeMenuTab == "Piutang"
                        ? Colors.blue.shade300
                        : Colors.grey;

    return (!_reportBloc.loadingSummary && !_reportBloc.loadingMenus)
        ? (_reportBloc.menus != null && _reportBloc.menus.length > 0)
            ? Container(
                height: double.infinity,
                child: Column(
                  children: <Widget>[
                    Container(),
                    const SizedBox(
                      height: 8,
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(0),
                        itemCount: _reportBloc.menus.length,
                        itemBuilder: (context, index) {
                          var data = _reportBloc.menus[index];
                          DateTime? tempDate;
                          if (data["keu_menu_deadline"] != null &&
                              data["keu_menu_deadline"] != "") {
                            tempDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS")
                                .parse(data["keu_menu_deadline"]);
                          }

                          return Container(
                            padding: const EdgeInsets.only(
                              top: 12,
                              bottom: 12,
                              left: 18,
                              right: 8,
                            ),
                            margin: const EdgeInsets.only(
                                bottom: 8, left: 12, right: 12),
                            decoration: BoxDecoration(
                              color: activeTabColor(
                                  data["keu_menu_type"], labelsColor),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: activeTabColor(
                                      data["keu_menu_type"], chipsColor),
                                  spreadRadius: 0,
                                  blurRadius: 0.2,
                                  offset: const Offset(
                                      0, 0.1), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        data["keu_menu_name"],
                                        style: TextStyle(
                                          color: activeTabColor(
                                              data["keu_menu_type"],
                                              reportActiveTabColor),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      data["keu_menu_notes"] != null &&
                                              data["keu_menu_notes"] != ""
                                          ? Text(
                                              data["keu_menu_notes"],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            )
                                          : const SizedBox(),
                                      Row(
                                        children: <Widget>[
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  spreadRadius: 0,
                                                  blurRadius: 0.2,
                                                  offset: const Offset(0,
                                                      0.2), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 4,
                                            ),
                                            child: data["total"] != 0
                                                ? Text(
                                                    formatCurrency
                                                        .format(data["total"]),
                                                    style: const TextStyle(
                                                      color: Colors.black87,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  )
                                                : (data["keu_menu_type"] ==
                                                                "Hutang" ||
                                                            data["keu_menu_type"] ==
                                                                "Piutang") &&
                                                        data["keu_menu_status_paid_off"] ==
                                                            1
                                                    ? Row(
                                                        children: <Widget>[
                                                          const Text(
                                                            "Lunas",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.green,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          Text(
                                                            "(" +
                                                                (data["keu_menu_type"] ==
                                                                        "Hutang"
                                                                    ? formatCurrency
                                                                        .format(data[
                                                                            "totalIn"])
                                                                    : data["keu_menu_type"] ==
                                                                            "Piutang"
                                                                        ? formatCurrency
                                                                            .format(data["totalOut"])
                                                                        : "") +
                                                                ")",
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : const SizedBox(),
                                          ),
                                          const Expanded(
                                            child: SizedBox(),
                                          ),
                                          (data["keu_menu_deadline"] != null &&
                                                  data["keu_menu_deadline"] !=
                                                      "" &&
                                                  (data["keu_menu_type"] ==
                                                          "Hutang" ||
                                                      data["keu_menu_type"] ==
                                                          "Piutang"))
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.5),
                                                        spreadRadius: 0,
                                                        blurRadius: 0.2,
                                                        offset: const Offset(0,
                                                            0.2), // changes position of shadow
                                                      ),
                                                    ],
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                                  child: Text(
                                                    DateFormat("yyyy-MM-dd")
                                                        .format(tempDate!),
                                                    style: TextStyle(
                                                      color:
                                                          data["keu_menu_status_paid_off"] ==
                                                                  1
                                                              ? Colors.grey
                                                              : Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType.bottomToTop,
                                        child: ReportMenuDetailPage(
                                          menuId: data["keu_menu_id"],
                                          type: data["keu_menu_type"],
                                        ),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.content_paste_search,
                                    color: activeTabColor(data["keu_menu_type"],
                                        reportActiveTabColor),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Icon(
                      Icons.emoji_symbols,
                      color: Colors.grey,
                      size: 50,
                    ),
                    Text(
                      "Data kosong",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.apps,
                  color: colorT,
                  size: 50,
                ),
                Text(
                  "Memuat menu...",
                  style: TextStyle(
                    color: colorT,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
  }
}
