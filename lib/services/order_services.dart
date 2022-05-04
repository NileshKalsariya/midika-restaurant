import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:midika/utils/firebase_references.dart';

class DashboardServices {
  static final CollectionReference _ordersCollection =
      FirebaseFirestore.instance.collection(FirebaseReferences.orders);
  Stream<QuerySnapshot> fetchOrdersByDate(
      {required String restaurantId, required String orderDate}) {
    return _ordersCollection
        .where("restaurant_id", isEqualTo: restaurantId)
        .where("order_date", isEqualTo: orderDate)
        .orderBy('added_on', descending: true)
        .snapshots();
  }

  static Future<List> getFiveDayOrder({
    required restaurantId,
    required day1,
    required day2,
    required day3,
    required day4,
    required day5,
  }) async {
    List arr = [day1, day2, day3, day4, day5];
    List orderCount = [];
    for (int i = 0; i < arr.length; i++) {
      await _ordersCollection
          .where("restaurant_id", isEqualTo: restaurantId)
          .where("order_date", isEqualTo: arr[i])
          .where('order_status', isEqualTo: 2)
          .orderBy('added_on', descending: true)
          .get()
          .then((value) {
        orderCount.add(value.docs.length);
      });
    }
    return orderCount;
  }
}
