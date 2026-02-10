import 'package:keuangan/components/circle_custom.dart';
import 'package:keuangan/components/models/cart_model.dart';
import 'package:keuangan/db/model/tb_menu_model.dart';
import 'package:keuangan/helpers/set_menus.dart';
import 'package:keuangan/pages/transaction/create2_model.dart';
import 'package:keuangan/providers/global_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:keuangan/providers/transaction_bloc.dart';
import 'package:keuangan/utils/currency.dart';
import 'package:provider/provider.dart';

class CreateTransactionModal extends StatefulWidget {
  const CreateTransactionModal({
    super.key,
    required this.data,
  });

  final TbMenuModel data;

  @override
  State<CreateTransactionModal> createState() => _CreateTransactionModalState();
}

class _CreateTransactionModalState extends State<CreateTransactionModal> {
  final _formKey = GlobalKey<FormBuilderState>();
  final formatCurrency = NumberFormat.simpleCurrency(
    locale: 'id_ID',
    decimalDigits: 0,
  );

  int _nominal = 0;
  bool _allowSave = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      _nominal = 0;
      _allowSave = true;
    });
  }

  checkAllow(BuildContext context) {
    _allowSave = true;
    final globalBloc = context.read<GlobalBloc>();
    if ((widget.data.type == "Hutang" || widget.data.type == "Piutang")) {
      int indexMenuExist = globalBloc.cart.indexWhere((element) =>
          // ignore: prefer_interpolation_to_compose_strings
          "${element.menuId}-${element.type}-${element.debtType}" ==
          "${widget.data.id}-${widget.data.type}-${globalBloc.debtType}");
      if (indexMenuExist > -1) {
        _allowSave = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final globalBloc = context.watch<GlobalBloc>();
    final transactionBloc = context.watch<TransactionBloc>();

    checkAllow(context);

    processSave(dynamic valueForm, bool isFinish) async {
      int nominal = int.parse(valueForm["nominal"]
          .replaceAll(RegExp(r'[^\d.]'), '')
          .replaceAll(RegExp(r'[.]'), '')
          .replaceAll(RegExp(r'[,]'), '.'));

      int gIn = 0;
      int gOut = 0;

      int sisa = 0;
      if (widget.data.type == "Hutang" || widget.data.type == "Piutang") {
        int currentTotal = int.tryParse(widget.data.total ?? "0") ?? 0;
        if (((globalBloc.debtType == "Bayar"
                    ? currentTotal - _nominal
                    : currentTotal + _nominal) *
                -1) >
            0) {
          sisa = ((globalBloc.debtType == "Bayar"
                  ? currentTotal - _nominal
                  : currentTotal + _nominal) *
              -1);
        }
      }

      if (widget.data.type == "Pemasukan") {
        gIn = nominal;
        gOut = 0;
      } else if (widget.data.type == "Pengeluaran") {
        gIn = 0;
        gOut = nominal;
      } else if (widget.data.type == "Hutang") {
        if (globalBloc.debtType == "Bayar") {
          gIn = 0;
          gOut = nominal - sisa;
        } else if (globalBloc.debtType == "Tambah") {
          gIn = nominal - sisa;
          gOut = 0;
        }
      } else if (widget.data.type == "Piutang") {
        if (globalBloc.debtType == "Bayar") {
          gIn = nominal - sisa;
          gOut = 0;
        } else if (globalBloc.debtType == "Tambah") {
          gIn = 0;
          gOut = nominal - sisa;
        }
      }

      if (gIn > 0 || gOut > 0) {
        bool allowSave = true;

        if ((widget.data.type == "Hutang" || widget.data.type == "Piutang")) {
          int indexMenuExist = globalBloc.cart
              .indexWhere((element) => element.menuId == widget.data.id);
          if (indexMenuExist > -1) {
            if (globalBloc.cart[indexMenuExist].type == widget.data.type) {
              if (globalBloc.cart[indexMenuExist].debtType ==
                  globalBloc.debtType) {
                allowSave = false;
              }
            }
          }
        }

        if (allowSave) {
          globalBloc.cart.add(CartModel(
            index: globalBloc.cart.length,
            tgl: valueForm["tgl"].toIso8601String(),
            gin: gIn.toString(),
            gout: gOut.toString(),
            notes: valueForm["notes"],
            deadline:
                valueForm["deadline"] != null && valueForm["deadline"] != ""
                    ? valueForm["deadline"].toIso8601String()
                    : null,
            debtType:
                (widget.data.type == "Hutang" || widget.data.type == "Piutang")
                    ? globalBloc.debtType
                    : "",
            type: widget.data.type,
            menuId: widget.data.id,
            menuDetail: widget.data,
          ));

          if (isFinish) {
            await CreateModel2().saveTransaction(context);
            // ignore: use_build_context_synchronously
            Navigator.pop(context, 'success');
            // refresh menu after saving...
            if (widget.data.type == "Hutang" || widget.data.type == "Piutang") {
              // ignore: use_build_context_synchronously
              await CreateModel2().getMenu(context);
            }
          } else {
            globalBloc.loadingMenus = false;
            Navigator.pop(context);
          }
        } else {
          Navigator.pop(context);
        }
      } else {
        Navigator.pop(context);
      }
    }

    List<CartModel> cartByMenu = globalBloc.cart
        .where((element) => element.menuId == widget.data.id)
        .toList();
    int totalSameCart = 0;
    for (var item in cartByMenu) {
      if (widget.data.type == "Hutang") {
        totalSameCart +=
            (int.tryParse(item.gin ?? "0") ?? 0) - (int.tryParse(item.gout ?? "0") ?? 0);
      } else {
        totalSameCart +=
            (int.tryParse(item.gout ?? "0") ?? 0) - (int.tryParse(item.gin ?? "0") ?? 0);
      }
    }

    // --- PERBAIKAN PARSING TANGGAL DI SINI ---
    DateTime? tempDateDeadline;
    String deadlineDisplay = "-";
    if (widget.data.type == "Hutang" || widget.data.type == "Piutang") {
      // Gunakan tryParse agar lebih aman dari format mismatch
      tempDateDeadline = DateTime.tryParse(widget.data.deadline ?? "");
      if (tempDateDeadline != null) {
        deadlineDisplay = DateFormat("dd-MM-yyyy").format(tempDateDeadline);
      }
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(
                top: 15,
              ),
              width: double.infinity,
              height: ((widget.data.type == "Hutang" ||
                              widget.data.type == "Piutang")
                          ? .45
                          : .39) *
                      MediaQuery.of(context).size.height +
                  34,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  bottomRight: const Radius.circular(20),
                  topRight: const Radius.circular(200),
                  bottomLeft: const Radius.circular(200),
                ),
                gradient: widget.data.type == "Pemasukan"
                    ? gradientActiveDMenu[0]
                    : (widget.data.type == "Pengeluaran"
                        ? gradientActiveDMenu[1]
                        : (widget.data.type == "Hutang")
                            ? gradientActiveDMenu[2]
                            : gradientActiveDMenu[3]),
              ),
              child: const SizedBox(),
            ),
            Container(
              width: double.infinity,
              height: ((widget.data.type == "Hutang" ||
                              widget.data.type == "Piutang")
                          ? .45
                          : .39) *
                  MediaQuery.of(context).size.height,
              margin: const EdgeInsets.only(
                left: 8,
                right: 8,
                top: 30,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 6,
              ),
              decoration: const BoxDecoration(
                color: Color.fromARGB(232, 255, 255, 255),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomRight: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 4,
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: _allowSave
                            ? SingleChildScrollView(
                                child: FormBuilder(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      widget.data.notes != null &&
                                              widget.data.notes != ""
                                          ? Container(
                                              margin: const EdgeInsets.only(
                                                bottom: 12,
                                                top: 4,
                                              ),
                                              child: Text(
                                                widget.data.notes ?? "",
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            )
                                          : const SizedBox(
                                              height: 22,
                                            ),
                                      globalBloc.debtType == "Tambah"
                                          ? Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 24),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 0,
                                                horizontal: 12,
                                              ),
                                              child: const Text(
                                                "Setelah anda menyimpan penambahan, anda tidak dapat mengubahnya lagi.",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                          : const SizedBox(),
                                      FormBuilderDateTimePicker(
                                        name: 'tgl',
                                        inputType: InputType.date,
                                        initialDate: DateTime.now(),
                                        initialValue: DateTime.now(),
                                        format: DateFormat('dd-MM-yyyy'),
                                        enabled: _allowSave &&
                                            !transactionBloc.loading,
                                        decoration: InputDecoration(
                                          labelText: 'Tanggal Transaksi',
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            vertical: 4,
                                            horizontal: 12,
                                          ),
                                        ),
                                        validator:
                                            FormBuilderValidators.compose([
                                          FormBuilderValidators.required(),
                                        ]),
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      FormBuilderTextField(
                                        name: 'nominal',
                                        enabled: _allowSave &&
                                            !transactionBloc.loading,
                                        initialValue: widget.data.defaultValue != "" && widget.data.defaultValue != null
                                            ? formatter.formatString(widget.data.defaultValue.toString())
                                            : null,
                                        decoration: InputDecoration(
                                          labelText: (widget.data.type == "Hutang" || widget.data.type == "Piutang")
                                              ? "Nominal ${globalBloc.debtType.toLowerCase()} ${(widget.data.type ?? "").toLowerCase()}"
                                              : "Nominal",
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                            horizontal: 12,
                                          ),
                                        ),
                                        validator: FormBuilderValidators.compose([
                                          FormBuilderValidators.required(),
                                        ]),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [formatter],
                                        onChanged: (val) {
                                          int total = 0;
                                          if (val != null && val != "") {
                                            total = int.tryParse(val.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
                                          }
                                          setState(() {
                                            _nominal = total;
                                          });
                                        },
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      globalBloc.debtType == "Tambah"
                                          ? Container(
                                              margin: const EdgeInsets.only(
                                                top: 12,
                                                bottom: 4,
                                              ),
                                              child: FormBuilderDateTimePicker(
                                                name: 'deadline',
                                                inputType: InputType.date,
                                                // Gunakan tempDateDeadline hasil tryParse
                                                initialDate: tempDateDeadline ?? DateTime.now(),
                                                initialValue: tempDateDeadline ?? DateTime.now(),
                                                format: DateFormat('dd-MM-yyyy'),
                                                enabled: _allowSave && !transactionBloc.loading,
                                                decoration: InputDecoration(
                                                  labelText: 'Jatuh tempo baru',
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  contentPadding: const EdgeInsets.symmetric(
                                                    vertical: 4,
                                                    horizontal: 12,
                                                  ),
                                                ),
                                                validator: FormBuilderValidators.compose([
                                                  FormBuilderValidators.required(),
                                                ]),
                                              ),
                                            )
                                          : const SizedBox(),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      FormBuilderTextField(
                                        name: 'notes',
                                        enabled: _allowSave &&
                                            !transactionBloc.loading,
                                        decoration: InputDecoration(
                                          labelText: 'Keterangan (opsional)',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            vertical: 4,
                                            horizontal: 12,
                                          ),
                                        ),
                                        keyboardType: TextInputType.multiline,
                                        textInputAction:
                                            TextInputAction.newline,
                                        minLines: 3,
                                        maxLines: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const Text(
                                "Menu ini hanya dapat 1 kali simpan",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            onTap: !transactionBloc.loading
                                ? () async {
                                    if (_formKey.currentState!.validate()) {
                                      _formKey.currentState!.save();
                                      await processSave(
                                          _formKey.currentState!.value, false);
                                    }
                                  }
                                : null,
                            child: Container(
                              margin: const EdgeInsets.only(
                                left: 12,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 9,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                gradient: !globalBloc.loading
                                    ? (widget.data.type == "Pemasukan"
                                        ? gradient2[0]
                                        : (widget.data.type == "Pengeluaran"
                                            ? gradient2[1]
                                            : (widget.data.type == "Hutang")
                                                ? gradient2[2]
                                                : gradient2[3]))
                                    : null,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 0,
                                    blurRadius: 2,
                                    offset: const Offset(
                                        0, 2), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  !transactionBloc.loading
                                      ? "Lanjut"
                                      : "Menyimpan..",
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: !transactionBloc.loading
                                ? () async {
                                    if (_formKey.currentState!.validate()) {
                                      _formKey.currentState!.save();
                                      await processSave(
                                          _formKey.currentState!.value, true);
                                    }
                                  }
                                : null,
                            child: Container(
                              margin: const EdgeInsets.only(
                                left: 12,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 9,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                gradient: !globalBloc.loading
                                    ? (widget.data.type == "Pemasukan"
                                        ? gradientMenu[0]
                                        : (widget.data.type == "Pengeluaran"
                                            ? gradientMenu[1]
                                            : (widget.data.type == "Hutang")
                                                ? gradientMenu[2]
                                                : gradientMenu[3]))
                                    : null,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 0,
                                    blurRadius: 2,
                                    offset: const Offset(
                                        0, 2), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  !transactionBloc.loading
                                      ? "Selesaikan"
                                      : "Menyimpan..",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 6,
              top: 25,
              right: 6,
              child: Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      children: <Widget>[
                        CircleCustom(
                          height: 24,
                          icon: widget.data.type == "Pemasukan"
                              ? iconMenus[0]
                              : (widget.data.type == "Pengeluaran"
                                  ? iconMenus[1]
                                  : (widget.data.type == "Hutang")
                                      ? iconMenus[2]
                                      : iconMenus[3]),
                          iconSize: 12,
                          gradient: widget.data.type == "Pemasukan"
                              ? gradientActiveDMenu[0]
                              : (widget.data.type == "Pengeluaran"
                                  ? gradientActiveDMenu[1]
                                  : (widget.data.type == "Hutang")
                                      ? gradientActiveDMenu[2]
                                      : gradientActiveDMenu[3]),
                          active: true,
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Text(
                          widget.data.name ?? "",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: SizedBox(),
                  ),
                  (widget.data.type == "Hutang" ||
                          widget.data.type == "Piutang")
                      ? Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: <Widget>[
                              InkWell(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: globalBloc.debtType == "Bayar"
                                        ? (widget.data.type == "Hutang"
                                            ? Colors.amber
                                            : Colors.blue)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "Bayar",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: globalBloc.debtType == "Bayar"
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  globalBloc.debtType = "Bayar";
                                  checkAllow(context);
                                },
                              ),
                              InkWell(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: globalBloc.debtType == "Tambah"
                                        ? (widget.data.type == "Hutang"
                                            ? Colors.amber
                                            : Colors.blue)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "Tambah",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: globalBloc.debtType == "Tambah"
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  globalBloc.debtType = "Tambah";
                                  checkAllow(context);
                                },
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}