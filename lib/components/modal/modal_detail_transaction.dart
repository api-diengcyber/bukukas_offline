import 'package:collection/collection.dart';
import 'package:keuangan/components/circle_custom.dart';
import 'package:keuangan/components/models/cart_model.dart';
import 'package:keuangan/helpers/set_menus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keuangan/pages/transaction/create2_model.dart';
import 'package:keuangan/utils/currency.dart';
import 'package:provider/provider.dart';

import '../../providers/global_bloc.dart';

class DetailTransactionModal extends StatefulWidget {
  const DetailTransactionModal({super.key});

  @override
  State<DetailTransactionModal> createState() => DetailTransactionModalState();
}

class DetailTransactionModalState extends State<DetailTransactionModal> {
  Map<dynamic, List<CartModel>> datas = {};

  @override
  void initState() {
    super.initState();
    setState(() {
      datas = {};
    });
  }

  Widget getListData(BuildContext context, List<CartModel> dataCart) {
    // final globalBloc = context.read<GlobalBloc>(); // Tidak digunakan, bisa dihapus
    datas = groupBy(dataCart, (CartModel obj) => obj.type);
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Agar scroll smooth di dalam modal
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
                    borderRadius: BorderRadius.circular(19),
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
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: datas[key]!.map((CartModel e) {
                        var menuDetail = e.menuDetail;
                        
                        // --- PERBAIKAN 1: Gunakan int.tryParse agar aman ---
                        int nominal = (int.tryParse(e.gin ?? "0") ?? 0) - 
                                      (int.tryParse(e.gout ?? "0") ?? 0);
                        
                        // --- PERBAIKAN 2: Gunakan DateTime.tryParse (Bebas Error 'T') ---
                        DateTime tempDate = DateTime.tryParse(e.tgl ?? "") ?? DateTime.now();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      menuDetail?.name ?? "Menu Tidak Diketahui",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (menuDetail?.notes != null && menuDetail?.notes != "")
                                      Text(
                                        menuDetail!.notes!,
                                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                                      ),
                                    Text(
                                      DateFormat("dd MMM yyyy, HH:mm").format(tempDate),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black45,
                                      ),
                                    ),
                                    if (e.notes != null && e.notes != "")
                                      Text(
                                        "Catatan: ${e.notes}",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      )
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  if (e.debtType != "")
                                    Text(
                                      "${e.debtType} ${key.toLowerCase()}",
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  Text(
                                    simpleFormatCurrency.format(nominal),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                onPressed: () async {
                                  // Hapus dari keranjang
                                  final gBloc = context.read<GlobalBloc>();
                                  gBloc.cart.remove(e);
                                  
                                  if (gBloc.cart.isEmpty) {
                                    Navigator.pop(context);
                                  } else {
                                    setState(() {}); // Refresh list di modal
                                    await CreateModel2().getMenu(context);
                                  }
                                },
                                icon: const Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                  size: 20,
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
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(32.0),
          ),
          child: StreamBuilder(
            stream: CreateModel2().getCartStream(context),
            builder: (context, AsyncSnapshot snapshot) {
              // --- PERBAIKAN 3: Hitung total dengan tryParse ---
              int totalNominal = 0;
              List<CartModel> sdata = snapshot.data ?? [];
              
              if (snapshot.hasData) {
                for (var item in sdata) {
                  totalNominal += (int.tryParse(item.gin ?? "0") ?? 0) - 
                                  (int.tryParse(item.gout ?? "0") ?? 0);
                }
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: <Widget>[
                        const Text(
                          "RINGKASAN TRANSAKSI",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          simpleFormatCurrency.format(totalNominal),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: getListData(context, sdata),
                    ),
                  ),
                  const Divider(),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        "TUTUP",
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
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