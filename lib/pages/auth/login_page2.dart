import 'dart:async';

import 'package:keuangan/pages/auth/register_page.dart';
import 'package:keuangan/pages/dashboard/dashboard_page.dart';
import 'package:keuangan/providers/global_bloc.dart';
import 'package:keuangan/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class LoginPage2 extends StatefulWidget {
  const LoginPage2({Key? key}) : super(key: key);

  @override
  State<LoginPage2> createState() => _LoginPage2State();
}

class _LoginPage2State extends State<LoginPage2> {
  int touchedIndex = -1;
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final _globalBloc = context.watch<GlobalBloc>();

    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/vlead.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "KEUANGAN",
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 26),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(137, 255, 255, 255),
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 16,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      width: double.infinity,
                      child: FormBuilder(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const <Widget>[
                                  Text(
                                    "Login",
                                    style: TextStyle(
                                      letterSpacing: 0.7,
                                      color: Colors.black87,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Isikan akun anda dibawah ini",
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            FormBuilderTextField(
                              name: 'username',
                              decoration: InputDecoration(
                                labelText: 'Username',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.min(4),
                                FormBuilderValidators.max(255),
                              ]),
                              keyboardType: TextInputType.text,
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
                                              .login(context,
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
                                            Timer(
                                                const Duration(
                                                    milliseconds: 1000), () {
                                              _globalBloc.loading = false;
                                            });
                                          }
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
                                            "MASUK",
                                            style: TextStyle(
                                              letterSpacing: 0.7,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
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
                                Text(
                                  "Belum punya akun?",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType.fade,
                                        child: const RegisterPage(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Daftar",
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                          ],
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
    );
  }
}
