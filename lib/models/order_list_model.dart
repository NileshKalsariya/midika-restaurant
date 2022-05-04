import 'package:midika/models/user_model.dart';

import 'order_model.dart';

class OrderListModel {
  Order? orderModel;
  UserModel? userModel;

  OrderListModel({
    this.userModel,
    this.orderModel,
  });
}
