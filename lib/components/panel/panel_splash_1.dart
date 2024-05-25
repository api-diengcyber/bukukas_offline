import 'package:flutter/material.dart';

class PanelSplash1 extends StatefulWidget {
  const PanelSplash1({Key? key}) : super(key: key);

  @override
  State<PanelSplash1> createState() => _PanelSplash1State();
}

class _PanelSplash1State extends State<PanelSplash1> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(
                    width: 32,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/images/logo.png"),
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
                  const VerticalDivider(
                    color: Colors.grey,
                  ),
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(height: 5),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 32,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
