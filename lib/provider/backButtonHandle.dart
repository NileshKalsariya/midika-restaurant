import 'package:flutter/cupertino.dart';

class BackButtonHandle extends ChangeNotifier {
  Widget? backScreen;

  setBackScreen(Widget widget) {
    backScreen = widget;
    notifyListeners();
  }
}
