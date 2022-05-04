import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/models/restaurant_model.dart';
import 'package:midika/models/restaurant_notification.dart';
import 'package:midika/provider/user_provider.dart';
import 'package:midika/services/notification_service.dart';
import 'package:midika/utils/asset_paths.dart';
import 'package:midika/utils/colors.dart';
import 'package:midika/utils/strings.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool isEmpty = true;
  Restaurant? restaurant;
  final template = DateFormat('dd, MMMM yyyy - hh:mm a');
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    Timer(Duration(seconds: 1), () {
      isEmpty = false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    restaurant =
        Provider.of<RestaurantProvider>(context, listen: true).GetRestaurant;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: white,
          title: appText(txtNotification,
              fontWeight: FontWeight.w500, fontSize: 13.sp),
          leading: GestureDetector(
            child: Icon(Icons.arrow_back_ios_new, color: black),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: notificationServices.getNotifications(
              userId: restaurant!.restaurantId!),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              List? docList = snapshot.data!.docs;
              print("length ${docList.length}");

              if (docList.length != 0) {
                return ListView.builder(
                  itemCount: docList.length,
                  itemBuilder: (context, index) {
                    RestaurantNotification notification =
                        RestaurantNotification.fromJson(docList[index].data());
                    var date = Jiffy(DateTime.fromMillisecondsSinceEpoch(
                            int.tryParse(notification.addedOn.toString())!))
                        .fromNow();
                    return Column(
                      children: [
                        ListTile(
                          leading: notification.notificationType == null
                              ? Image.asset(
                                  iconNoti,
                                  width: 50,
                                  height: 50,
                                )
                              : notification.notificationType == 'profile'
                                  ? Image.asset(
                                      icon_update_profile,
                                      width: 50,
                                      height: 50,
                                    )
                                  : Image.asset(
                                      icon_order_cancel,
                                      width: 50,
                                      height: 50,
                                    ),
                          title: Text(
                            notification.notificationMessage!,
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // SizedBox(
                              //   height: 5,
                              // ),
                              // Text(
                              //   "Order Id - ${notification.orderId!}",
                              //   style: TextStyle(
                              //       color: Colors.green,
                              //       fontSize: 13,
                              //       fontWeight: FontWeight.w400),
                              // ),
                              Text(
                                date,
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                        // Divider()
                      ],
                    );
                  },
                );
              } else {
                return Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(icon_no_noti,
                          width: MediaQuery.of(context).size.width / 2,
                          height: MediaQuery.of(context).size.height / 6),
                      const SizedBox(height: 20),
                      appText(
                        "$txtItSeemsLikeYouDontHaveAny\n$txtNotificationsYet. $txtCheckBackLater.",
                        style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            height: 1.5),
                      )
                    ],
                  ),
                );
              }
            } else {
              return Container(
                child: Center(
                  child: CircularProgressIndicator(
                    color: appPrimaryColor,
                  ),
                ),
              );
            }
          },
        ));
  }
}
