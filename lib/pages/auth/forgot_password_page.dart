import 'dart:async';

import 'package:form_builder_phone_field/form_builder_phone_field.dart';
import 'package:keuangan/pages/dashboard/dashboard_page.dart';
import 'package:keuangan/providers/global_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  int touchedIndex = -1;
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final _globalBloc = context.watch<GlobalBloc>();

    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 1),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  color: Colors.white,
                  child: Center(
                    child: SingleChildScrollView(
                      child: FormBuilder(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 8,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const <Widget>[
                                  SizedBox(height: 24),
                                  Text(
                                    "Lupa Password",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            FormBuilderPhoneField(
                              name: 'phone',
                              decoration: InputDecoration(
                                labelText: 'Nomor HP',
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 7,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                    color: Colors.black54,
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                    color: Colors.black54,
                                    width: 1,
                                  ),
                                ),
                              ),
                              dialogTitle: const Text('Pilih Kode Negara'),
                              priorityListByIsoCode: const ['ID'],
                              countryFilterByIsoCode: const ['ID'],
                              defaultSelectedCountryIsoCode: 'ID',
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.numeric(),
                                FormBuilderValidators.min(7),
                              ]),
                              keyboardType: TextInputType.number,
                              enabled: !_globalBloc.loading,
                            ),
                            const SizedBox(height: 12),
                            FormBuilderTextField(
                              name: 'password',
                              decoration: InputDecoration(
                                labelText: 'Password baru',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.min(4),
                              ]),
                              keyboardType: TextInputType.text,
                              obscureText: true,
                              enabled: !_globalBloc.loading,
                            ),
                            const SizedBox(height: 12),
                            FormBuilderTextField(
                              name: 'confirm_password',
                              decoration: InputDecoration(
                                labelText: 'Ulangi Password baru',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.min(4),
                              ]),
                              keyboardType: TextInputType.text,
                              obscureText: true,
                              enabled: !_globalBloc.loading,
                            ),
                            const SizedBox(height: 30),
                            Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(40),
                              animationDuration:
                                  const Duration(milliseconds: 500),
                              child: InkWell(
                                onTap: !_globalBloc.loading
                                    ? () async {
                                        if (_formKey.currentState!.validate()) {
                                          _formKey.currentState!.save();
                                          _globalBloc.loading = true;
                                          final _resp = await AuthService()
                                              .forgotPassword(context,
                                                  _formKey.currentState!.value);
                                          if (_resp) {
                                            Timer(
                                                const Duration(
                                                    milliseconds: 1000), () {
                                              _globalBloc.loading = false;
                                              Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (ctx) =>
                                                        const DashboardPage(),
                                                  ),
                                                  (Route<dynamic> route) =>
                                                      false);
                                            });
                                          } else {
                                            _globalBloc.loading = false;
                                          }
                                        } else {
                                          _globalBloc.loading = false;
                                        }
                                      }
                                    : null,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: !_globalBloc.loading
                                        ? Colors.amber
                                        : Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: Center(
                                    child: !_globalBloc.loading
                                        ? const Text(
                                            "SUBMIT",
                                            style: TextStyle(
                                              letterSpacing: 0.6,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          )
                                        : const Text(
                                            "Tunggu sebentar...",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.grey,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            const Divider(),
                            const SizedBox(
                              height: 12,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    "Kembali",
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 1),
            ],
          ),
        ),
      ),
    );
  }
}
