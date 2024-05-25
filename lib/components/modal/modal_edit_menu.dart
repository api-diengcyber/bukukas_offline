import 'package:keuangan/db/model/tb_menu_model.dart';
import 'package:keuangan/db/tb_menu.dart';
import 'package:keuangan/providers/global_bloc.dart';
import 'package:keuangan/services/menu_service.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class EditMenuModal extends StatefulWidget {
  EditMenuModal({
    Key? key,
    required this.type,
    required this.gradient,
    this.data,
    this.onSuccess,
  }) : super(key: key);

  final String type;
  LinearGradient gradient;
  TbMenuModel? data;
  dynamic onSuccess;

  @override
  State<EditMenuModal> createState() => _EditMenuModalState();
}

class _EditMenuModalState extends State<EditMenuModal> {
  final formKey = GlobalKey<FormBuilderState>();
  final CurrencyTextInputFormatter _formatter = CurrencyTextInputFormatter(
    NumberFormat.compactCurrency(
      decimalDigits: 0,
      locale: 'id',
      symbol: 'Rp',
    ),
  );

  @override
  Widget build(BuildContext context) {
    final globalBloc = context.watch<GlobalBloc>();

    return AlertDialog(
      backgroundColor: Colors.white54,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(32.0),
        ),
      ),
      contentPadding: const EdgeInsets.all(0),
      content: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32.0),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  gradient: widget.gradient,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 21,
                ),
                child: const Text(
                  "Edit Menu",
                  style: TextStyle(
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: FormBuilder(
                      key: formKey,
                      child: Column(
                        children: <Widget>[
                          FormBuilderTextField(
                            name: 'name',
                            initialValue: widget.data!.name,
                            decoration: InputDecoration(
                              labelText: widget.type == "Hutang" ||
                                      widget.type == "Piutang"
                                  ? "Nama ${widget.type}"
                                  : "Nama menu",
                              labelStyle: const TextStyle(
                                fontSize: 14,
                              ),
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
                              FormBuilderValidators.min(4),
                            ]),
                            keyboardType: TextInputType.text,
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          FormBuilderTextField(
                            name: 'notes',
                            initialValue: widget.data!.notes,
                            decoration: InputDecoration(
                              labelText: 'Keterangan',
                              labelStyle: const TextStyle(
                                fontSize: 14,
                              ),
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
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            minLines: 3,
                            maxLines: 5,
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          widget.type == "Hutang" || widget.type == "Piutang"
                              ? Container()
                              : Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: FormBuilderTextField(
                                    name: 'defaultValue',
                                    initialValue: int.parse(
                                                (widget.data!.defaultValue == ''
                                                        ? '0'
                                                        : widget.data!
                                                            .defaultValue) ??
                                                    "0") >
                                            0
                                        ? _formatter.formatString(widget
                                            .data!.defaultValue
                                            .toString())
                                        : null,
                                    decoration: InputDecoration(
                                      labelText: 'Nilai default (opsional)',
                                      labelStyle: const TextStyle(
                                        fontSize: 14,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 4,
                                        horizontal: 12,
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [_formatter],
                                  ),
                                ),
                          ((widget.type == "Hutang" ||
                                      widget.type == "Piutang") &&
                                  (widget.data!.name != null &&
                                      widget.data!.name != ""))
                              ? Container(
                                  margin: const EdgeInsets.only(
                                    top: 0,
                                    bottom: 8,
                                  ),
                                  child: FormBuilderDateTimePicker(
                                    name: 'deadline',
                                    inputType: InputType.date,
                                    initialDate:
                                        DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS")
                                            .parse(widget.data!.deadline ?? ""),
                                    initialValue:
                                        DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS")
                                            .parse(widget.data!.deadline ?? ""),
                                    format: DateFormat('dd-MM-yyyy'),
                                    decoration: InputDecoration(
                                      labelText: 'Jatuh tempo',
                                      labelStyle: const TextStyle(
                                        fontSize: 14,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
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
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                    ]),
                                  ),
                                )
                              : const SizedBox(),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: !globalBloc.loading
                                  ? () async {
                                      if (formKey.currentState!.validate()) {
                                        formKey.currentState!.save();
                                        globalBloc.loading = true;
                                        await TbMenu().update(
                                          widget.data!.id ?? 0,
                                          widget.data!.type ?? "",
                                          formKey.currentState!.value,
                                        );
                                        if (widget.onSuccess != null) {
                                          await widget.onSuccess();
                                        }
                                        globalBloc.loading = false;
                                        Navigator.pop(context);
                                      } else {
                                        globalBloc.loading = false;
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(32.0),
                                  ),
                                ),
                              ),
                              child: !globalBloc.loading
                                  ? const Text(
                                      "UPDATE",
                                      style: TextStyle(
                                        fontSize: 12,
                                        letterSpacing: 0.6,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                      ),
                                    )
                                  : const Text(
                                      "Tunggu sebentar...",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                        color: Colors.grey,
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
            ],
          ),
        ),
      ),
    );
  }
}
