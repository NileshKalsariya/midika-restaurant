import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:midika/models/qr_code_model.dart';
import 'package:midika/models/restaurant_model.dart';
import 'package:midika/provider/user_provider.dart';
import 'package:midika/utils/firebase_references.dart';
import 'package:provider/provider.dart';

class QrCodeServices extends ChangeNotifier {
  bool is_loading = false;

  setLoaderState(bool value) {
    is_loading = value;
    notifyListeners();
  }

  CollectionReference qr_collection = FirebaseFirestore.instance
      .collection(FirebaseReferences.qr_code_collection);

  Future<void> saveQrCodeToFirebase({
    required QrCodeModel qrcode,
    required BuildContext context,
    required int table_no,
    String qr_code_id = '',
    bool edit_mode = false,
  }) async {
    final restaurant_id =
        Provider.of<RestaurantProvider>(context, listen: false)
            .GetRestaurant!
            .restaurantId;

    if (edit_mode == true && qr_code_id != '') {
      await qr_collection.doc(qr_code_id).delete();
      DocumentReference doc = qr_collection.doc();
      qrcode.qrCodeId = doc.id;
      qrcode.addedOn = DateTime.now().millisecondsSinceEpoch.toString();
      qrcode.restaurantId = restaurant_id;
      qrcode.tableNo = table_no;

      await doc.set(qrcode.toJson(qrcode));
      notifyListeners();
    } else {
      DocumentReference doc = qr_collection.doc();
      qrcode.qrCodeId = doc.id;
      qrcode.addedOn = DateTime.now().millisecondsSinceEpoch.toString();
      qrcode.restaurantId = restaurant_id;
      qrcode.tableNo = table_no;

      await doc.set(qrcode.toJson(qrcode));
      notifyListeners();
    }
  }

  Stream<QuerySnapshot> FetchQrCode({required BuildContext context}) {
    // final uid = FirebaseAuth.instance.currentUser!.uid;
    Restaurant? restaurant =
        Provider.of<RestaurantProvider>(context, listen: false).GetRestaurant;
    print('fetch qrcode from' + restaurant!.restaurantId.toString());
    return qr_collection
        .where('restaurant_id', isEqualTo: restaurant.restaurantId)
        .orderBy('added_on', descending: true)
        .snapshots();
  }

  Future deleteAllQrcode({required BuildContext context}) async {
    Restaurant? restaurant =
        Provider.of<RestaurantProvider>(context, listen: false).GetRestaurant;

    return await qr_collection
        .where('restaurant_id', isEqualTo: restaurant!.restaurantId)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        qr_collection.doc(element.id).delete();
      });
    });
  }
}
