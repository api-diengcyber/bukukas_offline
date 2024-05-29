import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:keuangan/components/bubble_triangle.dart';
import 'package:keuangan/components/circle_custom.dart';
import 'package:keuangan/components/circle_menu.dart';
import 'package:keuangan/components/pagination.dart';
import 'package:keuangan/db/model/tb_transaksi_model.dart';
import 'package:keuangan/helpers/set_menus.dart';
import 'package:keuangan/pages/transaction/create_model.dart';
import 'package:keuangan/pages/transaction/create2_page.dart';
import 'package:keuangan/providers/create_bloc.dart';
import 'package:keuangan/providers/global_bloc.dart';
import 'package:keuangan/providers/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keuangan/utils/currency.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../report/detail/report_menu_detail_page.dart';
import '../report/report_model.dart';

class CreateTransactionPage extends StatefulWidget {
  const CreateTransactionPage({super.key});

  @override
  State<CreateTransactionPage> createState() => _CreateTransactionPageState();
}

class _CreateTransactionPageState extends State<CreateTransactionPage> {
  final formatCurrency = NumberFormat.simpleCurrency(
    locale: 'id_ID',
    decimalDigits: 0,
  );

  int totalIn = 0;
  int totalOut = 0;
  int totalNominal = 0;

  int trendIndexPemasukan = -1;
  int trendIndexPengeluaran = -1;
  int trendIndexHutang = -1;
  int trendIndexPiutang = -1;

  bool showSelesai = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      CreateModel().init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final globalBloc = context.watch<GlobalBloc>();
    final createBloc = context.watch<CreateBloc>();
    final transactionBloc = context.watch<TransactionBloc>();

