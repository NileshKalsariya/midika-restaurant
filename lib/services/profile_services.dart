import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:midika/models/operational_hours_model.dart';
import 'package:midika/models/restaurant_model.dart';
import 'package:midika/utils/firebase_references.dart';

class ProfileService {
  static final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection(FirebaseReferences.user_collection);

  ///set user
  static Future setUser(Restaurant restaurantModel) {
    return _userCollection
        .doc(restaurantModel.restaurantId)
        .set(restaurantModel.toJson());
  }

  ///get user
  Future<Restaurant> getUser({String? uid}) {
    return _userCollection.doc(uid).get().then((value) {
      print("value ::::: $value");
      DocumentSnapshot data = value;

      return Restaurant.fromJson(data);
    });
  }

  static Future<Restaurant> getUserById({required id}) {
    return _userCollection.doc(id).get().then((value) {
      DocumentSnapshot data = value;
      return Restaurant.fromJson(data);
    });
  }

  static Future<Restaurant> getUserByEmailID({required email}) {
    return _userCollection
        .where('restaurant_email', isEqualTo: email)
        .get()
        .then((value) {
      print(value.docs[0]);
      DocumentSnapshot data = value.docs[0];
      return Restaurant.fromJson(data);
    });
  }

  static Future<Restaurant> getUserByPhone({required phone}) {
    return _userCollection
        .where('restaurant_phone_number', isEqualTo: phone)
        .get()
        .then((value) {
      DocumentSnapshot data = value.docs[0];
      return Restaurant.fromJson(data);
    });
  }

  ///update user
  Future updateUser(Restaurant restaurantModel) {
    return _userCollection
        .doc(restaurantModel.restaurantId)
        .update(restaurantModel.toJson());
  }

  ///delete user
  deleteUser() {
    _userCollection.doc(FirebaseAuth.instance.currentUser!.uid).delete();
  }

  static Future checkUserByEmail(String email) {
    var snapshot =
        _userCollection.where("restaurant_email", isEqualTo: email).get();
    return snapshot;
  }

  static Future checkUserByMobile(String phone) {
    var snapshot = _userCollection
        .where("restaurant_phone_number", isEqualTo: phone)
        .get();
    return snapshot;
  }

  ///fetch operational hours
  Stream<QuerySnapshot> fetchOperationalHours({required String restaurantId}) =>
      _userCollection
          .doc(restaurantId)
          .collection('operational_hours')
          .orderBy('number', descending: false)
          .snapshots();

  /// change operational hours
  Future<void> changeOperationalHours({
    required OperationalHours operationalHours,
  }) async {
    try {
      await _userCollection
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('operational_hours')
          .doc(operationalHours.day)
          .update(operationalHours.toJson());

      print("hours updated Done !");
    } catch (Exception) {
      Exception.toString();
    }
  }
}
