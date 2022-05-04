import 'package:flutter/cupertino.dart';
import 'package:midika/models/operational_hours_model.dart';
import 'package:midika/services/profile_services.dart';



class OperationalHoursProvider extends ChangeNotifier {
  bool isLoading = false;

  bool get getLoadingState => isLoading;

  ProfileService _profileService = ProfileService();

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  changeOperationalHours(
      {required BuildContext context,
        required OperationalHours operationalHours}) async {
    setLoading(true);

    await _profileService.changeOperationalHours(
        operationalHours: operationalHours);
    print("Changed");

    setLoading(false);

    notifyListeners();
  }
}
