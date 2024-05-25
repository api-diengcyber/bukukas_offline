import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:keuangan/pages/report/detail/report_menu_detail_model.dart';
import 'package:keuangan/pages/report/report_model.dart';
import 'package:keuangan/providers/report_menu_detail_bloc.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeleton_text/skeleton_text.dart';
import '../../../helpers/set_menus.dart';

class ReportMenuDetailPage extends StatefulWidget {
  const ReportMenuDetailPage({
    Key? key,
    required this.menuId,
    required this.type,
  }) : super(key: key);

  final int menuId;
  final String type;

  @override
  State<ReportMenuDetailPage> createState() => _ReportMenuDetailPageState();
}

class _ReportMenuDetailPageState extends State<ReportMenuDetailPage> {
  final formatCurrency = NumberFormat.simpleCurrency(
    locale: 'id_ID',
    decimalDigits: 0,
  );
  final CurrencyTextInputFormatter _formatter =
      CurrencyTextInputFormatter(NumberFormat.compactCurrency(
    decimalDigits: 0,
    locale: 'id',
    symbol: 'Rp',
  ));

  // List<TimelineEventDisplay> events = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ReportMenuDetailModel().init(context, widget.menuId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final _reportMenuDetailBloc = context.watch<ReportMenuDetailBloc>();

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
            await ReportMenuDetailModel().getMenuDetail(context, widget.menuId);
            if (_reportMenuDetailBloc.data.isEmpty) {
              Navigator.pop(context);
            }
          }
        },
      ).show();
    }

    if (_reportMenuDetailBloc.data.isEmpty) {
      Navigator.pop(context);
    }

    Color colorT = widget.type == "Pemasukan"
        ? Colors.green
        : widget.type == "Pengeluaran"
            ? Colors.pink
            : widget.type == "Hutang"
                ? Colors.amber
                : widget.type == "Piutang"
                    ? Colors.blue
                    : Colors.grey;

    AppBar appBar = AppBar(
      backgroundColor: const Color(0x00000000),
      elevation: 0,
      centerTitle: true,
      leading: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back, color: Colors.black),
      ),
      title: Text(
        '${widget.type} detail',
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    double marginTopScreen =
        appBar.preferredSize.height + MediaQuery.of(context).viewPadding.top;

    // TimelineEventDisplay timelineWidget(dynamic data) {
    //   DateTime tempDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS")
    //       .parse(data["keu_transaction_transaction_date"]);

    //   return TimelineEventDisplay(
    //     anchor: IndicatorPosition.top,
    //     indicator: Container(
    //       width: 5,
    //       height: 5,
    //       decoration: BoxDecoration(
    //         color: widget.type == "Pemasukan"
    //             ? Colors.green
    //             : widget.type == "Pengeluaran"
    //                 ? Colors.pink
    //                 : widget.type == "Hutang"
    //                     ? Colors.amber
    //                     : widget.type == "Piutang"
    //                         ? Colors.blue
    //                         : Colors.grey,
    //         borderRadius: const BorderRadius.all(
    //           Radius.circular(64),
    //         ),
    //       ),
    //     ),
    //     child: Row(
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       children: <Widget>[
    //         Expanded(
    //           child: Container(
    //             margin: const EdgeInsets.only(left: 8),
    //             padding: const EdgeInsets.symmetric(
    //               vertical: 12,
    //               horizontal: 16,
    //             ),
    //             decoration: BoxDecoration(
    //               color: Colors.white,
    //               borderRadius: BorderRadius.circular(20),
    //               boxShadow: [
    //                 BoxShadow(
    //                   color: activeTabColor(
    //                       _reportMenuDetailBloc.detail["keu_menu_type"],
    //                       chipsColor),
    //                   spreadRadius: 0,
    //                   blurRadius: 2,
    //                   offset: const Offset(0, 2), // changes position of shadow
    //                 ),
    //               ],
    //             ),
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: <Widget>[
    //                 Text(
    //                   DateFormat("yyyy-MM-dd HH:mm:ss").format(tempDate),
    //                   style: const TextStyle(
    //                     fontWeight: FontWeight.bold,
    //                   ),
    //                 ),
    //                 data["keu_transaction_notes"] != "" &&
    //                         data["keu_transaction_notes"] != null
    //                     ? Text(
    //                         data["keu_transaction_notes"],
    //                         style: const TextStyle(
    //                           fontWeight: FontWeight.bold,
    //                         ),
    //                       )
    //                     : const SizedBox(),
    //                 Row(
    //                   children: <Widget>[
    //                     Container(
    //                       decoration: BoxDecoration(
    //                         color: Colors.white,
    //                         borderRadius: BorderRadius.circular(10),
    //                         boxShadow: [
    //                           BoxShadow(
    //                             color: Colors.grey.withOpacity(0.5),
    //                             spreadRadius: 0,
    //                             blurRadius: 0.2,
    //                             offset: const Offset(
    //                                 0, 0.2), // changes position of shadow
    //                           ),
    //                         ],
    //                       ),
    //                       padding: const EdgeInsets.symmetric(
    //                         horizontal: 6,
    //                         vertical: 4,
    //                       ),
    //                       child: Text(
    //                         formatCurrency.format(
    //                             data["keu_transaction_value_in"] -
    //                                 data["keu_transaction_value_out"]),
    //                         style: const TextStyle(
    //                           color: Colors.black87,
    //                           fontWeight: FontWeight.bold,
    //                           fontSize: 14,
    //                         ),
    //                       ),
    //                     ),
    //                     const Expanded(
    //                       child: SizedBox(),
    //                     ),
    //                     data["keu_transaction_debtType"] != "NON"
    //                         ? Container(
    //                             margin: const EdgeInsets.only(left: 6),
    //                             decoration: BoxDecoration(
    //                               color: Colors.grey.shade100,
    //                               borderRadius: BorderRadius.circular(10),
    //                             ),
    //                             padding: const EdgeInsets.symmetric(
    //                               horizontal: 12,
    //                               vertical: 4,
    //                             ),
    //                             child: Text(
    //                               data["keu_transaction_debtType"] +
    //                                   " " +
    //                                   data["menus_type"]
    //                                       .toString()
    //                                       .toLowerCase(),
    //                               style: const TextStyle(
    //                                 color: Colors.black54,
    //                                 fontWeight: FontWeight.bold,
    //                                 fontSize: 13,
    //                               ),
    //                             ),
    //                           )
    //                         : const SizedBox(),
    //                   ],
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    //         data["keu_transaction_allow_delete"] == 1
    //             ? Container(
    //                 margin: const EdgeInsets.only(left: 12),
    //                 child: InkWell(
    //                   child: const Icon(
    //                     Icons.delete,
    //                     color: Colors.red,
    //                     size: 20,
    //                   ),
    //                   onTap: () async {
    //                     await onDeleteMenu(data);
    //                   },
    //                 ),
    //               )
    //             : const SizedBox(),
    //       ],
    //     ),
    //   );
    // }

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, 'load');
        return Future.value(false);
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: appBar,
        body: Container(
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
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 8,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 0,
                        blurRadius: 0.2,
                        offset:
                            const Offset(0, 0.1), // changes position of shadow
                      ),
                    ],
                  ),
                  child: _reportMenuDetailBloc.loading
                      ? SkeletonAnimation(
                          borderRadius: BorderRadius.circular(20.0),
                          shimmerColor: Colors.blueGrey.shade50,
                          child: Container(
                            height: 30,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.white54,
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _reportMenuDetailBloc.detail["keu_menu_name"],
                              style: TextStyle(
                                fontSize: 15,
                                color: activeTabColor(
                                    _reportMenuDetailBloc
                                        .detail["keu_menu_type"],
                                    reportActiveTabColor),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            _reportMenuDetailBloc.detail["keu_menu_notes"] !=
                                        "" &&
                                    _reportMenuDetailBloc
                                            .detail["keu_menu_notes"] !=
                                        null
                                ? Text(
                                    _reportMenuDetailBloc
                                        .detail["keu_menu_notes"],
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  )
                                : const SizedBox(),
                            _reportMenuDetailBloc.detail['defaultValue'] !=
                                        "" &&
                                    _reportMenuDetailBloc
                                            .detail['defaultValue'] !=
                                        null &&
                                    _reportMenuDetailBloc
                                            .detail['defaultValue'] >
                                        0
                                ? Container(
                                    padding: const EdgeInsets.only(
                                      top: 2,
                                      bottom: 2,
                                      left: 6,
                                      right: 6,
                                    ),
                                    margin: const EdgeInsets.only(top: 3),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: _reportMenuDetailBloc
                                                  .detail['type'] ==
                                              "Pemasukan"
                                          ? Colors.green.shade100
                                          : (_reportMenuDetailBloc
                                                      .detail['type'] ==
                                                  "Pengeluaran"
                                              ? Colors.pink.shade100
                                              : (_reportMenuDetailBloc
                                                          .detail['type'] ==
                                                      "Hutang")
                                                  ? Colors.amber.shade100
                                                  : Colors.blue.shade100),
                                    ),
                                    child: Text(
                                      _formatter.formatString(
                                          _reportMenuDetailBloc
                                              .detail['defaultValue']
                                              .toString()),
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 13,
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                            Row(
                              children: <Widget>[
                                _reportMenuDetailBloc.detail["total"] != 0 &&
                                        _reportMenuDetailBloc.detail["total"] !=
                                            null
                                    ? Text(
                                        formatCurrency.format(
                                            _reportMenuDetailBloc
                                                .detail["total"]),
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      )
                                    : (_reportMenuDetailBloc.detail[
                                                        "keu_menu_type"] ==
                                                    "Hutang" ||
                                                _reportMenuDetailBloc.detail[
                                                        "keu_menu_type"] ==
                                                    "Piutang") &&
                                            _reportMenuDetailBloc.detail[
                                                    "keu_menu_status_paid_off"] ==
                                                1
                                        ? Row(
                                            children: <Widget>[
                                              const Text(
                                                "Lunas",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 4,
                                              ),
                                              Text(
                                                "(" +
                                                    (_reportMenuDetailBloc
                                                                    .detail[
                                                                "keu_menu_type"] ==
                                                            "Hutang"
                                                        ? formatCurrency.format(
                                                            _reportMenuDetailBloc
                                                                    .detail[
                                                                "totalIn"])
                                                        : _reportMenuDetailBloc
                                                                        .detail[
                                                                    "keu_menu_type"] ==
                                                                "Piutang"
                                                            ? formatCurrency.format(
                                                                _reportMenuDetailBloc
                                                                        .detail[
                                                                    "totalOut"])
                                                            : "") +
                                                    ")",
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          )
                                        : const SizedBox(),
                                const Expanded(
                                  child: SizedBox(),
                                ),
                                (_reportMenuDetailBloc
                                                .detail["keu_menu_deadline"] !=
                                            null &&
                                        _reportMenuDetailBloc
                                                .detail["keu_menu_deadline"] !=
                                            "" &&
                                        (_reportMenuDetailBloc
                                                    .detail["keu_menu_type"] ==
                                                "Hutang" ||
                                            _reportMenuDetailBloc
                                                    .detail["keu_menu_type"] ==
                                                "Piutang"))
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 0.2,
                                              offset: const Offset(0,
                                                  0.2), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        child: Text(
                                          DateFormat("yyyy-MM-dd").format(
                                              DateFormat(
                                                      "yyyy-MM-dd'T'HH:mm:ss.SSS")
                                                  .parse(_reportMenuDetailBloc
                                                          .detail[
                                                      "keu_menu_deadline"])),
                                          style: TextStyle(
                                            color: _reportMenuDetailBloc.detail[
                                                        "keu_menu_status_paid_off"] ==
                                                    1
                                                ? Colors.grey
                                                : Colors.red,
                                            fontWeight: FontWeight.bold,
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
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 12,
                    ),
                    margin: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 0,
                          blurRadius: 0.2,
                          offset: const Offset(
                              0, 0.1), // changes position of shadow
                        ),
                      ],
                    ),
                    // child: !_reportMenuDetailBloc.loading
                    //     ? _reportMenuDetailBloc.data.isNotEmpty
                    //         ? TimelineTheme(
                    //             data: TimelineThemeData(
                    //               lineColor: colorT,
                    //               strokeWidth: 2,
                    //             ),
                    //             child: Timeline(
                    //               indicatorSize: 10,
                    //               separatorBuilder: (context, index) =>
                    //                   const SizedBox(height: 24),
                    //               altOffset: const Offset(5, 16),
                    //               anchor: IndicatorPosition.top,
                    //               events: <TimelineEventDisplay>[
                    //                 for (var item in _reportMenuDetailBloc.data)
                    //                   timelineWidget(item),
                    //                 if (_reportMenuDetailBloc.detail[
                    //                         "keu_menu_status_paid_off"] ==
                    //                     1)
                    //                   TimelineEventDisplay(
                    //                     anchor: IndicatorPosition.top,
                    //                     indicatorOffset: const Offset(0, -3),
                    //                     indicator: Container(
                    //                       width: 5,
                    //                       height: 5,
                    //                       decoration: BoxDecoration(
                    //                         color: widget.type == "Pemasukan"
                    //                             ? Colors.green
                    //                             : widget.type == "Pengeluaran"
                    //                                 ? Colors.pink
                    //                                 : widget.type == "Hutang"
                    //                                     ? Colors.amber
                    //                                     : widget.type ==
                    //                                             "Piutang"
                    //                                         ? Colors.blue
                    //                                         : Colors.grey,
                    //                         borderRadius:
                    //                             const BorderRadius.all(
                    //                           Radius.circular(64),
                    //                         ),
                    //                       ),
                    //                     ),
                    //                     child: Container(
                    //                       margin:
                    //                           const EdgeInsets.only(left: 8),
                    //                       padding: const EdgeInsets.symmetric(
                    //                         vertical: 12,
                    //                         horizontal: 16,
                    //                       ),
                    //                       decoration: BoxDecoration(
                    //                         color: Colors.white,
                    //                         borderRadius:
                    //                             BorderRadius.circular(20),
                    //                         boxShadow: [
                    //                           BoxShadow(
                    //                             color: activeTabColor(
                    //                                 _reportMenuDetailBloc
                    //                                         .detail[
                    //                                     "keu_menu_type"],
                    //                                 chipsColor),
                    //                             spreadRadius: 0,
                    //                             blurRadius: 2,
                    //                             offset: const Offset(0,
                    //                                 2), // changes position of shadow
                    //                           ),
                    //                         ],
                    //                       ),
                    //                       child: const Text(
                    //                         "Lunas",
                    //                         style: TextStyle(
                    //                           color: Colors.green,
                    //                           fontWeight: FontWeight.bold,
                    //                         ),
                    //                       ),
                    //                     ),
                    //                   ),
                    //               ],
                    //             ),
                    //           )
                    //         : const SizedBox()
                    //     : Center(
                    //         child: SpinKitDoubleBounce(
                    //           color: colorT,
                    //         ),
                    //       ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
