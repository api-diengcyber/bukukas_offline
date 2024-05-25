import 'package:flutter/material.dart';

class SplashscreenBloc extends ChangeNotifier {
  int _splashIndex = 1;
  int get splashIndex => _splashIndex;
  set splashIndex(int val) {
    _splashIndex = val;
    notifyListeners();
  }
}
