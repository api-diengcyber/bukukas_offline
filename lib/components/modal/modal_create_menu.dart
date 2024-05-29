import 'package:keuangan/db/model/tb_menu_model.dart';
import 'package:keuangan/db/tb_menu.dart';
import 'package:keuangan/providers/global_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:keuangan/utils/currency.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class CreateMenuModal extends StatefulWidget {
  CreateMenuModal({
    super.key,
    required this.type,
    required this.gradient,
    this.onSuccess,
  });

  final String type;
  LinearGradient gradient;
  dynamic onSuccess;

  @override
  State<CreateMenuModal> createState() => _CreateMenuModalState();
}

class _CreateMenuModalState extends State<CreateMenuModal> {
  final formKey = GlobalKey<FormBuilderState>();

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
                  "Buat menu baru",
                  style: TextStyle(
                    letterSpacing: 0.6,
                    fontSize: 17,
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
                          widget.type != "Hutang" && widget.type != "Piutang"
                              ? Container()
                              : Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: FormBuilderDateTimePicker(
                                    name: 'debtDate',
                                    inputType: InputType.date,
                                    initialDate: DateTime.now(),
                                    initialValue: DateTime.now(),
                                    format: DateFormat('dd-MM-yyyy'),
                                    decoration: InputDecoration(
                                      labelText: 'Tanggal ${widget.type}',
                                      labelStyle: const TextStyle(
                                        fontSize: 16,
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
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                    ]),
                                  ),
                                ),
                          FormBuilderTextField(
                            name: 'name',
                            decoration: InputDecoration(
                              labelText: widget.type == "Hutang" ||
                                      widget.type == "Piutang"
                                  ? "Nama ${widget.type}"
                                  : "Nama menu",
                              labelStyle: const TextStyle(
                                fontSize: 16,
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
                            decoration: InputDecoration(
                              labelText: 'Keterangan',
                              labelStyle: const TextStyle(
                                fontSize: 16,
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
                                    decoration: InputDecoration(
                                      labelText: 'Nilai default (opsional)',
                                      labelStyle: const TextStyle(
                                        fontSize: 16,
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
                                    inputFormatters: [
                                      formatter,
                                    ],
                                  ),
                                ),
                          widget.type == "Hutang" || widget.type == "Piutang"
                              ? Column(
                                  children: <Widget>[
                                    FormBuilderTextField(
                                      name: 'total',
                                      decoration: InputDecoration(
                                        labelText: 'Nominal ${widget.type}',
                                        labelStyle: const TextStyle(
                                          fontSize: 16,
                                        ),
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
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.required(),
                                      ]),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        formatter,
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    FormBuilderDateTimePicker(
                                      name: 'deadline',
                                      inputType: InputType.date,
                                      initialDate: DateTime.now(),
                                      format: DateFormat('dd-MM-yyyy'),
                                      decoration: InputDecoration(
                                        labelText: 'Jatuh Tempo',
                                        labelStyle: const TextStyle(
                                          fontSize: 16,
                                        ),
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
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.required(),
                                      ]),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    FormBuilderTextField(
                                      name: 'paid',
                                      decoration: InputDecoration(
                                        labelText: 'Bayar (opsional)',
                                        labelStyle: const TextStyle(
                                          fontSize: 16,
                                        ),
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
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        formatter,
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                  ],
                                )
                              : Container(),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: !globalBloc.loading
                                  ? () async {
                                      if (formKey.currentState!.validate()) {
                                        formKey.currentState!.save();
                                        globalBloc.loading = true;
                                        await TbMenu().create([
                                          TbMenuModel.fromJson({
                                            ...formKey.currentState!.value,
                                            "type": widget.type,
                                          })
                                        ]);
                                        await widget.onSuccess();
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
                                      "SIMPAN",
                                      style: TextStyle(
                                        fontSize: 15,
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
