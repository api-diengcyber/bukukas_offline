import 'package:keuangan/components/circle_custom.dart';
import 'package:keuangan/components/panel/panel_report_chips_menu.dart';
import 'package:keuangan/helpers/set_menus.dart';
import 'package:keuangan/pages/report/report_model.dart';
import 'package:keuangan/providers/report_bloc.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:intl/intl.dart';

class PanelReportSwiper extends StatefulWidget {
  const PanelReportSwiper({super.key});

  @override
  State<StatefulWidget> createState() => _PanelReportSwiperState();
}

List<String> _listImages = [
  "assets/images/grad0.png",
  "assets/images/grad1.png",
  "assets/images/grad2.png",
  "assets/images/grad3.png",
  "assets/images/grad4.png",
];

List<String> _listMenuName = [
  "Semua",
  "Pemasukan",
  "Pengeluaran",
  "Hutang",
  "Piutang",
];

class _PanelReportSwiperState extends State<PanelReportSwiper> {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final formatCurrency = NumberFormat.simpleCurrency(
    locale: 'id_ID',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final reportBloc = context.watch<ReportBloc>();

    showDateTimeRange() async {
      DateTimeRange? result = await showDateRangePicker(
        context: context,
        firstDate:
            DateTime(DateTime.now().year - 1, 1, 1), // the earliest allowable
        lastDate:
            DateTime(DateTime.now().year + 1, 12, 31), // the latest allowable
        currentDate: DateTime.now(),
        initialDateRange:
            reportBloc.startDate != "" && reportBloc.startDate != ""
                ? DateTimeRange(
                    start: DateTime.parse(reportBloc.startDate),
                    end: DateTime.parse(reportBloc.endDate),
                  )
                : null,
        saveText: 'Selesai',
      );
      if (result != null) {
        DateTime startDate = result.start;
        DateTime endDate = result.end;
        reportBloc.startDate = formatter.format(startDate);
        reportBloc.endDate = formatter.format(endDate);
        await ReportModel().getSummaryReport(context);
        await ReportModel().getTabsData(context);
      }
    }

    return SizedBox(
      height: reportBloc.activeChipTab == "Periode" ? 170 : 130,
      child: Swiper(
        loop: false,
        autoplay: false,
        physics: (reportBloc.loadingSummary || reportBloc.loadingData)
            ? reportBloc.listAvailableMenuType.isNotEmpty
                ? const NeverScrollableScrollPhysics()
                : null
            : null,
        itemCount: reportBloc.listAvailableMenuType.length + 1,
        scrollDirection: Axis.horizontal,
        control: reportBloc.listAvailableMenuType.isNotEmpty
            ? const SwiperControl(
                color: Colors.black45,
                size: 28,
              )
            : null,
        index: (reportBloc.activeMenuTab == "Semua" ||
                reportBloc.listAvailableMenuType.isEmpty)
            ? 0
            : reportBloc.listAvailableMenuType.indexWhere(
                    (element) => element['name'] == reportBloc.activeMenuTab) +
                1,
        onIndexChanged: (index) async {
          if (index == 0) {
            reportBloc.activeMenuTab = _listMenuName[index];
            reportBloc.reportIndexActiveTab = 0;
          } else {
            if (reportBloc.activeMenuTab == "Semua") {
              if (reportBloc.reportIndexActiveTab == 1) {
                reportBloc.reportIndexActiveTab = 2;
              }
            }
            var rowIndex = reportBloc.listAvailableMenuType[index - 1];
            reportBloc.activeMenuTab = rowIndex["name"];
          }
          await ReportModel().getSummaryReport(context);
          await ReportModel().getTabsData(context);
        },
        itemBuilder: (BuildContext context, int index) {
          int rIndex = _listMenuName.indexOf(reportBloc.activeMenuTab);
          return Container(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            margin: const EdgeInsets.only(
              left: 16,
              right: 16,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: AssetImage(_listImages[rIndex]),
                fit: BoxFit.cover,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      reportBloc.activeMenuTab,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: reportBloc.activeMenuTab == "Semua"
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                    const Expanded(
                      child: SizedBox(),
                    ),
                    reportBloc.activeMenuTab == "Semua"
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              for (var item in reportBloc.listAvailableMenuType)
                                Container(
                                  margin: const EdgeInsets.only(left: 4),
                                  child: CircleCustom(
                                    height: 8,
                                    gradient: item["name"] == "Pemasukan"
                                        ? gradientActiveDMenu[0]
                                        : (item["name"] == "Pengeluaran"
                                            ? gradientActiveDMenu[1]
                                            : (item["name"] == "Hutang")
                                                ? gradientActiveDMenu[2]
                                                : gradientActiveDMenu[3]),
                                    active: true,
                                  ),
                                ),
                            ],
                          )
                        : const SizedBox(),
                  ],
                ),
                PanelReportChipsMenu(
                  backgroundColor: chipsColor[rIndex],
                ),
                reportBloc.activeChipTab == "Periode"
                    ? InkWell(
                        onTap: !reportBloc.loadingSummary &&
                                !reportBloc.loadingData
                            ? () async {
                                await showDateTimeRange();
                              }
                            : () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: <Widget>[
                              const Icon(
                                Icons.calendar_month,
                                size: 20,
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Text(
                                    "Periode",
                                    style: TextStyle(
                                      fontSize: 13,
                                    ),
                                  ),
                                  reportBloc.startDate != "" &&
                                          reportBloc.endDate != ""
                                      ? Text(
                                          "${reportBloc.startDate} s/d ${reportBloc.endDate}",
                                          style: const TextStyle(
                                            fontSize: 13,
                                          ),
                                        )
                                      : const SizedBox(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(),
                const Expanded(
                  child: SizedBox(),
                ),
                !reportBloc.loadingSummary
                    ? Text(
                        formatCurrency
                            .format(reportBloc.dataSummary['totalByType']),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: reportBloc.activeMenuTab == "Semua"
                              ? Colors.black
                              : Colors.white,
                        ),
                      )
                    : SkeletonAnimation(
                        borderRadius: BorderRadius.circular(20.0),
                        shimmerColor: Colors.grey.shade200,
                        child: Container(
                          height: 30,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.white54,
                          ),
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}
