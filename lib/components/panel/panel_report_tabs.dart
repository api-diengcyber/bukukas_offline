import 'package:keuangan/components/tab/tab_report_data.dart';
import 'package:keuangan/components/tab/tab_report_graph.dart';
import 'package:keuangan/components/tab/tab_report_menu.dart';
import 'package:keuangan/helpers/set_menus.dart';
import 'package:keuangan/pages/report/report_model.dart';
import 'package:keuangan/providers/report_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PanelReportTabs extends StatefulWidget {
  const PanelReportTabs({super.key});

  @override
  State<StatefulWidget> createState() => _PanelReportTabsState();
}

class _PanelReportTabsState extends State<PanelReportTabs>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
  }

  List<dynamic> tabs = [
    {
      'name': 'Data',
      'icon': Icons.list,
      'widget': const TabReportData(),
    },
    {
      'name': 'Grafik',
      'icon': Icons.bar_chart,
      'widget': const TabReportGraph(),
    },
  ];

  List<dynamic> tabsForMenus = [
    {
      'name': 'Data',
      'icon': Icons.list,
      'widget': const TabReportData(),
    },
    {
      'name': 'Menu',
      'icon': Icons.apps_rounded,
      'widget': const TabReportMenu(),
    },
    {
      'name': 'Grafik',
      'icon': Icons.bar_chart,
      'widget': const TabReportGraph(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final _reportBloc = context.watch<ReportBloc>();

    _tabController = TabController(
      initialIndex: _reportBloc.reportIndexActiveTab,
      length: _reportBloc.activeMenuTab == "Semua" ? 2 : 3,
      vsync: this,
    );
    _tabController.addListener(() async {
      if (_tabController.indexIsChanging) {
        _reportBloc.reportIndexActiveTab = _tabController.index;
        await ReportModel().getTabsData(context);
      }
    });

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 8,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
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
      child: Column(
        children: <Widget>[
          TabBar(
            controller: _tabController,
            indicatorColor:
                activeTabColor(_reportBloc.activeMenuTab, reportActiveTabColor),
            tabs: (_reportBloc.activeMenuTab == "Semua" ? tabs : tabsForMenus)
                .asMap()
                .map(
                  (i, element) => MapEntry(
                    i,
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            element['icon'],
                            color: _reportBloc.reportIndexActiveTab == i
                                ? activeTabColor(_reportBloc.activeMenuTab,
                                    reportActiveTabColor)
                                : Colors.black54,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            element['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _reportBloc.reportIndexActiveTab == i
                                  ? activeTabColor(_reportBloc.activeMenuTab,
                                      reportActiveTabColor)
                                  : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .values
                .toList(),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.62,
            // height: MediaQuery.of(context).size.height *
            //     ((_reportBloc.activeMenuTab == "Semua" ? 0.58 : 0.5) +
            //         (_reportBloc.activeChipTab == "Semua" ? 0.06 : 0)),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: Colors.white,
            ),
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children:
                  (_reportBloc.activeMenuTab == "Semua" ? tabs : tabsForMenus)
                      .asMap()
                      .map(
                        (i, element) => MapEntry(
                          i,
                          element['widget'] as Widget,
                        ),
                      )
                      .values
                      .toList(),
              //controller: __tabController,
            ),
          ),
        ],
      ),
    );
  }
}
