import 'dart:async';

import 'package:form_builder_phone_field/form_builder_phone_field.dart';
import 'package:keuangan/pages/dashboard/dashboard_page.dart';
import 'package:keuangan/providers/global_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int touchedIndex = -1;
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final _globalBloc = context.watch<GlobalBloc>();

    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        // decoration: const BoxDecoration(
        //   image: DecorationImage(
        //     image: AssetImage("keuangan/assets/images/vlead.png"),
        //     fit: BoxFit.cover,
        //   ),
        // ),
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
                                children: <Widget>[
                                  Center(
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: const BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                              "keuangan/assets/images/logo.png"),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    "Daftar Akun",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    "Silahkan lengkapi data anda dibawah ini",
                                    style: TextStyle(
                                      color: Colors.black,
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
                                labelText: 'Password',
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
                              name: 'verify_password',
                              decoration: InputDecoration(
                                labelText: 'Ulangi Password',
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
                                              .register(context,
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
                                    horizontal: 16,
                                    vertical: 16,
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
                                            "KLIK UNTUK DAFTAR",
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
                                const Text(
                                  "Sudah punya akun?",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    "Login",
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
