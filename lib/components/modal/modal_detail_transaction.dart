import 'package:keuangan/components/circle_custom.dart';
import 'package:keuangan/components/models/cart_model.dart';
import 'package:keuangan/helpers/set_menus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:keuangan/pages/transaction/create2_model.dart';
import 'package:provider/provider.dart';

import '../../providers/global_bloc.dart';

class DetailTransactionModal extends StatefulWidget {
  const DetailTransactionModal({super.key});

  @override
  State<DetailTransactionModal> createState() => DetailTransactionModalState();
}

class DetailTransactionModalState extends State<DetailTransactionModal> {
  final formatCurrency = NumberFormat.simpleCurrency(
    locale: 'id_ID',
    decimalDigits: 0,
  );

  Map<dynamic, List<dynamic>> datas = {};

  @override
  void initState() {
    super.initState();
    setState(() {
      datas = {};
    });
  }

  Widget getListData(BuildContext context, AsyncSnapshot snapshot) {
    final globalBloc = context.read<GlobalBloc>();
    print(snapshot.data);
    datas = groupBy(snapshot.data, (dynamic obj) => obj['type']);
    return ListView.builder(
      shrinkWrap: true,
      itemCount: datas.length,
      itemBuilder: (context, index) {
        String key = datas.keys.elementAt(index).toString();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(
                  right: 8,
                  top: 4,
                ),
                child: CircleCustom(
                  height: 12,
                  gradient: key == "Pemasukan"
                      ? gradientActiveDMenu[0]
                      : (key == "Pengeluaran"
                          ? gradientActiveDMenu[1]
                          : (key == "Hutang")
                              ? gradientActiveDMenu[2]
                              : gradientActiveDMenu[3]),
                  active: true,
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    gradient: key == "Pemasukan"
                        ? gradientActiveDMenu[0]
                        : (key == "Pengeluaran"
                            ? gradientActiveDMenu[1]
                            : (key == "Hutang")
                                ? gradientActiveDMenu[2]
                                : gradientActiveDMenu[3]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    padding: const EdgeInsets.only(
                      top: 8,
                      bottom: 2,
                      left: 12,
                      right: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: key == "Pemasukan"
                          ? gradient2[0]
                          : (key == "Pengeluaran"
                              ? gradient2[1]
                              : (key == "Hutang")
                                  ? gradient2[2]
                                  : gradient2[3]),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: datas[key]!.map((dynamic e) {
                        var menuDetail = e["menuDetail"];
                        int nominal = int.parse(e["in"]) - int.parse(e["out"]);
                        DateTime tempDate =
                            DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS")
                                .parse(e["tgl"]);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      menuDetail["keu_menu_name"],
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    menuDetail["keu_menu_notes"] != null &&
                                            menuDetail["keu_menu_notes"] != ""
                                        ? Text(
                                            menuDetail["keu_menu_notes"],
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          )
                                        : const SizedBox(),
                                    Text(
                                      DateFormat("yyyy-MM-dd hh:mm:ss")
                                          .format(tempDate),
                                      style: const TextStyle(
                                        fontSize: 13,
                                      ),
                                    ),
                                    e["notes"] != null
                                        ? Text(
                                            e["notes"],
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  e["debtType"] != ""
                                      ? Text(
                                          e["debtType"] +
                                              " " +
                                              key.toString().toLowerCase(),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black54,
                                          ),
                                        )
                                      : const SizedBox(),
                                  Text(
                                    formatCurrency.format(nominal),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 25,
                                child: IconButton(
                                  onPressed: () async {
                                    setState(() async {
                                      globalBloc.cart.remove(e);
                                      datas[key]!.remove(e);
                                      if (globalBloc.cart.isEmpty) {
                                        globalBloc.loading = false;
                                        Navigator.pop(context);
                                      } else {
                                        await CreateModel2().getMenu(context);
                                      }
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.remove_circle,
                                    color: Colors.red,
                                  ),
                                  iconSize: 18,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    // return Column(children: list);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(10),
      child: SafeArea(
        child: Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32.0),
          ),
          child: StreamBuilder(
            stream: CreateModel2().getCartStream(context),
            builder: (context, AsyncSnapshot snapshot) {
              int totalNominal = 0;
              List<CartModel> sdata = snapshot.data ?? [];
              if (snapshot.connectionState == ConnectionState.done) {
                for (var i = 0; i < sdata.length; i++) {
                  totalNominal += (int.parse(sdata[i].gin ?? "0") -
                      int.parse(sdata[i].gout ?? "0"));
                }
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: 6,
                    ),
                    child: Column(
                      children: <Widget>[
                        const Text(
                          "TOTAL",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          formatCurrency.format(totalNominal),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Flexible(
                    child: SingleChildScrollView(
                      child: getListData(context, snapshot),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "TUTUP",
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
