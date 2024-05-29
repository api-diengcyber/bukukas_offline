import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:keuangan/components/circle_custom.dart';
import 'package:keuangan/components/models/cart_model.dart';
import 'package:keuangan/components/modal/modal_detail_transaction.dart';
import 'package:keuangan/components/modal/modal_create_menu.dart';
import 'package:keuangan/components/modal/modal_create_transaction.dart';
import 'package:keuangan/components/pagination.dart';
import 'package:keuangan/db/model/tb_menu_model.dart';
import 'package:keuangan/helpers/set_menus.dart';
import 'package:keuangan/pages/transaction/create2_model.dart';
import 'package:keuangan/providers/global_bloc.dart';
import 'package:keuangan/providers/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:keuangan/utils/currency.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class CreateTransaction2Page extends StatefulWidget {
  const CreateTransaction2Page({super.key});

  @override
  State<CreateTransaction2Page> createState() => _CreateTransaction2PageState();
}

class _CreateTransaction2PageState extends State<CreateTransaction2Page> {
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
      CreateModel2().init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final globalBloc = context.watch<GlobalBloc>();
    final transactionBloc = context.watch<TransactionBloc>();

    openDialogMenu() {
      globalBloc.loading = false;
      showDialog(
        context: context,
        barrierColor: const Color.fromARGB(26, 0, 0, 0),
        builder: (BuildContext context) => CreateMenuModal(
          type: globalBloc.tabMenuTransaction,
          gradient: globalBloc.tabMenuTransaction == "Pemasukan"
              ? modalGradientMenu[0]
              : (globalBloc.tabMenuTransaction == "Pengeluaran"
                  ? modalGradientMenu[1]
                  : (globalBloc.tabMenuTransaction == "Hutang")
                      ? modalGradientMenu[2]
                      : modalGradientMenu[3]),
          onSuccess: () async {
            await CreateModel2().getMenu(context);
          },
        ),
      );
    }

    openDialogTransaction(TbMenuModel data) {
      globalBloc.loading = false;
      globalBloc.debtType = "Bayar";
      showDialog(
        context: context,
        barrierColor: const Color.fromARGB(224, 210, 210, 210),
        builder: (BuildContext context) => CreateTransactionModal(
          data: data,
        ),
      ).then((value) {
        if (value != null) {
          if (value == 'success') {
            Navigator.pop(context, 'load');
          }
        }
      });
    }

