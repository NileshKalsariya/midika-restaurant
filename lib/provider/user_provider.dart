import 'package:flutter/cupertino.dart';
import 'package:midika/models/restaurant_model.dart';

class RestaurantProvider extends ChangeNotifier {
  Restaurant restaurantModel = Restaurant();
  Restaurant? get GetRestaurant => restaurantModel;
  setUser({required Restaurant currentUser}) {
    restaurantModel = currentUser;
    print("user added to provider");
    notifyListeners();
  }
}
