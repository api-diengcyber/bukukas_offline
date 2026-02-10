import 'package:awesome_dialog/awesome_dialog.dart';
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
      // PERBAIKAN 1: Gunakan DateTime.tryParse (Bebas error 'T')
      DateTime tempDate = DateTime.tryParse(data.transactionDate ?? "") ?? DateTime.now();
      
      // PERBAIKAN 2: Gunakan int.tryParse (Bebas error isNegative)
      int jml = (int.tryParse(data.valueIn ?? "0") ?? 0) - 
                (int.tryParse(data.valueOut ?? "0") ?? 0);

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
          var resp = await ReportModel().deleteTransaction(context, data.id ?? 0);
          if (resp) {
            await CreateModel().getData(context);
          }
        },
      ).show();
    }

    AppBar appBar = AppBar(
      iconTheme: const IconThemeData(color: Colors.black),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: const Color(0x00000000),
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Buku: ${globalBloc.activeBukukasName}', // Menampilkan nama Buku Kas aktif
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, 'load');
        return Future.value(false);
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: appBar,
        body: Container(
          constraints: const BoxConstraints.expand(),
          color: Colors.grey.shade200,
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                  child: Row(
                    children: [
                      _buildMenuTab(context, globalBloc, transactionBloc, createBloc, 0, 'Pemasukan'),
                      _buildMenuTab(context, globalBloc, transactionBloc, createBloc, 1, 'Pengeluaran'),
                      _buildMenuTab(context, globalBloc, transactionBloc, createBloc, 2, 'Hutang'),
                      _buildMenuTab(context, globalBloc, transactionBloc, createBloc, 3, 'Piutang'),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                    child: CustomPaint(
                      painter: BubbleTriangle(
                        comparePathWidth: globalBloc.tabMenuTransaction == "Pemasukan"
                            ? 8.2 : (globalBloc.tabMenuTransaction == "Pengeluaran"
                                ? 2.65 : (globalBloc.tabMenuTransaction == "Hutang" ? 1.6 : 1.14)),
                      ),
                      child: Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: [
                            _buildAddNewButton(context, globalBloc, createBloc, transactionBloc),
                            Expanded(
                              child: !createBloc.loading
                                  ? Column(
                                      children: [
                                        if (createBloc.data.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          const Divider(height: 0),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            color: Colors.white,
                                            child: Center(
                                              child: Text(
                                                "${globalBloc.tabMenuTransaction.toUpperCase()} TERAKHIR",
                                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54),
                                              ),
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 6),
                                        Expanded(
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            padding: EdgeInsets.zero,
                                            itemCount: createBloc.data.length,
                                            itemBuilder: (context, index) {
                                              var data = createBloc.data[index];
                                              DateTime itemDate = DateTime.tryParse(data.transactionDate ?? "") ?? DateTime.now();
                                              return _buildTransactionItem(data, itemDate, onDeleteMenu);
                                            },
                                          ),
                                        ),
                                        if (createBloc.totalPage > 1)
                                          Pagination(
                                            totalPage: createBloc.totalPage,
                                            page: createBloc.page,
                                            height: 10,
                                            onTap: (page) async {
                                              createBloc.page = page;
                                              await CreateModel().getData(context);
                                            },
                                          )
                                      ],
                                    )
                                  : const Center(child: SpinKitDoubleBounce(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTab(BuildContext context, GlobalBloc globalBloc, TransactionBloc tBloc, CreateBloc cBloc, int index, String type) {
    return Expanded(
      child: CircleMenu(
        icon: iconMenus[index],
        iconSize: 30,
        name: type,
        nameSize: 13,
        gradient: gradientMenu[index],
        active: globalBloc.tabMenuTransaction == type,
        onTap: globalBloc.tabMenuTransaction != type
            ? () async {
                tBloc.page = 1;
                cBloc.page = 1;
                globalBloc.tabMenuTransaction = type;
                await CreateModel().getData(context);
              }
            : () {},
      ),
    );
  }

  Widget _buildAddNewButton(BuildContext context, GlobalBloc globalBloc, CreateBloc cBloc, TransactionBloc tBloc) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, bottom: 2, top: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            PageTransition(type: PageTransitionType.fade, child: const CreateTransaction2Page()),
          ).then((value) async {
            if (value == 'load') {
              cBloc.page = 1;
              tBloc.page = 1;
              await CreateModel().getData(context);
            }
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color.fromARGB(146, 255, 255, 255),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              CircleCustom(
                height: 40,
                icon: Icons.add,
                iconSize: 23,
                gradient: globalBloc.tabMenuTransaction == "Pemasukan" ? gradientMenu[0] 
                        : (globalBloc.tabMenuTransaction == "Pengeluaran" ? gradientMenu[1] 
                        : (globalBloc.tabMenuTransaction == "Hutang" ? gradientMenu[2] : gradientMenu[3])),
                active: true,
              ),
              const SizedBox(width: 12),
              Text(
                "${globalBloc.tabMenuTransaction} baru",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(TbTransaksiModel data, DateTime tempDate, Function onDelete) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8, left: 12, right: 12),
      decoration: BoxDecoration(
        color: activeTabColor(data.menuType ?? "", labelsColor),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: activeTabColor(data.menuType ?? "", chipsColor), blurRadius: 0.2),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.menuName ?? "", style: TextStyle(color: activeTabColor(data.menuType ?? "", reportActiveTabColor), fontWeight: FontWeight.bold, fontSize: 15)),
                Text(DateFormat("yyyy-MM-dd HH:mm").format(tempDate), style: const TextStyle(color: Colors.black87, fontSize: 13)),
                if (data.notes != null && data.notes != "")
                  Text(data.notes!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        formatCurrency.format((int.tryParse(data.valueIn ?? "0") ?? 0) - (int.tryParse(data.valueOut ?? "0") ?? 0)),
                        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    if (data.debtType != "NON") ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(10)),
                        child: Text("${data.debtType} ${data.menuType?.toLowerCase()}", style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ]
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 22),
            onPressed: () => onDelete(data),
          ),
        ],
      ),
    );
  }
}