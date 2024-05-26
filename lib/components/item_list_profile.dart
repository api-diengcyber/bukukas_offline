import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ItemListProfile extends StatelessWidget {
  ItemListProfile({
    super.key,
    this.icon,
    required this.text,
    this.fontWeight = FontWeight.normal,
    this.color = Colors.black87,
    this.onTap,
  });

  IconData? icon;
  String text;
  FontWeight fontWeight;
  Color color;
  GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon != null
                ? Icon(
                    icon,
                    color: color,
                  )
                : const SizedBox(),
            icon != null
                ? const SizedBox(
                    width: 8,
                  )
                : const SizedBox(),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: fontWeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
