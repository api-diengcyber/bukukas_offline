import 'package:get/get.dart';
import 'package:keuangan/components/circle_custom.dart';
import 'package:keuangan/helpers/set_menus.dart';
import 'package:flutter/material.dart';
import 'package:keuangan/pages/dashboard/dashboard_controller.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class PanelTransaction extends StatefulWidget {
  const PanelTransaction({Key? key}) : super(key: key);

  @override
  State<PanelTransaction> createState() => _PanelTransactionState();
}

class _PanelTransactionState extends State<PanelTransaction> {
  final formatCurrency = NumberFormat.simpleCurrency(
    locale: 'id_ID',
    decimalDigits: 0,
  );
  late DashboardController dashboardController;

  @override
  void initState() {
    Get.lazyPut(() => DashboardController());
    dashboardController = Get.find<DashboardController>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
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
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            child: const Text(
              "Transaksi Terbaru",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              bottom: 5,
              left: 12,
              right: 12,
            ),
            child: !dashboardController.loading
                ? (dashboardController.dataDashboard["dataTransaction"] ?? "")
                            .length >
                        0
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: (dashboardController
                                    .dataDashboard["dataTransaction"] ??
                                "")
                            .length,
                        padding: const EdgeInsets.all(0),
                        itemBuilder: (context, index) {
                          dynamic data = dashboardController
                              .dataDashboard["dataTransaction"][index];
                          DateTime tempDate =
                              DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").parse(
                                  data["keu_transaction_transaction_date"]);

                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            margin: const EdgeInsets.only(
                              bottom: 8,
                            ),
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(178, 235, 235, 235),
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  child: CircleCustom(
                                    height: 10,
                                    gradient: data["menuType"] == "Pemasukan"
                                        ? gradientActiveDMenu[0]
                                        : (data["menuType"] == "Pengeluaran"
                                            ? gradientActiveDMenu[1]
                                            : (data["menuType"] == "Hutang")
                                                ? gradientActiveDMenu[2]
                                                : gradientActiveDMenu[3]),
                                    active: true,
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        data["menuName"],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                          fontSize: 15,
                                        ),
                                      ),
                                      data["menuNotes"] != null &&
                                              data["menuNotes"] != ""
                                          ? Text(
                                              data["menuNotes"],
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 14,
                                              ),
                                            )
                                          : const SizedBox(),
                                      data["keu_transaction_created_on"] !=
                                                  null &&
                                              data["keu_transaction_created_on"] !=
                                                  ""
                                          ? Text(
                                              DateFormat("yyyy-MM-dd HH:mm:ss")
                                                  .format(tempDate),
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 14,
                                              ),
                                            )
                                          : const SizedBox(),
                                      data["keu_transaction_notes"] != null &&
                                              data["keu_transaction_notes"] !=
                                                  ""
                                          ? Text(
                                              data["keu_transaction_notes"],
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 14,
                                              ),
                                            )
                                          : const SizedBox(),
                                      Row(
                                        children: <Widget>[
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  spreadRadius: 0,
                                                  blurRadius: 0.2,
                                                  offset: const Offset(0,
                                                      0.2), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 4,
                                            ),
                                            child: Text(
                                              formatCurrency.format(data[
                                                      "keu_transaction_value_in"] -
                                                  data[
                                                      "keu_transaction_value_out"]),
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.bold,
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
                                                  margin: const EdgeInsets.only(
                                                      left: 6),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white54,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 12,
                                                    vertical: 4,
                                                  ),
                                                  child: Text(
                                                    data["keu_transaction_debtType"] +
                                                        " " +
                                                        data["menuType"]
                                                            .toString()
                                                            .toLowerCase(),
                                                    style: const TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox(),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 26),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const <Widget>[
                              Icon(
                                Icons.list_alt,
                                color: Colors.grey,
                                size: 40,
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                "Transaksi kosong",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                : const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 26),
                      child: Text(
                        "Memuat...",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
