import 'package:keuangan/components/tab_chips.dart';
import 'package:keuangan/pages/report/report_model.dart';
import 'package:keuangan/providers/report_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PanelReportChipsMenu extends StatefulWidget {
  const PanelReportChipsMenu({
    super.key,
    required this.backgroundColor,
  });

  final Color backgroundColor;

  @override
  State<StatefulWidget> createState() => _PanelReportChipsMenuState();
}

const dataChips = [
  {
    'name': 'Semua',
    'value': 'Semua',
  },
  {
    'name': 'Periode',
    'value': 'Periode',
  },
];

class _PanelReportChipsMenuState extends State<PanelReportChipsMenu> {
  @override
  Widget build(BuildContext context) {
    final reportBloc = context.watch<ReportBloc>();
    return TabChips(
      activeColor: Colors.white70,
      activeTextColor: Colors.black,
      elevation: 0,
      backgroundColor: widget.backgroundColor,
      data: dataChips,
      enabled: !reportBloc.loadingSummary,
      initialIndex: dataChips.indexWhere(
          (element) => element['value'] == reportBloc.activeChipTab),
      onTap: !reportBloc.loadingSummary
          ? (data, index) async {
              reportBloc.activeChipTab = data["value"];
              await ReportModel().getSummaryReport(context);
              await ReportModel().getTabsData(context);
            }
          : null,
    );
  }
}
