import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:keuangan/components/bubble_triangle.dart';
import 'package:keuangan/components/circle_custom.dart';
import 'package:keuangan/components/circle_menu.dart';
import 'package:keuangan/components/pagination.dart';
import 'package:keuangan/helpers/set_menus.dart';
import 'package:keuangan/pages/transaction/create_model.dart';
import 'package:keuangan/pages/transaction/create2_page.dart';
import 'package:keuangan/providers/create_bloc.dart';
import 'package:keuangan/providers/global_bloc.dart';
import 'package:keuangan/providers/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../report/detail/report_menu_detail_page.dart';
import '../report/report_model.dart';

class CreateTransactionPage extends StatefulWidget {
  const CreateTransactionPage({Key? key}) : super(key: key);

  @override
  State<CreateTransactionPage> createState() => _CreateTransactionPageState();
}

class _CreateTransactionPageState extends State<CreateTransactionPage> {
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
    final _globalBloc = context.watch<GlobalBloc>();
    final _createBloc = context.watch<CreateBloc>();
    final _transactionBloc = context.watch<TransactionBloc>();

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
        dialogType: DialogType.WARNING,
        headerAnimationLoop: false,
        animType: AnimType.BOTTOMSLIDE,
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
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 12,
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: CircleMenu(
                                  icon: iconMenus[0],
                                  iconSize: 35,
                                  name: 'Masuk',
                                  nameSize: 15,
                                  gradient: gradientMenu[0],
                                  active: _globalBloc.tabMenuTransaction ==
                                      "Pemasukan",
                                  onTap: _globalBloc.tabMenuTransaction !=
                                          "Pemasukan"
                                      ? () async {
                                          _transactionBloc.page = 1;
                                          _createBloc.page = 1;
                                          _globalBloc.tabMenuTransaction =
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
                                  active: _globalBloc.tabMenuTransaction ==
                                      "Pengeluaran",
                                  onTap: _globalBloc.tabMenuTransaction !=
                                          "Pengeluaran"
                                      ? () async {
                                          _transactionBloc.page = 1;
                                          _createBloc.page = 1;
                                          _globalBloc.tabMenuTransaction =
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
                                  active: _globalBloc.tabMenuTransaction ==
                                      "Hutang",
                                  onTap: _globalBloc.tabMenuTransaction !=
                                          "Hutang"
                                      ? () async {
                                          _transactionBloc.page = 1;
                                          _createBloc.page = 1;
                                          _globalBloc.tabMenuTransaction =
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
                                  active: _globalBloc.tabMenuTransaction ==
                                      "Piutang",
                                  onTap: _globalBloc.tabMenuTransaction !=
                                          "Piutang"
                                      ? () async {
                                          _transactionBloc.page = 1;
                                          _createBloc.page = 1;
                                          _globalBloc.tabMenuTransaction =
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
                          comparePathWidth: _globalBloc.tabMenuTransaction ==
                                  "Pemasukan"
                              ? 8.2
                              : (_globalBloc.tabMenuTransaction == "Pengeluaran"
                                  ? 2.65
                                  : (_globalBloc.tabMenuTransaction == "Hutang")
                                      ? 1.6
                                      : 1.14),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            // color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.only(
                                  left: 5,
                                  right: 5,
                                  bottom: 2,
                                  top: 12,
                                ),
                                child: InkWell(
                                  splashColor: _globalBloc.tabMenuTransaction ==
                                          "Pemasukan"
                                      ? Colors.greenAccent.shade400
                                      : (_globalBloc.tabMenuTransaction ==
                                              "Pengeluaran"
                                          ? Colors.pink
                                          : (_globalBloc.tabMenuTransaction ==
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
                                          _createBloc.page = 1;
                                          _transactionBloc.page = 1;
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
                                      children: <Widget>[
                                        CircleCustom(
                                          height: 40,
                                          icon: Icons.add,
                                          iconSize: 23,
                                          gradient: _globalBloc
                                                      .tabMenuTransaction ==
                                                  "Pemasukan"
                                              ? gradientMenu[0]
                                              : (_globalBloc
                                                          .tabMenuTransaction ==
                                                      "Pengeluaran"
                                                  ? gradientMenu[1]
                                                  : (_globalBloc
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
                                          "Tambahkan ${_globalBloc.tabMenuTransaction}",
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: !_createBloc.loading
                                    ? Container(
                                        child: Column(
                                          children: [
                                            _createBloc.data.length > 0
                                                ? const SizedBox(
                                                    height: 6,
                                                  )
                                                : const SizedBox(),
                                            _createBloc.data.length > 0
                                                ? const Divider(
                                                    height: 0,
                                                  )
                                                : const SizedBox(),
                                            _createBloc.data.length > 0
                                                ? Container(
                                                    width: double.infinity,
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 7),
                                                    color: Colors.grey.shade50,
                                                    child: Center(
                                                      child: Text(
                                                        "Riwayat ${_globalBloc.tabMenuTransaction.toLowerCase()}",
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                                padding:
                                                    const EdgeInsets.all(0),
                                                itemCount:
                                                    _createBloc.data.length,
                                                itemBuilder: (context, index) {
                                                  var data =
                                                      _createBloc.data[index];
                                                  DateTime tempDate = DateFormat(
                                                          "yyyy-MM-dd'T'HH:mm:ss.SSS")
                                                      .parse(data[
                                                          "keu_transaction_transaction_date"]);
                                                  return Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      vertical: 12,
                                                      horizontal: 18,
                                                    ),
                                                    margin:
                                                        const EdgeInsets.only(
                                                            bottom: 8,
                                                            left: 12,
                                                            right: 12),
                                                    decoration: BoxDecoration(
                                                      color: activeTabColor(
                                                          data["menus_type"],
                                                          labelsColor),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: activeTabColor(
                                                              data[
                                                                  "menus_type"],
                                                              chipsColor),
                                                          spreadRadius: 0,
                                                          blurRadius: 0.2,
                                                          offset: const Offset(
                                                              0,
                                                              0.1), // changes position of shadow
                                                        ),
                                                      ],
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Text(
                                                          data["menus_name"],
                                                          style: TextStyle(
                                                            color: activeTabColor(
                                                                data[
                                                                    "menus_type"],
                                                                reportActiveTabColor),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                        data["menus_notes"] !=
                                                                    null &&
                                                                data["menus_notes"] !=
                                                                    ""
                                                            ? Text(
                                                                data[
                                                                    "menus_notes"],
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
                                                          style:
                                                              const TextStyle(
                                                            color:
                                                                Colors.black87,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        data["keu_transaction_notes"] !=
                                                                    null &&
                                                                data["keu_transaction_notes"] !=
                                                                    ""
                                                            ? Text(
                                                                data[
                                                                    "keu_transaction_notes"],
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
                                                          children: <Widget>[
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .white,
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
                                                                formatCurrency
                                                                    .format(data[
                                                                            "keu_transaction_value_in"] -
                                                                        data[
                                                                            "keu_transaction_value_out"]),
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
                                                            data["keu_transaction_debtType"] !=
                                                                    "NON"
                                                                ? Container(
                                                                    margin: const EdgeInsets
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
                                                                      vertical:
                                                                          4,
                                                                    ),
                                                                    child: Text(
                                                                      data["keu_transaction_debtType"] +
                                                                          " " +
                                                                          data["menus_type"]
                                                                              .toString()
                                                                              .toLowerCase(),
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .black54,
                                                                        fontWeight:
                                                                            FontWeight.bold,
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
                                                          children: <Widget>[
                                                            Expanded(
                                                              child: Container(
                                                                width: double
                                                                    .infinity,
                                                                child: InkWell(
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: const <Widget>[
                                                                      Icon(
                                                                        Icons
                                                                            .content_paste_search,
                                                                        color: Colors
                                                                            .black87,
                                                                        size:
                                                                            20,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            4,
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
                                                                              data["menus_id"],
                                                                          type:
                                                                              data["menus_type"],
                                                                        ),
                                                                      ),
                                                                    ).then(
                                                                        (value) async {
                                                                      if (value !=
                                                                          null) {
                                                                        if (value ==
                                                                            'load') {
                                                                          _createBloc.page =
                                                                              1;
                                                                          await CreateModel()
                                                                              .getData(context);
                                                                        }
                                                                      }
                                                                    });
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                            data["keu_transaction_allow_delete"] ==
                                                                    1
                                                                ? Expanded(
                                                                    child:
                                                                        Container(
                                                                      width: double
                                                                          .infinity,
                                                                      child:
                                                                          InkWell(
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: const <Widget>[
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
                                            _createBloc.totalPage > 1
                                                ? Container(
                                                    child: Pagination(
                                                      totalPage:
                                                          _createBloc.totalPage,
                                                      page: _createBloc.page,
                                                      height: 10,
                                                      onTap: (page) async {
                                                        _createBloc.page = page;
                                                        await CreateModel()
                                                            .getData(context);
                                                      },
                                                    ),
                                                  )
                                                : const SizedBox(),
                                          ],
                                        ),
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
