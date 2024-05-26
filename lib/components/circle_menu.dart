import 'package:keuangan/components/circle_custom.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';

// ignore: must_be_immutable
class CircleMenu extends StatelessWidget {
  CircleMenu({
    super.key,
    required this.icon,
    required this.iconSize,
    required this.name,
    this.nameSize = 11,
    required this.gradient,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final double iconSize;
  final String name;
  double nameSize = 11;
  final LinearGradient gradient;
  final Callback onTap;
  bool active;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: <Widget>[
            CircleCustom(
              height: 50,
              icon: icon,
              iconSize: iconSize,
              gradient: gradient,
              active: active,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              name,
              style: TextStyle(
                fontSize: nameSize,
                color: active ? Colors.black87 : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