    openDialogDetailTransaction() {
      globalBloc.loading = false;
      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        builder: (BuildContext context) => const DetailTransactionModal(),
        // animationType: DialogTransitionType.slideFromTopFade,
        // curve: Curves.fastOutSlowIn,
        // duration: const Duration(milliseconds: 200),
      );
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
      title: Text(
        'Tambah ${globalBloc.tabMenuTransaction.toLowerCase()}',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    return WillPopScope(
      onWillPop: () async {
        if (globalBloc.cart.isNotEmpty) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.warning,
            animType: AnimType.topSlide,
            headerAnimationLoop: true,
            title: 'Tidak bisa kembali',
            desc: 'Masih ada data yang harus diselesaikan...',
          ).show();
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: appBar,
        body: Container(
          constraints: const BoxConstraints.expand(),
          color: Colors.grey.shade200,
          child: SafeArea(
            child: !transactionBloc.loading
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 0,
                    ),
                    child: Column(
                      children: <Widget>[
                        StreamBuilder(
                          stream: CreateModel2().getCartStream(context),
                          builder: (context, AsyncSnapshot snapshot) {
                            int totalIn = 0;
                            int totalOut = 0;
                            int totalNominal = 0;
                            List<CartModel> sdata = snapshot.data ?? [];
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              for (var i = 0; i < sdata.length; i++) {
                                totalIn += int.parse(sdata[i].gin ?? "0");
                                totalOut += int.parse(sdata[i].gout ?? "0");
                                totalNominal +=
                                    (int.parse(sdata[i].gin ?? "0") -
                                        int.parse(sdata[i].gout ?? "0"));
                              }
                              totalIn = totalIn;
                              totalOut = totalOut;
                              totalNominal = totalNominal;
                              trendIndexPemasukan = sdata
                                  .indexWhere((f) => f.type == "Pemasukan");
                              trendIndexPengeluaran = sdata
                                  .indexWhere((f) => f.type == "Pengeluaran");
                              trendIndexHutang =
                                  sdata.indexWhere((f) => f.type == "Hutang");
                              trendIndexPiutang =
                                  sdata.indexWhere((f) => f.type == "Piutang");
                            }

                            return (totalIn > 0 || totalOut > 0)
                                ? Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(
                                      left: 12,
                                      right: 12,
                                      bottom: 4,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            simpleFormatCurrency
                                                .format(totalNominal),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                            ),
                                          ),
                                        ),
                                        globalBloc.cart.isNotEmpty
                                            ? Container(
                                                margin: const EdgeInsets.only(
                                                    right: 8),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.5),
                                                        spreadRadius: 1,
                                                        blurRadius: 3,
                                                        offset: const Offset(0,
                                                            3), // changes position of shadow
                                                      ),
                                                    ],
                                                  ),
                                                  padding:
                                                      const EdgeInsets.only(
                                                    left: 8,
                                                    right: 4,
                                                    top: 5,
                                                    bottom: 5,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      trendIndexPemasukan > -1
                                                          ? Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right: 4),
                                                              child:
                                                                  CircleCustom(
                                                                height: 7,
                                                                gradient:
                                                                    gradientActiveDMenu[
                                                                        0],
                                                                active: true,
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                      trendIndexPengeluaran > -1
                                                          ? Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right: 4),
                                                              child:
                                                                  CircleCustom(
                                                                height: 7,
                                                                gradient:
                                                                    gradientActiveDMenu[
                                                                        1],
                                                                active: true,
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                      trendIndexHutang > -1
                                                          ? Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right: 4),
                                                              child:
                                                                  CircleCustom(
                                                                height: 7,
                                                                gradient:
                                                                    gradientActiveDMenu[
                                                                        2],
                                                                active: true,
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                      trendIndexPiutang > -1
                                                          ? Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right: 4),
                                                              child:
                                                                  CircleCustom(
                                                                height: 7,
                                                                gradient:
                                                                    gradientActiveDMenu[
                                                                        3],
                                                                active: true,
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : const SizedBox(),
                                        globalBloc.cart.isNotEmpty
                                            ? InkWell(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.5),
                                                        spreadRadius: 1,
                                                        blurRadius: 3,
                                                        offset: const Offset(0,
                                                            3), // changes position of shadow
                                                      ),
                                                    ],
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 5,
                                                  ),
                                                  child: const Icon(
                                                    Icons.arrow_downward,
                                                    size: 15,
                                                  ),
                                                ),
                                                onTap: () {
                                                  openDialogDetailTransaction();
                                                },
                                              )
                                            : const SizedBox(),
                                      ],
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 10,
                                    ),
                                    margin: const EdgeInsets.only(
                                      bottom: 6,
                                      left: 12,
                                      right: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(20),
                                      ),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 0,
                                          blurRadius: 0.2,
                                          offset: const Offset(0,
                                              0.1), // changes position of shadow
                                        ),
                                      ],
                                      // image: DecorationImage(
                                      //   image:
                                      //       AssetImage("assets/images/lead.png"),
                                      //   fit: BoxFit.cover,
                                      // ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Silahkan pilih menu",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                          },
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
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: globalBloc.menus.isNotEmpty
                                  ? Container(
                                      decoration: BoxDecoration(
                                        // color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Column(
                                        children: <Widget>[
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                left: 15,
                                                right: 15,
                                                bottom: 2,
                                                top: 20,
                                              ),
                                              child: globalBloc.loadingMenus
                                                  ? const Center(
                                                      child: Text("Memuat...."),
                                                    )
                                                  : ListView.builder(
                                                      itemCount: globalBloc
                                                          .menus.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 8),
                                                          child: Material(
                                                            color: Colors
                                                                .grey.shade300,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                            child: InkWell(
                                                              splashColor: globalBloc
                                                                          .tabMenuTransaction ==
                                                                      "Pemasukan"
                                                                  ? Colors
                                                                      .greenAccent
                                                                      .shade400
                                                                  : (globalBloc
                                                                              .tabMenuTransaction ==
                                                                          "Pengeluaran"
                                                                      ? Colors
                                                                          .pink
                                                                      : (globalBloc.tabMenuTransaction ==
                                                                              "Hutang")
                                                                          ? Colors
                                                                              .amber
                                                                          : Colors
                                                                              .blue),
                                                              onTap: () {
                                                                openDialogTransaction(
                                                                    globalBloc
                                                                            .menus[
                                                                        index]);
                                                              },
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                              child: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  vertical: 10,
                                                                  horizontal:
                                                                      20,
                                                                ),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: const Color
                                                                      .fromARGB(
                                                                      146,
                                                                      255,
                                                                      255,
                                                                      255),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                ),
                                                                child: Row(
                                                                  children: <Widget>[
                                                                    CircleCustom(
                                                                      height:
                                                                          40,
                                                                      icon: globalBloc.tabMenuTransaction ==
                                                                              "Pemasukan"
                                                                          ? iconMenus[
                                                                              0]
                                                                          : (globalBloc.tabMenuTransaction == "Pengeluaran"
                                                                              ? iconMenus[1]
                                                                              : (globalBloc.tabMenuTransaction == "Hutang")
                                                                                  ? iconMenus[2]
                                                                                  : iconMenus[3]),
                                                                      iconSize:
                                                                          23,
                                                                      gradient: globalBloc.tabMenuTransaction ==
                                                                              "Pemasukan"
                                                                          ? gradientMenu[
                                                                              0]
                                                                          : (globalBloc.tabMenuTransaction == "Pengeluaran"
                                                                              ? gradientMenu[1]
                                                                              : (globalBloc.tabMenuTransaction == "Hutang")
                                                                                  ? gradientMenu[2]
                                                                                  : gradientMenu[3]),
                                                                      active:
                                                                          true,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 12,
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: <Widget>[
                                                                        Text(
                                                                          globalBloc.menus[index].name ??
                                                                              "",
                                                                          style:
                                                                              const TextStyle(fontSize: 17),
                                                                        ),
                                                                        globalBloc.menus[index].notes !=
                                                                                ""
                                                                            ? Text(
                                                                                globalBloc.menus[index].notes ?? "",
                                                                                style: const TextStyle(
                                                                                  color: Colors.black54,
                                                                                  fontSize: 14,
                                                                                ),
                                                                              )
                                                                            : const SizedBox(),
                                                                        globalBloc.menus[index].defaultValue != "" &&
                                                                                globalBloc.menus[index].defaultValue != null &&
                                                                                int.parse(globalBloc.menus[index].defaultValue ?? "0") > 0
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
                                                                                  color: globalBloc.menus[index].type == "Pemasukan"
                                                                                      ? Colors.green.shade100
                                                                                      : (globalBloc.menus[index].type == "Pengeluaran"
                                                                                          ? Colors.pink.shade100
                                                                                          : (globalBloc.menus[index].type == "Hutang")
                                                                                              ? Colors.amber.shade100
                                                                                              : Colors.blue.shade100),
                                                                                ),
                                                                                child: Text(
                                                                                  formatter.formatString(globalBloc.menus[index].defaultValue.toString()),
                                                                                  style: const TextStyle(
                                                                                    color: Colors.black87,
                                                                                    fontSize: 14,
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            : const SizedBox(),
                                                                        (globalBloc.tabMenuTransaction == "Hutang" || globalBloc.tabMenuTransaction == "Piutang") &&
                                                                                int.parse(globalBloc.menus[index].total ?? "0") > 0
                                                                            ? Row(
                                                                                children: <Widget>[
                                                                                  Container(
                                                                                    margin: const EdgeInsets.only(top: 5),
                                                                                    decoration: BoxDecoration(
                                                                                      color: Colors.white,
                                                                                      borderRadius: BorderRadius.circular(6),
                                                                                      boxShadow: [
                                                                                        BoxShadow(
                                                                                          color: Colors.grey.withOpacity(0.5),
                                                                                          spreadRadius: 0,
                                                                                          blurRadius: 2,
                                                                                          offset: const Offset(0, 2), // changes position of shadow
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    padding: const EdgeInsets.symmetric(
                                                                                      horizontal: 5,
                                                                                      vertical: 4,
                                                                                    ),
                                                                                    child: Text(
                                                                                      simpleFormatCurrency.format(globalBloc.menus[index].total),
                                                                                      style: TextStyle(
                                                                                        letterSpacing: 0.5,
                                                                                        fontSize: 13,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        color: globalBloc.tabMenuTransaction == "Hutang"
                                                                                            ? Colors.amber.shade800
                                                                                            : globalBloc.tabMenuTransaction == "Piutang"
                                                                                                ? Colors.blue.shade800
                                                                                                : Colors.black54,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              )
                                                                            : const SizedBox(),
                                                                      ],
                                                                    ),
                                                                    const Expanded(
                                                                        child:
                                                                            SizedBox()),
                                                                    Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                            color:
                                                                                Colors.grey.withOpacity(0.5),
                                                                            spreadRadius:
                                                                                1,
                                                                            blurRadius:
                                                                                3,
                                                                            offset:
                                                                                const Offset(0, 3), // changes position of shadow
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .symmetric(
                                                                        horizontal:
                                                                            12,
                                                                        vertical:
                                                                            6,
                                                                      ),
                                                                      child: const Text(
                                                                          "Pilih"),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                            ),
                                          ),
                                          Container(
                                            child: !globalBloc.loadingMenus
                                                ? transactionBloc.totalPages > 1
                                                    ? Pagination(
                                                        totalPage:
                                                            transactionBloc
                                                                .totalPages,
                                                        page: transactionBloc
                                                            .page,
                                                        height: 10,
                                                        onTap: (page) async {
                                                          transactionBloc.page =
                                                              page;
                                                          await CreateModel2()
                                                              .getMenu(context);
                                                        },
                                                      )
                                                    : const SizedBox()
                                                : const SizedBox(),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        // color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: globalBloc.loadingMenus
                                          ? const Center(
                                              child: Text("Memuat...."),
                                            )
                                          : Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  ClipOval(
                                                    child: Material(
                                                      shape: const CircleBorder(
                                                        side: BorderSide(
                                                          color: Color.fromARGB(
                                                              95,
                                                              167,
                                                              167,
                                                              167),
                                                          width: 6,
                                                        ),
                                                      ),
                                                      color: Colors
                                                          .white, // Button color
                                                      child: InkWell(
                                                        splashColor: globalBloc
                                                                    .tabMenuTransaction ==
                                                                "Hutang"
                                                            ? Colors.amber
                                                            : globalBloc.tabMenuTransaction ==
                                                                    "Piutang"
                                                                ? Colors.blue
                                                                : Colors
                                                                    .black54, // Splash color
                                                        onTap: () {
                                                          openDialogMenu();
                                                        },
                                                        child: const SizedBox(
                                                          width: 64,
                                                          height: 64,
                                                          child: Icon(
                                                            Icons.add,
                                                            size: 30,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 12,
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      openDialogMenu();
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: globalBloc
                                                                    .tabMenuTransaction ==
                                                                "Pemasukan"
                                                            ? Colors
                                                                .green.shade600
                                                            : globalBloc.tabMenuTransaction ==
                                                                    "Pengeluaran"
                                                                ? Colors.pink
                                                                    .shade600
                                                                : globalBloc.tabMenuTransaction ==
                                                                        "Hutang"
                                                                    ? Colors
                                                                        .amber
                                                                        .shade600
                                                                    : globalBloc.tabMenuTransaction ==
                                                                            "Piutang"
                                                                        ? Colors
                                                                            .blue
                                                                        : Colors
                                                                            .black54,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.5),
                                                            spreadRadius: 1,
                                                            blurRadius: 3,
                                                            offset: const Offset(
                                                                0,
                                                                3), // changes position of shadow
                                                          ),
                                                        ],
                                                      ),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 12,
                                                        vertical: 6,
                                                      ),
                                                      child: const Text(
                                                        "Buat baru",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          letterSpacing: 0.5,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                            top: 5,
                            bottom: 7,
                            left: 12,
                            right: 12,
                          ),
                          child: InkWell(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(
                                        0, 0.6), // changes position of shadow
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.add,
                                    size: 22,
                                    color: Colors.black54,
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  Text(
                                    "Tambah menu ${globalBloc.tabMenuTransaction.toLowerCase()}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              openDialogMenu();
                            },
                          ),
                        ),
                        StreamBuilder(
                          stream: CreateModel2().getCartStream(context),
                          builder: (context, AsyncSnapshot snapshot) {
                            bool showSelesai = false;
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.data.length > 0) {
                                showSelesai = true;
                              }
                              showSelesai = showSelesai;
                            }
                            return showSelesai
                                ? Container(
                                    margin: const EdgeInsets.only(
                                      left: 12,
                                      right: 12,
                                    ),
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundBuilder: (context, s, x) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            gradient: globalBloc
                                                        .tabMenuTransaction ==
                                                    "Pemasukan"
                                                ? modalGradientMenu[0]
                                                : (globalBloc
                                                            .tabMenuTransaction ==
                                                        "Pengeluaran"
                                                    ? modalGradientMenu[1]
                                                    : (globalBloc
                                                                .tabMenuTransaction ==
                                                            "Hutang")
                                                        ? modalGradientMenu[2]
                                                        : modalGradientMenu[3]),
                                          ),
                                          child: x,
                                        );
                                      }),
                                      onPressed: () async {
                                        await Future.delayed(
                                            const Duration(milliseconds: 400),
                                            () async {
                                          await CreateModel2()
                                              .saveTransaction(context);
                                          // _key.currentState!.reset();
                                        });
                                      },
                                      child: const Text(
                                        "Simpan",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox();
                          },
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                      ],
                    ),
                  )
                : const Center(
                    child: SpinKitDoubleBounce(
                      color: Colors.grey,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
