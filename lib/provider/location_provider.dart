import 'package:flutter/cupertino.dart';
import 'package:midika/models/location_mode.dart';

class LocationProvider extends ChangeNotifier {
  bool is_loading = false;
  get getLoaderState => is_loading;

  LocationModel currentLocationModel = LocationModel();
  LocationModel get getLocationModel => currentLocationModel;

  setLocationModel(LocationModel location) {
    currentLocationModel = location;
    notifyListeners();
  }

  changeLoaderState(bool loaderState) {
    is_loading = loaderState;
    notifyListeners();
  }
}
