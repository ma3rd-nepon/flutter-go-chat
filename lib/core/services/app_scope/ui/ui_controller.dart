import 'package:flutter/material.dart';

class UIController extends ChangeNotifier {
  bool _barHidden = false;

  bool get barHidden => _barHidden;

  void toggleBar(bool? value) {
    if (value == null) {
      _barHidden = !_barHidden;
      return;
    }
    _barHidden = value;

    notifyListeners();
  }
}
