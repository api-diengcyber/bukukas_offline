import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:keuangan/helpers/set_menus.dart';
import 'package:keuangan/pages/report/report_model.dart';
import 'package:keuangan/providers/report_bloc.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../pages/report/detail/report_menu_detail_page.dart';

class TabReportData extends StatefulWidget {
  const TabReportData({Key? key}) : super(key: key);

  @override
  State<TabReportData> createState() => _TabReportDataState();
}

class _TabReportDataState extends State<TabReportData> {
  final formatCurrency = NumberFormat.simpleCurrency(
    locale: 'id_ID',
    decimalDigits: 0,
  );
  final CurrencyTextInputFormatter _formatter = CurrencyTextInputFormatter(
    NumberFormat.currency(
      decimalDigits: 0,
      locale: 'id',
      symbol: 'Rp',
    ),
  );

  @override
  Widget build(BuildContext context) {
    final _reportBloc = context.watch<ReportBloc>();

    onDeleteMenu(data) async {
      DateTime tempDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS")
          .parse(data["keu_transaction_transaction_date"]);
      int jml = (data['keu_transaction_value_in']) -
          (data['keu_transaction_value_out']);

      String desc = "${data['menus_name']} (${data['menus_type']})";
      desc += "\n ${DateFormat("yyyy-MM-dd HH:mm:ss").format(tempDate)}";
      if (data['keu_transaction_notes'] != null &&
          data['keu_transaction_notes'] != "") {
        desc += "\n ${data['keu_transaction_notes']}";
      }
      desc += "\n ${_formatter.formatString(jml.toString())}";

      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        headerAnimationLoop: false,
        animType: AnimType.bottomSlide,
        title: 'Hapus transaksi ini',
        desc: desc,
        buttonsTextStyle: const TextStyle(color: Colors.white),
        showCloseIcon: true,
        btnCancelColor: Colors.grey,
        btnOkColor: Colors.red,
        btnOkText: "Hapus transaksi",
        btnCancelOnPress: () {},
        btnOkOnPress: () async {
          var _resp = await ReportModel()
              .deleteTransaction(context, data["keu_transaction_id"]);
          if (_resp) {
            await ReportModel().getTabsData(context);
            await ReportModel().getSummaryReport(context);
          }
        },
      ).show();
    }

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

    return (!_reportBloc.loadingSummary && !_reportBloc.loadingData)
        ? _reportBloc.data.length > 0
            ? SizedBox(
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
                        itemCount: _reportBloc.data.length,
                        itemBuilder: (context, index) {
                          var data = _reportBloc.data[index];
                          DateTime tempDate =
                              DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").parse(
                                  data["keu_transaction_transaction_date"]);
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 18,
                            ),
                            margin: const EdgeInsets.only(
                                bottom: 8, left: 12, right: 12),
                            decoration: BoxDecoration(
                              color: activeTabColor(
                                  data["menus_type"], labelsColor),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: activeTabColor(
                                      data["menus_type"], chipsColor),
                                  spreadRadius: 0,
                                  blurRadius: 0.2,
                                  offset: const Offset(
                                      0, 0.1), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  data["menus_name"],
                                  style: TextStyle(
                                    color: activeTabColor(data["menus_type"],
                                        reportActiveTabColor),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                data["menus_notes"] != null &&
                                        data["menus_notes"] != ""
                                    ? Text(
                                        data["menus_notes"],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      )
                                    : const SizedBox(),
                                Text(
                                  DateFormat("yyyy-MM-dd HH:mm:ss")
                                      .format(tempDate),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                                data["keu_transaction_notes"] != null &&
                                        data["keu_transaction_notes"] != ""
                                    ? Text(
                                        data["keu_transaction_notes"],
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
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
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
                                      child: Text(
                                        formatCurrency.format(data[
                                                "keu_transaction_value_in"] -
                                            data["keu_transaction_value_out"]),
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      child: SizedBox(),
                                    ),
                                    data["keu_transaction_debtType"] != "NON"
                                        ? Container(
                                            margin:
                                                const EdgeInsets.only(left: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.white54,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            child: Text(
                                              data["keu_transaction_debtType"] +
                                                  " " +
                                                  data["menus_type"]
                                                      .toString()
                                                      .toLowerCase(),
                                              style: const TextStyle(
                                                color: Colors.black54,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: InkWell(
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Icon(
                                                Icons.content_paste_search,
                                                color: Colors.black87,
                                                size: 20,
                                              ),
                                              SizedBox(
                                                width: 4,
                                              ),
                                              Text(
                                                "Detail",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              PageTransition(
                                                type: PageTransitionType
                                                    .bottomToTop,
                                                child: ReportMenuDetailPage(
                                                  menuId: data["menus_id"],
                                                  type: data["menus_type"],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    data["keu_transaction_allow_delete"] == 1
                                        ? Expanded(
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: InkWell(
                                                child: const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                      size: 20,
                                                    ),
                                                    SizedBox(
                                                      width: 4,
                                                    ),
                                                    Text(
                                                      "Hapus",
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                onTap: () async {
                                                  await onDeleteMenu(data);
                                                },
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),
                                  ],
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
            : const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
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
                  Icons.list,
                  color: colorT,
                  size: 50,
                ),
                Text(
                  "Memuat data...",
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
