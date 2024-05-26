import 'package:keuangan/components/circle_custom.dart';
import 'package:keuangan/helpers/set_menus.dart';
import 'package:keuangan/pages/transaction/create2_model.dart';
import 'package:keuangan/providers/global_bloc.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:keuangan/providers/transaction_bloc.dart';
import 'package:provider/provider.dart';

class CreateTransactionModal extends StatefulWidget {
  const CreateTransactionModal({
    Key? key,
    required this.data,
  }) : super(key: key);

  final dynamic data;

  @override
  State<CreateTransactionModal> createState() => _CreateTransactionModalState();
}

class _CreateTransactionModalState extends State<CreateTransactionModal> {
  final _formKey = GlobalKey<FormBuilderState>();
  final formatCurrency = NumberFormat.simpleCurrency(
    locale: 'id_ID',
    decimalDigits: 0,
  );
  final CurrencyTextInputFormatter _formatter = CurrencyTextInputFormatter(
    NumberFormat.currency(
      decimalDigits: 0,
      locale: 'id',
      symbol: 'Rp',
    ),
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
    final _globalBloc = context.read<GlobalBloc>();
    if ((widget.data["keu_menu_type"] == "Hutang" ||
        widget.data["keu_menu_type"] == "Piutang")) {
      int _indexMenuExist = _globalBloc.cart.indexWhere((element) =>
          element["menuId"].toString() +
              "-" +
              element["type"] +
              "-" +
              element["debtType"] ==
          widget.data["keu_menu_id"].toString() +
              "-" +
              widget.data["keu_menu_type"] +
              "-" +
              _globalBloc.debtType);
      if (_indexMenuExist > -1) {
        _allowSave = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _globalBloc = context.watch<GlobalBloc>();
    final _transactionBloc = context.watch<TransactionBloc>();

    checkAllow(context);

    processSave(dynamic valueForm, bool isFinish) async {
      int nominal = int.parse(valueForm["nominal"]
          .replaceAll(RegExp(r'[^\d.]'), '')
          .replaceAll(RegExp(r'[.]'), '')
          .replaceAll(RegExp(r'[,]'), '.'));

      int _in = 0;
      int _out = 0;

      int sisa = 0;
      if (widget.data["keu_menu_type"] == "Hutang" ||
          widget.data["keu_menu_type"] == "Piutang") {
        if (((_globalBloc.debtType == "Bayar"
                    ? widget.data['total'] - _nominal
                    : widget.data['total'] + _nominal) *
                -1) >
            0) {
          sisa = ((_globalBloc.debtType == "Bayar"
                  ? widget.data['total'] - _nominal
                  : widget.data['total'] + _nominal) *
              -1);
        }
      }

      if (widget.data["keu_menu_type"] == "Pemasukan") {
        _in = nominal;
        _out = 0;
      } else if (widget.data["keu_menu_type"] == "Pengeluaran") {
        _in = 0;
        _out = nominal;
      } else if (widget.data["keu_menu_type"] == "Hutang") {
        if (_globalBloc.debtType == "Bayar") {
          _in = 0;
          _out = nominal - sisa;
        } else if (_globalBloc.debtType == "Tambah") {
          _in = nominal - sisa;
          _out = 0;
        }
      } else if (widget.data["keu_menu_type"] == "Piutang") {
        if (_globalBloc.debtType == "Bayar") {
          _in = nominal - sisa;
          _out = 0;
        } else if (_globalBloc.debtType == "Tambah") {
          _in = 0;
          _out = nominal - sisa;
        }
      }

      if (_in > 0 || _out > 0) {
        bool allowSave = true;

        if ((widget.data["keu_menu_type"] == "Hutang" ||
            widget.data["keu_menu_type"] == "Piutang")) {
          int _indexMenuExist = _globalBloc.cart.indexWhere(
              (element) => element["menuId"] == widget.data["keu_menu_id"]);
          if (_indexMenuExist > -1) {
            if (_globalBloc.cart[_indexMenuExist]["type"] ==
                widget.data["keu_menu_type"]) {
              if (_globalBloc.cart[_indexMenuExist]["debtType"] ==
                  _globalBloc.debtType) {
                allowSave = false;
              }
            }
          }
        }

        if (allowSave) {
          _globalBloc.cart.add({
            "index": _globalBloc.cart.length,
            "tgl": valueForm["tgl"].toIso8601String(),
            "in": _in.toString(),
            "out": _out.toString(),
            "notes": valueForm["notes"],
            "deadline":
                valueForm["deadline"] != null && valueForm["deadline"] != ""
                    ? valueForm["deadline"].toIso8601String()
                    : null,
            "debtType": (widget.data["keu_menu_type"] == "Hutang" ||
                    widget.data["keu_menu_type"] == "Piutang")
                ? _globalBloc.debtType
                : "",
            "type": widget.data["keu_menu_type"],
            "menuId": widget.data["keu_menu_id"],
            "menuDetail": widget.data,
          });

          if (isFinish) {
            await CreateModel2().saveTransaction(context);
            Navigator.pop(context, 'success');
            // refresh menu after saving...
            // if (widget.data["keu_menu_type"] == "Hutang" ||
            //     widget.data["keu_menu_type"] == "Piutang") {
            //   await CreateModel2().getMenu(context);
            // }
          } else {
            _globalBloc.loadingMenus = false;
            Navigator.pop(context);
          }
        } else {
          Navigator.pop(context);
        }
      } else {
        Navigator.pop(context);
      }
    }

    List<dynamic> _cartByMenu = _globalBloc.cart
        .where((element) => element["menuId"] == widget.data["keu_menu_id"])
        .toList();
    int _totalSameCart = 0;
    for (var item in _cartByMenu) {
      if (widget.data["keu_menu_type"] == "Hutang") {
        _totalSameCart += int.parse(item["in"]) - int.parse(item["out"]);
      } else {
        _totalSameCart += int.parse(item["out"]) - int.parse(item["in"]);
      }
    }

    DateTime? tempDateDeadline;
    String deadline = "";
    if (widget.data["keu_menu_type"] == "Hutang" ||
        widget.data["keu_menu_type"] == "Piutang") {
      tempDateDeadline = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS")
          .parse(widget.data["keu_menu_deadline"]);
      deadline = DateFormat("yyyy-MM-dd").format(tempDateDeadline);
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
              height: ((widget.data["keu_menu_type"] == "Hutang" ||
                              widget.data["keu_menu_type"] == "Piutang")
                          ? .45
                          : .39) *
                      MediaQuery.of(context).size.height +
                  34,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  bottomRight: const Radius.circular(20),
                  topRight: Radius.circular(
                      (widget.data["keu_menu_type"] == "Hutang" ||
                              widget.data["keu_menu_type"] == "Piutang")
                          ? 200
                          : 200),
                  bottomLeft: Radius.circular(
                      (widget.data["keu_menu_type"] == "Hutang" ||
                              widget.data["keu_menu_type"] == "Piutang")
                          ? 200
                          : 200),
                ),
                gradient: widget.data["keu_menu_type"] == "Pemasukan"
                    ? gradientActiveDMenu[0]
                    : (widget.data["keu_menu_type"] == "Pengeluaran"
                        ? gradientActiveDMenu[1]
                        : (widget.data["keu_menu_type"] == "Hutang")
                            ? gradientActiveDMenu[2]
                            : gradientActiveDMenu[3]),
              ),
              child: const SizedBox(),
            ),
            Container(
              width: double.infinity,
              height: ((widget.data["keu_menu_type"] == "Hutang" ||
                          widget.data["keu_menu_type"] == "Piutang")
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
                                      widget.data["keu_menu_notes"] != null &&
                                              widget.data["keu_menu_notes"] !=
                                                  ""
                                          ? Container(
                                              margin: const EdgeInsets.only(
                                                bottom: 12,
                                                top: 4,
                                              ),
                                              child: Text(
                                                widget.data["keu_menu_notes"],
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            )
                                          : const SizedBox(
                                              height: 22,
                                            ),
                                      _globalBloc.debtType == "Tambah"
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
                                            !_transactionBloc.loading,
                                        decoration: InputDecoration(
                                          labelText: 'Tanggal',
                                          labelStyle: const TextStyle(
                                            fontSize: 16,
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                            borderSide: const BorderSide(
                                                color: Colors.grey),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                            borderSide: const BorderSide(
                                                color: Colors.grey),
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
                                            !_transactionBloc.loading,
                                        initialValue: widget.data[
                                                    "keu_menu_default_value"] >
                                                0
                                            ? _formatter.formatString(widget
                                                .data["keu_menu_default_value"]
                                                .toString())
                                            : null,
                                        decoration: InputDecoration(
                                          labelText: (widget.data[
                                                          "keu_menu_type"] ==
                                                      "Hutang" ||
                                                  widget.data[
                                                          "keu_menu_type"] ==
                                                      "Piutang")
                                              ? "Nominal ${_globalBloc.debtType.toLowerCase()} ${widget.data["keu_menu_type"].toLowerCase()}"
                                              : "Nominal",
                                          labelStyle: const TextStyle(
                                            fontSize: 16,
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                            borderSide: const BorderSide(
                                                color: Colors.grey),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                            borderSide: const BorderSide(
                                                color: Colors.grey),
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
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [_formatter],
                                        onChanged: (val) {
                                          int total = 0;
                                          if (val != null && val != "") {
                                            total = int.parse(val
                                                .replaceAll(
                                                    RegExp(r'[^\d.]'), '')
                                                .replaceAll(RegExp(r'[.]'), '')
                                                .replaceAll(
                                                    RegExp(r'[,]'), '.'));
                                          }
                                          setState(() {
                                            _nominal = total;
                                          });
                                        },
                                        onReset: () {
                                          setState(() {
                                            _nominal = 0;
                                          });
                                        },
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      _globalBloc.debtType == "Tambah"
                                          ? Container(
                                              margin: const EdgeInsets.only(
                                                top: 12,
                                                bottom: 4,
                                              ),
                                              child: FormBuilderDateTimePicker(
                                                name: 'deadline',
                                                inputType: InputType.date,
                                                initialDate: tempDateDeadline,
                                                initialValue: tempDateDeadline,
                                                format:
                                                    DateFormat('dd-MM-yyyy'),
                                                enabled: _allowSave &&
                                                    !_transactionBloc.loading,
                                                decoration: InputDecoration(
                                                  labelText: 'Jatuh tempo',
                                                  labelStyle: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Colors.grey),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Colors.grey),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    vertical: 4,
                                                    horizontal: 12,
                                                  ),
                                                ),
                                                validator: FormBuilderValidators
                                                    .compose([
                                                  FormBuilderValidators
                                                      .required(),
                                                ]),
                                              ),
                                            )
                                          : const SizedBox(),
                                      (widget.data["keu_menu_type"] ==
                                                  "Hutang" ||
                                              widget.data["keu_menu_type"] ==
                                                  "Piutang")
                                          ? Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.5),
                                                    spreadRadius: 0,
                                                    blurRadius: 2,
                                                    offset: const Offset(0,
                                                        2), // changes position of shadow
                                                  ),
                                                ],
                                              ),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 5,
                                                vertical: 4,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              child: Row(
                                                children: <Widget>[
                                                  _globalBloc.debtType ==
                                                          "Bayar"
                                                      ? Expanded(
                                                          child: Column(
                                                            children: <Widget>[
                                                              const Text(
                                                                "Jatuh tempo",
                                                                style:
                                                                    TextStyle(
                                                                  letterSpacing:
                                                                      0.5,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black54,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 4,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: <Widget>[
                                                                  Text(
                                                                    deadline,
                                                                    style:
                                                                        const TextStyle(
                                                                      letterSpacing:
                                                                          0.5,
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .black87,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : const SizedBox(),
                                                  (_globalBloc.debtType ==
                                                                  "Bayar"
                                                              ? widget.data[
                                                                      'total'] -
                                                                  _nominal
                                                              : widget.data[
                                                                      'total'] +
                                                                  _nominal) >
                                                          0
                                                      ? Expanded(
                                                          child: Column(
                                                            children: <Widget>[
                                                              Text(
                                                                "${widget.data["keu_menu_type"].toString()} sekarang",
                                                                style:
                                                                    const TextStyle(
                                                                  letterSpacing:
                                                                      0.5,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black54,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 4,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: <Widget>[
                                                                  // for (var item
                                                                  //     in _cartByMenu)
                                                                  //   Container(
                                                                  //     margin: const EdgeInsets
                                                                  //             .only(
                                                                  //         right:
                                                                  //             4),
                                                                  //     child: Text(
                                                                  //         formatCurrency.format(int.parse(item["in"]) - int.parse(item["out"])) +
                                                                  //             ","),
                                                                  //   ),
                                                                  Text(
                                                                    formatCurrency.format(_globalBloc.debtType ==
                                                                            "Bayar"
                                                                        ? widget.data['total'] -
                                                                            _nominal +
                                                                            _totalSameCart
                                                                        : widget.data['total'] +
                                                                            _nominal +
                                                                            _totalSameCart),
                                                                    style:
                                                                        const TextStyle(
                                                                      letterSpacing:
                                                                          0.5,
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .black87,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : Expanded(
                                                          child: Column(
                                                            children: <Widget>[
                                                              const Text(
                                                                "Lunas",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .green,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 15,
                                                                ),
                                                              ),
                                                              ((_globalBloc.debtType == "Bayar"
                                                                              ? widget.data['total'] - _nominal
                                                                              : widget.data['total'] + _nominal) *
                                                                          -1) >
                                                                      0
                                                                  ? Container(
                                                                      margin: const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              4),
                                                                      child:
                                                                          Text(
                                                                        "Sisa: " +
                                                                            formatCurrency.format((_globalBloc.debtType == "Bayar" ? widget.data['total'] - _nominal : widget.data['total'] + _nominal) *
                                                                                -1),
                                                                        style:
                                                                            const TextStyle(
                                                                          letterSpacing:
                                                                              0.5,
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.grey,
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : const SizedBox(),
                                                            ],
                                                          ),
                                                        ),
                                                ],
                                              ),
                                            )
                                          : const SizedBox(),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      FormBuilderTextField(
                                        name: 'notes',
                                        enabled: _allowSave &&
                                            !_transactionBloc.loading,
                                        decoration: InputDecoration(
                                          labelText: 'Keterangan (opsional)',
                                          labelStyle: const TextStyle(
                                            fontSize: 16,
                                          ),
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
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                            borderSide: const BorderSide(
                                                color: Colors.grey),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                            borderSide: const BorderSide(
                                                color: Colors.grey),
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
                            onTap: !_transactionBloc.loading
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
                                gradient: !_globalBloc.loading
                                    ? (widget.data["keu_menu_type"] ==
                                            "Pemasukan"
                                        ? gradientMenu[0]
                                        : (widget.data["keu_menu_type"] ==
                                                "Pengeluaran"
                                            ? gradientMenu[1]
                                            : (widget.data["keu_menu_type"] ==
                                                    "Hutang")
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
                                  !_transactionBloc.loading
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
                          icon: widget.data["keu_menu_type"] == "Pemasukan"
                              ? iconMenus[0]
                              : (widget.data["keu_menu_type"] == "Pengeluaran"
                                  ? iconMenus[1]
                                  : (widget.data["keu_menu_type"] == "Hutang")
                                      ? iconMenus[2]
                                      : iconMenus[3]),
                          iconSize: 12,
                          gradient: widget.data["keu_menu_type"] == "Pemasukan"
                              ? gradientActiveDMenu[0]
                              : (widget.data["keu_menu_type"] == "Pengeluaran"
                                  ? gradientActiveDMenu[1]
                                  : (widget.data["keu_menu_type"] == "Hutang")
                                      ? gradientActiveDMenu[2]
                                      : gradientActiveDMenu[3]),
                          active: true,
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Text(
                          widget.data["keu_menu_name"],
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
                  (widget.data["keu_menu_type"] == "Hutang" ||
                          widget.data["keu_menu_type"] == "Piutang")
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
                                    color: _globalBloc.debtType == "Bayar"
                                        ? widget.data["keu_menu_type"] ==
                                                "Hutang"
                                            ? Colors.amber
                                            : Colors.blue
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "Bayar",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: _globalBloc.debtType == "Bayar"
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  _globalBloc.debtType = "Bayar";
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
                                    color: _globalBloc.debtType == "Tambah"
                                        ? widget.data["keu_menu_type"] ==
                                                "Hutang"
                                            ? Colors.amber
                                            : Colors.blue
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "Tambah",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: _globalBloc.debtType == "Tambah"
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  _globalBloc.debtType = "Tambah";
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
