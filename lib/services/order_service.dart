import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:midika/models/order_model.dart';
import 'package:midika/models/user_model.dart';
import 'package:midika/models/user_notification_model.dart';
import 'package:midika/provider/user_provider.dart';
import 'package:midika/services/notification_service.dart';
import 'package:midika/utils/firebase_references.dart';
import 'package:provider/provider.dart';

class OrderService {
  CollectionReference orders_collection =
      FirebaseFirestore.instance.collection(FirebaseReferences.orders);

  Stream<QuerySnapshot> getAllOrders({required BuildContext context}) {
    var restaurant_id = Provider.of<RestaurantProvider>(context, listen: false)
        .restaurantModel
        .restaurantId;
    return orders_collection
        .where('restaurant_id', isEqualTo: restaurant_id)
        // .where('order_status', whereIn: [0])
        .where('order_status', isNull: true)
        .orderBy('added_on', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getAcceptedOrder({required BuildContext context}) {
    var restaurant_id = Provider.of<RestaurantProvider>(context, listen: false)
        .restaurantModel
        .restaurantId;
    return orders_collection
        .where('restaurant_id', isEqualTo: restaurant_id)
        .where('order_status', isEqualTo: 1)
        .orderBy('added_on', descending: true)
        .snapshots();
  }

  static Future<UserModel> getUserById({required String userId}) async {
    return await FirebaseFirestore.instance
        .collection(FirebaseReferences.users_customer)
        .doc(userId)
        .get()
        .then((value) {
      Map<String, dynamic> data = value.data() as Map<String, dynamic>;
      UserModel currentUser = UserModel.fromJson(data);
      return currentUser;
    });
  }

  static Stream<QuerySnapshot> getItemCount({required String orderId}) {
    CollectionReference orders_collection =
        FirebaseFirestore.instance.collection(FirebaseReferences.orders);
    return orders_collection.doc(orderId).collection('items').snapshots();
  }

  Stream<QuerySnapshot> getIems({required String orderId}) {
    return orders_collection.doc(orderId).collection('items').snapshots();
  }

  // Stream<QuerySnapshot> getOrderList({required BuildContext context}) {
  //   var restaurant_id = Provider.of<RestaurantProvider>(context, listen: false)
  //       .restaurantModel
  //       .restaurantId;
  //   orders_collection
  //       .where('restaurant_id', isEqualTo: restaurant_id)
  //       .snapshots()
  //       .listen((event) {
  //     print(event.docs.length);
  //   });
  // }

  Future<int> changeOrderStatusToAccept(
      {required Order orderModel, required BuildContext context}) async {
    var restaurant_Name =
        Provider.of<RestaurantProvider>(context, listen: false)
            .restaurantModel
            .restaurantName;
    var title = "Order Accepted - ${restaurant_Name}";
    var mainData =
        "Thank you for your recent order from our ${restaurant_Name} restaurant. We are pleased to inform you that the items on the way to you.";
    int status = 0;

    UserNotification user_notification = new UserNotification(
        orderId: orderModel.orderId,
        addedOn: DateTime.now().millisecondsSinceEpoch.toString(),
        notificationMessage: 'Order Accepted',
        userId: orderModel.userId);

    await orderAcceptedNotification(
        notification: user_notification, userId: orderModel.userId!);

    await orders_collection
        .doc(orderModel.orderId)
        .update({'order_status': 1}).whenComplete(
      () {
        FirebaseFirestore.instance
            .collection('users_customer')
            .where('uid', isEqualTo: orderModel.userId)
            .get()
            .then(
          (value) async {
            if (value != '') {
              Map<String, dynamic> userData = value.docs[0].data();
              String userId = userData['device_token'];

              bool data = await NotificationServices.sendNotifications(
                  userToken: [userId], title: title, mainData: mainData);
            }
          },
        );
        status = 1;
      },
    );
    return status;
  }

  Future<int> changeOrderStatusToCancel({required Order orderModel}) async {
    int status = 0;
    await orders_collection
        .doc(orderModel.orderId)
        .update({'order_status': 0}).whenComplete(() {
      status = 1;
    });
    return status;
  }

  Future<int> changeOrderStatusToDeliver(
      {required Order orderModel, required BuildContext context}) async {
    int status = 0;
    var restaurant_Name =
        Provider.of<RestaurantProvider>(context, listen: false)
            .restaurantModel
            .restaurantName;

    UserNotification user_notification = new UserNotification(
        orderId: orderModel.orderId,
        addedOn: DateTime.now().millisecondsSinceEpoch.toString(),
        notificationMessage: 'Order Deliverd',
        userId: orderModel.userId);

    await orderAcceptedNotification(
        notification: user_notification, userId: orderModel.userId!);

    await orders_collection
        .doc(orderModel.orderId)
        .update({'order_status': 2}).whenComplete(
      () {
        status = 1;

        var title = "Order Deliverd - ${restaurant_Name}";
        var mainData = "Your order deliverd  by ${restaurant_Name}";

        FirebaseFirestore.instance
            .collection('users_customer')
            .where('uid', isEqualTo: orderModel.userId)
            .get()
            .then((value) async {
          if (value != '') {
            Map<String, dynamic> userData = value.docs[0].data();
            String userId = userData['device_token'];

            bool data = await NotificationServices.sendNotifications(
                userToken: [userId], title: title, mainData: mainData);
          }
        });
      },
    );
    return status;
  }

  static Future<void> orderAcceptedNotification({
    required UserNotification notification,
    required String userId,
  }) async {
    await FirebaseFirestore.instance
        .collection(FirebaseReferences.users_customer)
        .doc(userId)
        .collection('notification')
        .doc()
        .set(notification.toJson());
  }
}
