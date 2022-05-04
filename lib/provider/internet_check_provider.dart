import 'package:flutter/cupertino.dart';
import 'package:midika/common/functions.dart';

class InternetProvider extends ChangeNotifier {
  bool is_internet = false;

  checkInternet() async {
    is_internet = await Functions.checkConnectivity();
    notifyListeners();
  }
}
