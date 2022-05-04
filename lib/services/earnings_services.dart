import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:midika/utils/firebase_references.dart';

class TotalEarningsClass {
  CollectionReference order_collection =
      FirebaseFirestore.instance.collection(FirebaseReferences.orders);
  Stream<QuerySnapshot> getTotalEarningCount({String? restaurantid}) {
    return order_collection
        .where('order_status', isEqualTo: 2)
        .where('restaurant_id', isEqualTo: restaurantid)
        .snapshots();
  }

  Stream<QuerySnapshot> fetchallOrdersByrange(
      {required String restaurantId,
      required String startDate,
      required String endDate}) {
    return order_collection
        .where("restaurant_id", isEqualTo: restaurantId)
        // .where("order_date", isEqualTo: orderDate)
        .where('order_status', isEqualTo: 2)
        .where('order_date', isGreaterThanOrEqualTo: startDate)
        .where('order_date', isLessThanOrEqualTo: endDate)
        .orderBy('order_date', descending: true)
        .snapshots();
  }
}
