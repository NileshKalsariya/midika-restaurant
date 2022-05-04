import 'package:flutter/cupertino.dart';

class ScreenProvier extends ChangeNotifier {
  int currentIndex = 1;
  get getcurrentIndex => currentIndex;
  setCurrentIndex(ind) {
    currentIndex = ind;
    notifyListeners();
  }
}
