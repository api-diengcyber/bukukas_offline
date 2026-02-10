import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:keuangan/components/timelines/event_item.dart';
import 'package:keuangan/components/timelines/indicator_position.dart';
import 'package:keuangan/components/timelines/timeline.dart';
import 'package:keuangan/components/timelines/timeline_theme_data.dart';
import 'package:keuangan/db/model/tb_transaksi_model.dart';
import 'package:keuangan/pages/report/detail/report_menu_detail_model.dart';
import 'package:keuangan/pages/report/report_model.dart';
import 'package:keuangan/providers/report_menu_detail_bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keuangan/utils/currency.dart';
import 'package:provider/provider.dart';
import 'package:skeleton_text/skeleton_text.dart';
import '../../../components/timelines/timeline_theme.dart';
import '../../../helpers/set_menus.dart';

class ReportMenuDetailPage extends StatefulWidget {
  const ReportMenuDetailPage({
    super.key,
    required this.menuId,
    required this.type,
  });

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ReportMenuDetailModel().init(context, widget.menuId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportMenuDetailBloc = context.watch<ReportMenuDetailBloc>();

    onDeleteMenu(data) async {
      // PERBAIKAN: Gunakan tryParse agar tidak error 'T'
      DateTime tempDate = DateTime.tryParse(data["keu_transaction_transaction_date"] ?? "") ?? DateTime.now();
      
      int jml = (int.tryParse(data['keu_transaction_value_in']?.toString() ?? "0") ?? 0) -
                (int.tryParse(data['keu_transaction_value_out']?.toString() ?? "0") ?? 0);

      String desc = "${data['menus_name']} (${data['menus_type']})";
      desc += "\n ${DateFormat("yyyy-MM-dd HH:mm:ss").format(tempDate)}";
      if (data['keu_transaction_notes'] != null &&
          data['keu_transaction_notes'] != "") {
        desc += "\n ${data['keu_transaction_notes']}";
      }
      desc += "\n ${formatter.formatString(jml.toString())}";

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
          var resp = await ReportModel()
              .deleteTransaction(context, data["keu_transaction_id"]);
          if (resp) {
            await ReportMenuDetailModel().getMenuDetail(context, widget.menuId);
            if (reportMenuDetailBloc.data.isEmpty) {
              Navigator.pop(context);
            }
          }
        },
      ).show();
    }

    if (reportMenuDetailBloc.data.isEmpty && !reportMenuDetailBloc.loading) {
      // Tambahkan delay sedikit agar tidak error build
      Future.delayed(Duration.zero, () {
        if (mounted) Navigator.pop(context);
      });
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

    TimelineEventDisplay timelineWidget(TbTransaksiModel data) {
      // PERBAIKAN: Gunakan tryParse agar fleksibel format lama/baru
      DateTime tempDate = DateTime.tryParse(data.transactionDate ?? "") ?? DateTime.now();

      return TimelineEventDisplay(
        anchor: IndicatorPosition.top,
        indicator: Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: colorT,
            borderRadius: const BorderRadius.all(
              Radius.circular(64),
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: activeTabColor(
                          reportMenuDetailBloc.detail.type ?? "", chipsColor),
                      spreadRadius: 0,
                      blurRadius: 2,
                      offset: const Offset(0, 2), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      DateFormat("dd MMM yyyy, HH:mm").format(tempDate),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    data.notes != "" && data.notes != null
                        ? Text(
                            data.notes ?? "",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
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
                                offset: const Offset(0, 0.2), 
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          child: Text(
                            // PERBAIKAN: Konversi ke int sebelum diformat
                            formatCurrency.format(
                                (int.tryParse(data.valueIn ?? "0") ?? 0) -
                                (int.tryParse(data.valueOut ?? "0") ?? 0)),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        data.debtType != "NON"
                            ? Container(
                                margin: const EdgeInsets.only(left: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                child: Text(
                                  "${data.debtType} ${data.menuType.toString().toLowerCase()}",
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
                  ],
                ),
              ),
            ),
            data.allowDelete == "1"
                ? Container(
                    margin: const EdgeInsets.only(left: 12),
                    child: InkWell(
                      child: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 20,
                      ),
                      onTap: () async {
                        await onDeleteMenu(data.toJson());
                      },
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      );
    }

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
          color: Colors.grey.shade100,
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
                        offset: const Offset(0, 0.1),
                      ),
                    ],
                  ),
                  child: reportMenuDetailBloc.loading
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
                              reportMenuDetailBloc.detail.name ?? "",
                              style: TextStyle(
                                fontSize: 15,
                                color: activeTabColor(
                                    reportMenuDetailBloc.detail.type ?? "",
                                    reportActiveTabColor),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (reportMenuDetailBloc.detail.notes != null && 
                                reportMenuDetailBloc.detail.notes != "")
                              Text(
                                reportMenuDetailBloc.detail.notes ?? "",
                                style: const TextStyle(fontSize: 14),
                              ),
                            
                            // PERBAIKAN DI SINI: Baris 404 (Sesuai Log Error)
                            Row(
                              children: <Widget>[
                                if (reportMenuDetailBloc.detail.total != null)
                                  Text(
                                    formatCurrency.format(
                                        int.tryParse(reportMenuDetailBloc.detail.total!.toString()) ?? 0),
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  )
                                else if ((reportMenuDetailBloc.detail.type == "Hutang" || 
                                          reportMenuDetailBloc.detail.type == "Piutang") &&
                                         reportMenuDetailBloc.detail.statusPaidOff == "1")
                                  Row(
                                    children: <Widget>[
                                      const Text(
                                        "Lunas ",
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "(${reportMenuDetailBloc.detail.type == "Hutang" ? formatCurrency.format(int.tryParse(reportMenuDetailBloc.detail.totalIn?.toString() ?? "0") ?? 0) : formatCurrency.format(int.tryParse(reportMenuDetailBloc.detail.totalOut?.toString() ?? "0") ?? 0)})",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                const Spacer(),
                                if (reportMenuDetailBloc.detail.deadline != null && 
                                    reportMenuDetailBloc.detail.deadline != "")
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 0,
                                          blurRadius: 0.2,
                                          offset: const Offset(0, 0.2),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    child: Text(
                                      // PERBAIKAN: tryParse untuk deadline agar tidak error 'T'
                                      DateFormat("yyyy-MM-dd").format(
                                          DateTime.tryParse(reportMenuDetailBloc.detail.deadline!) ?? DateTime.now()),
                                      style: TextStyle(
                                        color: reportMenuDetailBloc.detail.statusPaidOff == "1" ? Colors.grey : Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          ],
                        ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                    margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 0,
                          blurRadius: 0.2,
                          offset: const Offset(0, 0.1),
                        ),
                      ],
                    ),
                    child: !reportMenuDetailBloc.loading
                        ? reportMenuDetailBloc.data.isNotEmpty
                            ? TimelineTheme(
                                data: TimelineThemeData(
                                  lineColor: colorT,
                                  strokeWidth: 2,
                                ),
                                child: Timeline(
                                  indicatorSize: 10,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 24),
                                  altOffset: const Offset(5, 16),
                                  anchor: IndicatorPosition.top,
                                  events: <TimelineEventDisplay>[
                                    for (var item in reportMenuDetailBloc.data)
                                      timelineWidget(item),
                                    if (reportMenuDetailBloc.detail.statusPaidOff == "1")
                                      TimelineEventDisplay(
                                        anchor: IndicatorPosition.top,
                                        indicatorOffset: const Offset(0, -3),
                                        indicator: Container(
                                          width: 5, height: 5,
                                          decoration: BoxDecoration(
                                            color: colorT,
                                            borderRadius: const BorderRadius.all(Radius.circular(64)),
                                          ),
                                        ),
                                        child: Container(
                                          margin: const EdgeInsets.only(left: 8),
                                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: activeTabColor(reportMenuDetailBloc.detail.type ?? "", chipsColor),
                                                spreadRadius: 0, blurRadius: 2,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Text(
                                            "Lunas",
                                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              )
                            : const Center(child: Text("Tidak ada riwayat transaksi"))
                        : Center(child: SpinKitDoubleBounce(color: colorT)),
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