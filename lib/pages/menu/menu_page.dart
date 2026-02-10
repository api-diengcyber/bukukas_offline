import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:keuangan/components/circle_custom.dart';
import 'package:keuangan/components/item_menu.dart';
import 'package:keuangan/components/modal/modal_create_menu.dart';
import 'package:keuangan/components/pagination.dart';
import 'package:keuangan/components/search_input.dart';
import 'package:keuangan/helpers/set_menus.dart';
import 'package:keuangan/pages/menu/menu_model.dart';
import 'package:keuangan/providers/global_bloc.dart';
import 'package:keuangan/providers/menu_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:keuangan/utils/currency.dart';
import 'package:provider/provider.dart';
import 'package:skeleton_text/skeleton_text.dart';
import '../../components/modal/modal_edit_menu.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

List<dynamic> items = [
  {
    'name': 'Semua',
    'icon': Icons.apps,
    'splashColor': Colors.black54,
    'activeColor': Colors.black,
    'activeIconColor': Colors.black,
    'activeGradient': const LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        Color.fromARGB(255, 255, 255, 255),
        Color.fromARGB(255, 255, 255, 255),
      ],
    ),
  },
  {
    'name': 'Masuk',
    'icon': iconMenus[0],
    'splashColor': Colors.green,
    'activeColor': Colors.black87,
    'activeIconColor': Colors.white,
    'activeGradient': gradientMenu[0],
  },
  {
    'name': 'Keluar',
    'icon': iconMenus[1],
    'splashColor': Colors.pink,
    'activeColor': Colors.black87,
    'activeIconColor': Colors.white,
    'activeGradient': gradientMenu[1],
  },
  {
    'name': 'Hutang',
    'icon': iconMenus[2],
    'splashColor': Colors.amber,
    'activeColor': Colors.black87,
    'activeIconColor': Colors.white,
    'activeGradient': gradientMenu[2],
  },
  {
    'name': 'Piutang',
    'icon': iconMenus[3],
    'splashColor': Colors.blue,
    'activeColor': Colors.black87,
    'activeIconColor': Colors.white,
    'activeGradient': gradientMenu[3],
  },
];

class _MenuPageState extends State<MenuPage> {
  final formatCurrency = NumberFormat.simpleCurrency(
    locale: 'id_ID',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      MenuModel().init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuBloc = context.watch<MenuBloc>();
    final globalBloc = context.watch<GlobalBloc>();

    double bottomPadding = MediaQuery.of(context).padding.bottom;

    openDialogMenu(int actTab) {
      globalBloc.loading = false;
      showDialog(
        context: context,
        barrierColor: const Color.fromARGB(26, 0, 0, 0),
        builder: (BuildContext context) => CreateMenuModal(
          type: actTab == 1
              ? "Pemasukan"
              : actTab == 2
                  ? "Pengeluaran"
                  : actTab == 3
                      ? "Hutang"
                      : actTab == 4
                          ? "Piutang"
                          : "",
          gradient: actTab == 1
              ? modalGradientMenu[0]
              : (actTab == 2)
                  ? modalGradientMenu[1]
                  : (actTab == 3)
                      ? modalGradientMenu[2]
                      : (actTab == 4)
                          ? modalGradientMenu[3]
                          : modalGradientMenu[0],
          onSuccess: () async {
            await MenuModel().getMenu(context);
          },
        ),
      );
    }

    openEditDialogMenu(data) {
      globalBloc.loading = false;
      showDialog(
        context: context,
        barrierColor: const Color.fromARGB(26, 0, 0, 0),
        builder: (BuildContext context) => EditMenuModal(
          type: data.type,
          gradient: data.type == "Pemasukan"
              ? modalGradientMenu[0]
              : (data.type == "Pengeluaran")
                  ? modalGradientMenu[1]
                  : (data.type == "Hutang")
                      ? modalGradientMenu[2]
                      : (data.type == "Piutang")
                          ? modalGradientMenu[3]
                          : modalGradientMenu[0],
          data: data,
          onSuccess: () async {
            await MenuModel().getMenu(context);
          },
        ),
      );
    }

    onDeleteMenu(data) async {
      // PERBAIKAN 1: Gunakan tryParse agar tidak error 'T'
      DateTime tempDate = DateTime.tryParse(data.createdOn ?? "") ?? DateTime.now();
      
      int jml = int.tryParse(data.total?.toString() ?? "0") ?? 0;

      String desc = '${data.name} (${data.type})';
      desc += '\n ${DateFormat("yyyy-MM-dd HH:mm").format(tempDate)}';
      
      if ((data.totalTransaction ?? 0) > 0) {
        desc += '\n\n Masih ada data transaksi yang terkait dengan akun ini [${data.totalTransaction}].';
      }

      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        headerAnimationLoop: false,
        animType: AnimType.bottomSlide,
        title: 'Konfirmasi hapus akun',
        desc: desc,
        buttonsTextStyle: const TextStyle(color: Colors.white),
        showCloseIcon: true,
        btnCancelColor: Colors.grey,
        btnOkColor: Colors.red,
        btnOkText: "Hapus akun",
        btnCancelOnPress: () {},
        btnOkOnPress: () async {
          var resp = await MenuModel().delete(context, data.id);
          if (resp) {
            await MenuModel().getMenu(context);
          }
        },
      ).show();
    }

