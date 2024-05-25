import 'dart:async';

import 'package:form_builder_phone_field/form_builder_phone_field.dart';
import 'package:get/get.dart';
import 'package:keuangan/pages/auth/register_page.dart';
import 'package:keuangan/pages/dashboard/dashboard_page.dart';
import 'package:keuangan/pages/splash_out/splash_out_page.dart';
import 'package:keuangan/providers/global_bloc.dart';
import 'package:keuangan/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  int touchedIndex = -1;
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final _globalBloc = context.watch<GlobalBloc>();
    return WillPopScope(
      onWillPop: () {
        // Restart.restartApp();
        Get.offAll(() => const SplashOutPage());
        return Future.value(false);
      },
      child: Stack(
        children: [
          Scaffold(
            resizeToAvoidBottomInset: false,
            body: Container(
              constraints: const BoxConstraints.expand(),
              child: SafeArea(
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 0,
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.5,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                "keuangan/assets/images/revenue_small.png"),
                            fit: BoxFit.fitWidth,
                            alignment: Alignment.bottomLeft,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 20,
                      child: Row(
                        children: const <Widget>[
                          Text(
                            "@2022",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
              constraints: const BoxConstraints.expand(),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: const BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                              "keuangan/assets/images/logo.png"),
                                          fit: BoxFit.cover,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      "KEUANGAN",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 24,
                            horizontal: 32,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                FormBuilderPhoneField(
                                  name: 'username',
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
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.min(4),
                                  ]),
                                  keyboardType: TextInputType.text,
                                  obscureText: true,
                                  enabled: !_globalBloc.loading,
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType.fade,
                                        child: const ForgotPasswordPage(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Lupa password?",
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 17),
                                Material(
                                  elevation: 4,
                                  borderRadius: BorderRadius.circular(40),
                                  animationDuration:
                                      const Duration(milliseconds: 500),
                                  child: InkWell(
                                    onTap: !_globalBloc.loading
                                        ? () async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              _formKey.currentState!.save();
                                              _globalBloc.loading = true;
                                              final _resp = await AuthService()
                                                  .login(
                                                      context,
                                                      _formKey
                                                          .currentState!.value);
                                              if (_resp) {
                                                Timer(
                                                    const Duration(
                                                        milliseconds: 1000),
                                                    () {
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
                                                        milliseconds: 1000),
                                                    () {
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
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
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
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () {
                                        Get.offAll(() => const SplashOutPage());
                                      },
                                      child: Container(
                                        color: Colors.white,
                                        margin: const EdgeInsets.only(left: 6),
                                        child: Image.asset(
                                          'assets/icon.png',
                                          height: 40,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
