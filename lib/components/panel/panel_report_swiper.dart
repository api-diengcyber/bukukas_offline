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
  const PanelReportSwiper({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PanelReportSwiperState();
}

List<String> _listImages = [
  "keuangan/assets/images/grad0.png",
  "keuangan/assets/images/grad1.png",
  "keuangan/assets/images/grad2.png",
  "keuangan/assets/images/grad3.png",
  "keuangan/assets/images/grad4.png",
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
    final _reportBloc = context.watch<ReportBloc>();

    showDateTimeRange() async {
      DateTimeRange? result = await showDateRangePicker(
        context: context,
        firstDate:
            DateTime(DateTime.now().year - 1, 1, 1), // the earliest allowable
        lastDate:
            DateTime(DateTime.now().year + 1, 12, 31), // the latest allowable
        currentDate: DateTime.now(),
        initialDateRange:
            _reportBloc.startDate != "" && _reportBloc.startDate != ""
                ? DateTimeRange(
                    start: DateTime.parse(_reportBloc.startDate),
                    end: DateTime.parse(_reportBloc.endDate),
                  )
                : null,
        saveText: 'Selesai',
      );
      if (result != null) {
        DateTime startDate = result.start;
        DateTime endDate = result.end;
        _reportBloc.startDate = formatter.format(startDate);
        _reportBloc.endDate = formatter.format(endDate);
        await ReportModel().getSummaryReport(context);
        await ReportModel().getTabsData(context);
      }
    }

    return SizedBox(
      height: _reportBloc.activeChipTab == "Periode" ? 170 : 130,
      child: Swiper(
        loop: false,
        autoplay: false,
        physics: (_reportBloc.loadingSummary || _reportBloc.loadingData)
            ? _reportBloc.listAvailableMenuType.isNotEmpty
                ? const NeverScrollableScrollPhysics()
                : null
            : null,
        itemCount: _reportBloc.listAvailableMenuType.length + 1,
        scrollDirection: Axis.horizontal,
        control: _reportBloc.listAvailableMenuType.isNotEmpty
            ? const SwiperControl(
                color: Colors.black45,
                size: 28,
              )
            : null,
        index: (_reportBloc.activeMenuTab == "Semua" ||
                _reportBloc.listAvailableMenuType.isEmpty)
            ? 0
            : _reportBloc.listAvailableMenuType.indexWhere(
                    (element) => element['name'] == _reportBloc.activeMenuTab) +
                1,
        onIndexChanged: (index) async {
          if (index == 0) {
            _reportBloc.activeMenuTab = _listMenuName[index];
            _reportBloc.reportIndexActiveTab = 0;
          } else {
            if (_reportBloc.activeMenuTab == "Semua") {
              if (_reportBloc.reportIndexActiveTab == 1) {
                _reportBloc.reportIndexActiveTab = 2;
              }
            }
            var rowIndex = _reportBloc.listAvailableMenuType[index - 1];
            _reportBloc.activeMenuTab = rowIndex["name"];
          }
          await ReportModel().getSummaryReport(context);
          await ReportModel().getTabsData(context);
        },
        itemBuilder: (BuildContext context, int index) {
          int rIndex = _listMenuName.indexOf(_reportBloc.activeMenuTab);
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
                      _reportBloc.activeMenuTab,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: _reportBloc.activeMenuTab == "Semua"
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                    const Expanded(
                      child: SizedBox(),
                    ),
                    _reportBloc.activeMenuTab == "Semua"
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              for (var item
                                  in _reportBloc.listAvailableMenuType)
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
                _reportBloc.activeChipTab == "Periode"
                    ? InkWell(
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
                                  _reportBloc.startDate != "" &&
                                          _reportBloc.endDate != ""
                                      ? Text(
                                          "${_reportBloc.startDate} s/d ${_reportBloc.endDate}",
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
                        onTap: !_reportBloc.loadingSummary &&
                                !_reportBloc.loadingData
                            ? () async {
                                await showDateTimeRange();
                              }
                            : () {},
                      )
                    : const SizedBox(),
                const Expanded(
                  child: SizedBox(),
                ),
                !_reportBloc.loadingSummary
                    ? Text(
                        formatCurrency
                            .format(_reportBloc.dataSummary['totalByType']),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: _reportBloc.activeMenuTab == "Semua"
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