    AppBar appBar = AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: const Color(0x00000000),
      elevation: 0,
      centerTitle: true,
      leading: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back, color: Colors.black),
      ),
      title: const Text(
        'Kelola menu',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    double marginTopScreen =
        appBar.preferredSize.height + MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: Container(
        color: Colors.grey.shade100,
        constraints: const BoxConstraints.expand(),
        padding: EdgeInsets.only(bottom: bottomPadding > 0 ? bottomPadding : 10),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                height: marginTopScreen,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 6, bottom: 0, left: 12, right: 12),
                      child: Row(
                        children: [
                          for (var item in items)
                            Expanded(
                              child: ItemMenu(
                                icon: item['icon'],
                                text: item['name'],
                                splashColor: item['splashColor'],
                                activeColor: item['activeColor'],
                                activeIconColor: item['activeIconColor'],
                                activeGradient: item['activeGradient'],
                                active: menuBloc.activeTab == items.indexOf(item),
                                onTap: !menuBloc.loading
                                    ? () async {
                                        if (menuBloc.activeTab != items.indexOf(item)) {
                                          menuBloc.activeTab = items.indexOf(item);
                                          menuBloc.page = 1;
                                          await MenuModel().getMenu(context);
                                        }
                                      }
                                    : () {},
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: SearchInput(
                        onChanged: (value) async {
                          menuBloc.page = 1;
                          await MenuModel().getMenu(context);
                        },
                        onReset: () async {
                          menuBloc.page = 1;
                          await MenuModel().getMenu(context);
                        },
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: !menuBloc.loading
                            ? menuBloc.data.isNotEmpty
                                ? ListView.builder(
                                    itemCount: menuBloc.data.length,
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.all(0),
                                    itemBuilder: (context, index) {
                                      var data = menuBloc.data[index];
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        child: Material(
                                          color: Colors.grey.shade200,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 12),
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(146, 255, 255, 255),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              children: [
                                                CircleCustom(
                                                  height: 35,
                                                  icon: data.type == "Pemasukan" ? iconMenus[0] : (data.type == "Pengeluaran" ? iconMenus[1] : (data.type == "Hutang" ? iconMenus[2] : iconMenus[3])),
                                                  iconSize: 23,
                                                  gradient: data.type == "Pemasukan" ? gradientMenu[0] : (data.type == "Pengeluaran" ? gradientMenu[1] : (data.type == "Hutang" ? gradientMenu[2] : gradientMenu[3])),
                                                  active: true,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(data.name ?? "", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                                      if (data.notes != null && data.notes != "")
                                                        Text(data.notes ?? "", style: const TextStyle(color: Colors.black54, fontSize: 13)),
                                                      
                                                      if (data.defaultValue != null && (int.tryParse(data.defaultValue.toString()) ?? 0) > 0)
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                          margin: const EdgeInsets.only(top: 3),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(20),
                                                            color: data.type == "Pemasukan" ? Colors.green.shade100 : (data.type == "Pengeluaran" ? Colors.pink.shade100 : Colors.amber.shade100),
                                                          ),
                                                          child: Text(
                                                            formatter.formatString(data.defaultValue.toString()),
                                                            style: const TextStyle(color: Colors.black, fontSize: 12),
                                                          ),
                                                        ),

                                                      // PERBAIKAN 2: Proteksi tryParse untuk Tanggal Deadline (Baris 475)
                                                      if ((data.type == "Hutang" || data.type == "Piutang") && data.deadline != null && data.deadline != "")
                                                        Container(
                                                          margin: const EdgeInsets.only(top: 4),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.circular(10),
                                                            boxShadow: [
                                                              BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 1),
                                                            ],
                                                          ),
                                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                          child: Text(
                                                            DateFormat("yyyy-MM-dd").format(DateTime.tryParse(data.deadline ?? "") ?? DateTime.now()),
                                                            style: TextStyle(
                                                              color: (int.tryParse(data.statusPaidOff ?? "0") ?? 0) == 1 ? Colors.grey : Colors.red,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () => openEditDialogMenu(data),
                                                      child: Container(
                                                        padding: const EdgeInsets.all(6),
                                                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7)),
                                                        child: const Icon(Icons.edit, size: 17, color: Colors.black87),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    InkWell(
                                                      onTap: () => onDeleteMenu(data),
                                                      child: Container(
                                                        padding: const EdgeInsets.all(6),
                                                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7)),
                                                        child: const Icon(Icons.delete, size: 17, color: Colors.red),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : const Center(child: Text("Data kosong", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)))
                            : Center(child: SpinKitDoubleBounce(color: items[menuBloc.activeTab]['splashColor'])),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        top: 6,
                      ),
                      width: double.infinity,
                      child: Row(
                        children: [
                          menuBloc.totalPages > 1
                              ? Expanded(
                                  child: !menuBloc.loading
                                      ? Pagination(
                                          totalPage: menuBloc.totalPages,
                                          page: menuBloc.page,
                                          onTap: (page) async {
                                            menuBloc.page = page;
                                            await MenuModel().getMenu(context);
                                          },
                                        )
                                      : SkeletonAnimation(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          shimmerColor:
                                              items[menuBloc.activeTab]
                                                  ['splashColor'],
                                          child: Container(
                                            height: 30,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              color: Colors.grey.shade200,
                                            ),
                                          ),
                                        ),
                                )
                              : const Expanded(
                                  child: SizedBox(),
                                ),
                          menuBloc.activeTab != 0
                              ? InkWell(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: menuBloc.activeTab == 1
                                          ? gradientMenu[0]
                                          : (menuBloc.activeTab == 2
                                              ? gradientMenu[1]
                                              : (menuBloc.activeTab == 3)
                                                  ? gradientMenu[2]
                                                  : gradientMenu[3]),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                          offset: const Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    margin: const EdgeInsets.only(bottom: 2),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      size: 25,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onTap: () {
                                    openDialogMenu(menuBloc.activeTab);
                                  },
                                )
                              : SpeedDial(
                                  icon: Icons.add,
                                  activeIcon: Icons.close,
                                  iconTheme: const IconThemeData(
                                    color: Colors.white,
                                  ),
                                  spacing: 3,
                                  childPadding: const EdgeInsets.all(5),
                                  spaceBetweenChildren: 4,
                                  buttonSize: const Size(40, 40),
                                  gradient: gradientMenu[4],
                                  gradientBoxShape: BoxShape.circle,
                                  children: [
                                    SpeedDialChild(
                                      child: CircleCustom(
                                        height: 50,
                                        icon: iconMenus[3],
                                        iconSize: 23,
                                        gradient: gradientMenu[3],
                                        active: true,
                                      ),
                                      label: 'Piutang',
                                      onTap: () {
                                        openDialogMenu(4);
                                      },
                                    ),
                                    SpeedDialChild(
                                      child: CircleCustom(
                                        height: 50,
                                        icon: iconMenus[2],
                                        iconSize: 23,
                                        gradient: gradientMenu[2],
                                        active: true,
                                      ),
                                      label: 'Hutang',
                                      onTap: () {
                                        openDialogMenu(3);
                                      },
                                    ),
                                    SpeedDialChild(
                                      child: CircleCustom(
                                        height: 50,
                                        icon: iconMenus[1],
                                        iconSize: 23,
                                        gradient: gradientMenu[1],
                                        active: true,
                                      ),
                                      label: 'Kas Keluar',
                                      onTap: () {
                                        openDialogMenu(2);
                                      },
                                    ),
                                    SpeedDialChild(
                                      child: CircleCustom(
                                        height: 50,
                                        icon: iconMenus[0],
                                        iconSize: 23,
                                        gradient: gradientMenu[0],
                                        active: true,
                                      ),
                                      label: 'Kas Masuk',
                                      onTap: () {
                                        openDialogMenu(1);
                                      },
                                    ),
                                  ],
                                ),
                          menuBloc.totalPages > 1
                              ? const SizedBox()
                              : const Expanded(
                                  child: SizedBox(),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}