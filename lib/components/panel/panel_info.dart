import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keuangan/pages/splash_out/splash_out_page.dart';

class PanelInfo extends StatefulWidget {
  const PanelInfo({Key? key}) : super(key: key);

  @override
  State<PanelInfo> createState() => _PanelInfoState();
}

class _PanelInfoState extends State<PanelInfo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 0.2,
            offset: const Offset(0, 0.1), // changes position of shadow
          ),
        ],
      ),
    );
  }
}
