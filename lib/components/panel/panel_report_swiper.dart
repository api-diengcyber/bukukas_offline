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
  State<PanelReportSwiper> createState() => _PanelReportSwiperState();
}

// 5 Kategori Tetap
List<String> _listMenuName = [
  "Semua",
  "Pemasukan",
  "Pengeluaran",
  "Hutang",
  "Piutang",
];

// 5 Gambar Background Tetap
List<String> _listImages = [
  "assets/images/grad0.png",
  "assets/images/grad1.png",
  "assets/images/grad2.png",
  "assets/images/grad3.png",
  "assets/images/grad4.png",
];

class _PanelReportSwiperState extends State<PanelReportSwiper> {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final formatCurrency = NumberFormat.simpleCurrency(
    locale: 'id_ID',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final reportBloc = context.watch<ReportBloc>();

    // Menentukan index swiper saat ini berdasarkan state di Bloc
    int currentIndex = _listMenuName.indexOf(reportBloc.activeMenuTab);
    if (currentIndex == -1) currentIndex = 0; // Guard if not found

    showDateTimeRange() async {
      DateTimeRange? result = await showDateRangePicker(
        context: context,
        firstDate: DateTime(DateTime.now().year - 1, 1, 1),
        lastDate: DateTime(DateTime.now().year + 1, 12, 31),
        currentDate: DateTime.now(),
        initialDateRange: reportBloc.startDate != "" && reportBloc.endDate != ""
            ? DateTimeRange(
                start: DateTime.parse(reportBloc.startDate),
                end: DateTime.parse(reportBloc.endDate),
              )
            : null,
        saveText: 'Selesai',
      );
      if (result != null) {
        reportBloc.startDate = formatter.format(result.start);
        reportBloc.endDate = formatter.format(result.end);
        // Refresh data setelah pilih tanggal
        await ReportModel().getSummaryReport(context);
        await ReportModel().getTabsData(context);
      }
    }

    return SizedBox(
      height: reportBloc.activeChipTab == "Periode" ? 170 : 130,
      child: Swiper(
        loop: false,
        autoplay: false,
        // Item count tetap 5 sesuai kategori
        itemCount: _listMenuName.length,
        scrollDirection: Axis.horizontal,
        index: currentIndex,
        control: const SwiperControl(
          color: Colors.black45,
          size: 20,
        ),
        onIndexChanged: (index) async {
          // Update kategori aktif di Bloc
          reportBloc.activeMenuTab = _listMenuName[index];
          
          // Reset tab bawah ke "Data" jika pindah kategori
          if (index == 0) {
            reportBloc.reportIndexActiveTab = 0;
          }

          // Panggil ulang data dari database berdasarkan kategori baru
          await ReportModel().getSummaryReport(context);
          await ReportModel().getTabsData(context);
        },
        itemBuilder: (BuildContext context, int index) {
          String title = _listMenuName[index];
          String image = _listImages[index];

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 0.2,
                  offset: const Offset(0, 0.1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      title.toUpperCase(), // Menampilkan PEMASUKAN, dsb.
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        letterSpacing: 1.2,
                        color: index == 0 ? Colors.black : Colors.white,
                      ),
                    ),
                    const Spacer(),
                    // Indikator titik warna (opsional, hanya muncul di "Semua")
                    if (index == 0)
                      Row(
                        children: [
                          for (int i = 1; i < 5; i++)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              child: CircleCustom(
                                height: 8,
                                gradient: gradientActiveDMenu[i - 1],
                                active: true,
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
                // Chips Menu (Semua, Bulanan, Periode)
                PanelReportChipsMenu(
                  backgroundColor: chipsColor[index],
                ),
                // Filter Tanggal jika pilih "Periode"
                if (reportBloc.activeChipTab == "Periode")
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: InkWell(
                      onTap: () => showDateTimeRange(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              reportBloc.startDate == "" 
                                  ? "Pilih Tanggal" 
                                  : "${reportBloc.startDate} - ${reportBloc.endDate}",
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const Spacer(),
                // Menampilkan Total Saldo Kategori
                !reportBloc.loadingSummary
                    ? Text(
                        formatCurrency.format(reportBloc.dataSummary.totalByType ?? 0),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: index == 0 ? Colors.black : Colors.white,
                        ),
                      )
                    : SkeletonAnimation(
                        child: Container(
                          height: 25,
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
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