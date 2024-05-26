import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CircleCustom extends StatelessWidget {
  CircleCustom({
    super.key,
    required this.height,
    this.icon,
    this.iconSize,
    required this.gradient,
    this.active = false,
  });

  final double height;
  final IconData? icon;
  final double? iconSize;
  final LinearGradient gradient;
  bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: height,
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.white,
        shape: BoxShape.circle,
        gradient: active ? gradient : null,
      ),
      child: icon != null
          ? Center(
              child: Icon(
                icon,
                size: iconSize,
                color: active ? Colors.white : Colors.black54,
              ),
            )
          : const SizedBox(),
    );
  }
}
