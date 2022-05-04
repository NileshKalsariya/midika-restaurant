import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:midika/models/restaurant_notification.dart';
import 'package:midika/utils/firebase_references.dart';

class NotificationServices {
  Stream<QuerySnapshot> getNotifications({required String userId}) =>
      FirebaseFirestore.instance
          .collection(FirebaseReferences.user_collection)
          .doc(userId)
          .collection(FirebaseReferences.notification)
          .orderBy('added_on', descending: true)
          .snapshots();

  static Future<bool> sendNotifications({
    List<String>? userToken,
    String? title,
    String? mainData,
    String? message,
  }) async {
    print("n NOttiii" + userToken.toString());

    const postUrl = 'https://fcm.googleapis.com/fcm/send';
    final data = {
      "registration_ids": userToken,
      "notification": {
        "title": "${title}",
        "body": mainData,
      },
      "android": {
        "notification": {"channel_id": "channel_id_1"}
      },
      "data": {
        "action": message,
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
      }
    };
    final headers = {
      'content-type': 'application/json',
      'Authorization':
          'key=AAAAoV83PyI:APA91bEtWOtdPErQJ8uPx4JJTma_P9sOao0bsqxrsBJiKU4lnfdY2yA98fmucBp3urCC5emHkRIAfF019_HXUJfJ8ZGVNkUVAwodqFC9D1JyZ-A3PYtVf1UuCWHGLY43HL_w_r1JAEmk'
      // 'key=YOUR_SERVER_KEY'
    };

    final response = await http.post(Uri.parse(postUrl),
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);
    print('Push Notification called');
    print("Response is--->" + response.toString());
    print(response.body);
    if (response.statusCode == 200) {
      // on success do sth
      print('test ok push FCM');
      return true;
    } else {
      print(' FCM error' + response.statusCode.toString());
      // on failure do sth
      return false;
    }
  }

  Future profileUpdate({required String RestaurantId}) async {
    RestaurantNotification noti = new RestaurantNotification();
    noti.notificationType = 'profile';
    noti.orderId = null;
    noti.addedOn = DateTime.now().millisecondsSinceEpoch.toString();
    noti.userId = null;
    noti.notificationMessage = 'Profile Updated';

    await FirebaseFirestore.instance
        .collection(FirebaseReferences.user_collection)
        .doc(RestaurantId)
        .collection(FirebaseReferences.notification)
        .add(noti.toJson());
  }

  Future orderCancel(
      {required String RestaurantId,
      required String orderId,
      required String userId}) async {
    RestaurantNotification noti = new RestaurantNotification();
    noti.notificationType = 'order_cancel';
    noti.orderId = orderId;
    noti.addedOn = DateTime.now().millisecondsSinceEpoch.toString();
    noti.userId = userId;
    noti.notificationMessage = 'order cancelled';

    String? resId;
    String? restName;
    FirebaseFirestore.instance
        .collection('users_customer')
        .where('uid', isEqualTo: userId)
        .get()
        .then((value) async {
      if (value != '') {
        await FirebaseFirestore.instance
            .collection(FirebaseReferences.user_collection)
            .doc(RestaurantId)
            .get()
            .then((value) {
          Map<String, dynamic> mydata = value.data() as Map<String, dynamic>;

          resId = mydata['device_token'];
          restName = mydata['restaurant_name'] ?? 'Midika Restaurant';
        });

        Map<String, dynamic> userData = value.docs[0].data();
        String userId = userData['device_token'];

        bool data = await NotificationServices.sendNotifications(
            userToken: [userId, resId!],
            title: 'order cancelled',
            mainData: 'order cancelled from ${restName}');
      }
    });

    await FirebaseFirestore.instance
        .collection(FirebaseReferences.user_collection)
        .doc(RestaurantId)
        .collection(FirebaseReferences.notification)
        .add(noti.toJson());
  }
}
