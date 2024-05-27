import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class PanelSplash2 extends StatefulWidget {
  const PanelSplash2({super.key});

  @override
  State<PanelSplash2> createState() => _PanelSplash2State();
}

class _PanelSplash2State extends State<PanelSplash2> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SizedBox(
          height: 250,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/logo.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                child: AnimatedTextKit(
                  animatedTexts: [
                    WavyAnimatedText(
                      'Memuat...',
                      speed: const Duration(milliseconds: 100),
                    ),
                  ],
                  isRepeatingAnimation: true,
                  repeatForever: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
