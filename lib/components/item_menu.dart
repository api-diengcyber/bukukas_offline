import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ItemMenu extends StatelessWidget {
  ItemMenu({
    super.key,
    required this.icon,
    required this.text,
    this.active = false,
    this.activeColor = Colors.black,
    this.activeIconColor = Colors.black,
    this.activeGradient,
    this.splashColor = Colors.amber,
    this.onTap,
  });

  final IconData icon;
  final String text;
  bool active;
  Color activeColor;
  Color activeIconColor;
  LinearGradient? activeGradient;
  Color? splashColor;
  VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.transparent,
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
        child: InkWell(
          splashColor: splashColor,
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                    gradient: active ? activeGradient : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 0,
                        blurRadius: 0.2,
                        offset:
                            const Offset(0, 0.1), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: active ? activeIconColor : Colors.black38,
                    size: 25,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: active ? activeColor : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