    onDeleteMenu(TbTransaksiModel data) async {
      DateTime tempDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS")
          .parse(data.transactionDate ?? "");
      int jml =
          int.parse(data.valueIn ?? "0") - int.parse(data.valueOut ?? "0");

      String desc = "${data.menuName} (${data.menuType})";
      desc += "\n ${DateFormat("yyyy-MM-dd HH:mm:ss").format(tempDate)}";
      if (data.notes != null && data.notes != "") {
        desc += "\n ${data.notes}";
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
          var resp =
              await ReportModel().deleteTransaction(context, data.id ?? 0);
          if (resp) {
            await CreateModel().getData(context);
          }
        },
      ).show();
    }

    AppBar appBar = AppBar(
      // systemOverlayStyle: const SystemUiOverlayStyle(
      //   statusBarIconBrightness: Brightness.dark,
      //   statusBarBrightness: Brightness.light,
      // ),
      iconTheme: const IconThemeData(
        color: Colors.black, //change your color here
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: const Color(0x00000000),
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Tambah baru',
        style: TextStyle(
          color: Colors.black,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    return WillPopScope(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: appBar,
        body: Container(
          constraints: const BoxConstraints.expand(),
          color: Colors.grey.shade200,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 0,
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 12,
                    ),
                    child: Column(
                      children: [
                        Container(
                          child: Row(
                            children: [
                              Expanded(
                                child: CircleMenu(
                                  icon: iconMenus[0],
                                  iconSize: 35,
                                  name: 'Masuk',
                                  nameSize: 15,
                                  gradient: gradientMenu[0],
                                  active: globalBloc.tabMenuTransaction ==
                                      "Pemasukan",
                                  onTap: globalBloc.tabMenuTransaction !=
                                          "Pemasukan"
                                      ? () async {
                                          transactionBloc.page = 1;
                                          createBloc.page = 1;
                                          globalBloc.tabMenuTransaction =
                                              'Pemasukan';
                                          await CreateModel().getData(context);
                                        }
                                      : () {},
                                ),
                              ),
                              Expanded(
                                child: CircleMenu(
                                  icon: iconMenus[1],
                                  iconSize: 35,
                                  name: 'Keluar',
                                  nameSize: 15,
                                  gradient: gradientMenu[1],
                                  active: globalBloc.tabMenuTransaction ==
                                      "Pengeluaran",
                                  onTap: globalBloc.tabMenuTransaction !=
                                          "Pengeluaran"
                                      ? () async {
                                          transactionBloc.page = 1;
                                          createBloc.page = 1;
                                          globalBloc.tabMenuTransaction =
                                              'Pengeluaran';
                                          await CreateModel().getData(context);
                                        }
                                      : () {},
                                ),
                              ),
                              Expanded(
                                child: CircleMenu(
                                  icon: iconMenus[2],
                                  iconSize: 30,
                                  name: 'Hutang',
                                  nameSize: 15,
                                  gradient: gradientMenu[2],
                                  active:
                                      globalBloc.tabMenuTransaction == "Hutang",
                                  onTap: globalBloc.tabMenuTransaction !=
                                          "Hutang"
                                      ? () async {
                                          transactionBloc.page = 1;
                                          createBloc.page = 1;
                                          globalBloc.tabMenuTransaction =
                                              'Hutang';
                                          await CreateModel().getData(context);
                                        }
                                      : () {},
                                ),
                              ),
                              Expanded(
                                child: CircleMenu(
                                  icon: iconMenus[3],
                                  iconSize: 30,
                                  name: 'Piutang',
                                  nameSize: 15,
                                  gradient: gradientMenu[3],
                                  active: globalBloc.tabMenuTransaction ==
                                      "Piutang",
                                  onTap: globalBloc.tabMenuTransaction !=
                                          "Piutang"
                                      ? () async {
                                          transactionBloc.page = 1;
                                          createBloc.page = 1;
                                          globalBloc.tabMenuTransaction =
                                              'Piutang';
                                          await CreateModel().getData(context);
                                        }
                                      : () {},
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 12,
                      ),
                      child: CustomPaint(
                        painter: BubbleTriangle(
                          comparePathWidth: globalBloc.tabMenuTransaction ==
                                  "Pemasukan"
                              ? 8.2
                              : (globalBloc.tabMenuTransaction == "Pengeluaran"
                                  ? 2.65
                                  : (globalBloc.tabMenuTransaction == "Hutang")
                                      ? 1.6
                                      : 1.14),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            // color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.only(
                                  left: 5,
                                  right: 5,
                                  bottom: 2,
                                  top: 12,
                                ),
                                child: InkWell(
                                  splashColor: globalBloc.tabMenuTransaction ==
                                          "Pemasukan"
                                      ? Colors.greenAccent.shade400
                                      : (globalBloc.tabMenuTransaction ==
                                              "Pengeluaran"
                                          ? Colors.pink
                                          : (globalBloc.tabMenuTransaction ==
                                                  "Hutang")
                                              ? Colors.amber
                                              : Colors.blue),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType.fade,
                                        child: const CreateTransaction2Page(),
                                      ),
                                    ).then((value) async {
                                      if (value != null) {
                                        if (value == 'load') {
                                          createBloc.page = 1;
                                          transactionBloc.page = 1;
                                          await CreateModel().getData(context);
                                        }
                                      }
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          146, 255, 255, 255),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleCustom(
                                          height: 40,
                                          icon: Icons.add,
                                          iconSize: 23,
                                          gradient: globalBloc
                                                      .tabMenuTransaction ==
                                                  "Pemasukan"
                                              ? gradientMenu[0]
                                              : (globalBloc
                                                          .tabMenuTransaction ==
                                                      "Pengeluaran"
                                                  ? gradientMenu[1]
                                                  : (globalBloc
                                                              .tabMenuTransaction ==
                                                          "Hutang")
                                                      ? gradientMenu[2]
                                                      : gradientMenu[3]),
                                          active: true,
                                        ),
                                        const SizedBox(
                                          width: 12,
                                        ),
                                        Text(
                                          "${globalBloc.tabMenuTransaction} baru",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: !createBloc.loading
                                    ? Column(
                                        children: [
                                          createBloc.data.isNotEmpty
                                              ? const SizedBox(
                                                  height: 6,
                                                )
                                              : const SizedBox(),
                                          createBloc.data.isNotEmpty
                                              ? const Divider(
                                                  height: 0,
                                                )
                                              : const SizedBox(),
                                          createBloc.data.isNotEmpty
                                              ? Container(
                                                  width: double.infinity,
                                                  padding:
                                                      const EdgeInsets.only(
                                                    top: 9,
                                                    bottom: 7,
                                                  ),
                                                  color: Colors.white,
                                                  child: Center(
                                                    child: Text(
                                                      "${globalBloc.tabMenuTransaction.toUpperCase()} TERAKHIR",
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox(),
                                          const SizedBox(
                                            height: 6,
                                          ),
                                          Expanded(
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              padding: const EdgeInsets.all(0),
                                              itemCount: createBloc.data.length,
                                              itemBuilder: (context, index) {
                                                var data =
                                                    createBloc.data[index];
                                                DateTime tempDate = DateFormat(
                                                        "yyyy-MM-dd'T'HH:mm:ss.SSS")
                                                    .parse(
                                                        data.transactionDate ??
                                                            "");
                                                return Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 12,
                                                    horizontal: 18,
                                                  ),
                                                  margin: const EdgeInsets.only(
                                                      bottom: 8,
                                                      left: 12,
                                                      right: 12),
                                                  decoration: BoxDecoration(
                                                    color: activeTabColor(
                                                        data.menuType ?? "",
                                                        labelsColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: activeTabColor(
                                                            data.menuType ?? "",
                                                            chipsColor),
                                                        spreadRadius: 0,
                                                        blurRadius: 0.2,
                                                        offset: const Offset(0,
                                                            0.1), // changes position of shadow
                                                      ),
                                                    ],
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        data.menuName ?? "",
                                                        style: TextStyle(
                                                          color: activeTabColor(
                                                              data.menuType ??
                                                                  "",
                                                              reportActiveTabColor),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      data.menuNotes != null &&
                                                              data.menuNotes !=
                                                                  ""
                                                          ? Text(
                                                              data.menuNotes ??
                                                                  "",
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14,
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                      Text(
                                                        DateFormat(
                                                                "yyyy-MM-dd HH:mm:ss")
                                                            .format(tempDate),
                                                        style: const TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      data.notes != null &&
                                                              data.notes != ""
                                                          ? Text(
                                                              data.notes ?? "",
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14,
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .grey
                                                                      .withOpacity(
                                                                          0.5),
                                                                  spreadRadius:
                                                                      0,
                                                                  blurRadius:
                                                                      0.2,
                                                                  offset: const Offset(
                                                                      0,
                                                                      0.2), // changes position of shadow
                                                                ),
                                                              ],
                                                            ),
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 6,
                                                              vertical: 4,
                                                            ),
                                                            child: Text(
                                                              formatCurrency.format(int
                                                                      .parse(data
                                                                              .valueIn ??
                                                                          "0") -
                                                                  int.parse(
                                                                      data.valueOut ??
                                                                          "0")),
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black87,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ),
                                                          const Expanded(
                                                            child: SizedBox(),
                                                          ),
                                                          data.debtType != "NON"
                                                              ? Container(
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              6),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white54,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical: 4,
                                                                  ),
                                                                  child: Text(
                                                                    "${data.debtType} ${data.menuType.toString().toLowerCase()}",
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .black54,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          13,
                                                                    ),
                                                                  ),
                                                                )
                                                              : const SizedBox(),
                                                        ],
                                                      ),
                                                      const Divider(),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: SizedBox(
                                                              width: double
                                                                  .infinity,
                                                              child: InkWell(
                                                                child:
                                                                    const Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .content_paste_search,
                                                                      color: Colors
                                                                          .black87,
                                                                      size: 20,
                                                                    ),
                                                                    SizedBox(
                                                                      width: 4,
                                                                    ),
                                                                    Text(
                                                                      "Detail",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                onTap: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    PageTransition(
                                                                      type: PageTransitionType
                                                                          .bottomToTop,
                                                                      child:
                                                                          ReportMenuDetailPage(
                                                                        menuId:
                                                                            data.menuId ??
                                                                                0,
                                                                        type: data.menuType ??
                                                                            "",
                                                                      ),
                                                                    ),
                                                                  ).then(
                                                                      (value) async {
                                                                    if (value !=
                                                                        null) {
                                                                      if (value ==
                                                                          'load') {
                                                                        createBloc
                                                                            .page = 1;
                                                                        await CreateModel()
                                                                            .getData(context);
                                                                      }
                                                                    }
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                          data.allowDelete ==
                                                                  "1"
                                                              ? Expanded(
                                                                  child:
                                                                      SizedBox(
                                                                    width: double
                                                                        .infinity,
                                                                    child:
                                                                        InkWell(
                                                                      child:
                                                                          const Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Icon(
                                                                            Icons.delete,
                                                                            color:
                                                                                Colors.red,
                                                                            size:
                                                                                20,
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                4,
                                                                          ),
                                                                          Text(
                                                                            "Hapus",
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 13,
                                                                              color: Colors.red,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      onTap:
                                                                          () async {
                                                                        await onDeleteMenu(
                                                                            data);
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
                                          createBloc.totalPage > 1
                                              ? Pagination(
                                                  totalPage:
                                                      createBloc.totalPage,
                                                  page: createBloc.page,
                                                  height: 10,
                                                  onTap: (page) async {
                                                    createBloc.page = page;
                                                    await CreateModel()
                                                        .getData(context);
                                                  },
                                                )
                                              : const SizedBox(),
                                        ],
                                      )
                                    : Center(
                                        child: SpinKitDoubleBounce(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      onWillPop: () {
        Navigator.pop(context, 'load');
        return Future.value(false);
      },
    );
  }
}
