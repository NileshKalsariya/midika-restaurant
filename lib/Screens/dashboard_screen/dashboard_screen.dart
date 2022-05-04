import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:midika/Screens/notifications_screen/notification.dart';
import 'package:midika/Screens/total_earning_screen/total_earning_screen.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/models/order_model.dart';
import 'package:midika/models/restaurant_model.dart';
import 'package:midika/provider/user_provider.dart';
import 'package:midika/services/order_services.dart';
import 'package:midika/services/profile_services.dart';
import 'package:midika/utils/asset_paths.dart';
import 'package:midika/utils/colors.dart';
import 'package:midika/utils/strings.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({Key? key}) : super(key: key);

  @override
  _DashBoardScreenState createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  bool switchStatus = false;

  setSwitchState(bool state) {
    setState(() {
      switchStatus = state;
    });
  }

  Restaurant? restaurant;

  final dateTemplate = DateFormat('dd');
  final timeTemplate = DateFormat('hh:mm:ss a');
  DatePickerController _controller = DatePickerController();
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => _controller.animateToSelection());
    return Consumer<RestaurantProvider>(
      builder: (context, data, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: white,
            title: appText(txtDashboard,
                fontWeight: FontWeight.w500, color: black, fontSize: 12.sp),
            centerTitle: true,
            elevation: 1,
            leading: Container(
              padding: EdgeInsets.only(left: 16),
              child: Image.asset(
                appLogo,
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return NotificationScreen();
                      },
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.only(right: 12),
                  child: Image.asset(
                    iconNotification,
                    width: 30,
                  ),
                ),
              )
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        appText(txtAreYouAvailable,
                            fontWeight: FontWeight.w500, fontSize: 12.sp),
                        Switch(
                          value:
                              data.restaurantModel.restaurantIsActive ?? false,
                          onChanged: (val) {
                            setState(
                              () {
                                data.restaurantModel.restaurantIsActive = val;
                                if (val == true) {
                                  Fluttertoast.showToast(
                                      msg: txtRestaurantStatusChangedToActive);
                                } else {
                                  Fluttertoast.showToast(
                                      msg:
                                          txtRestaurantStatusChangedToInActive);
                                }
                                Restaurant currentUser = data.restaurantModel;
                                ProfileService().updateUser(currentUser);
                                setSwitchState(val);
                              },
                            );
                          },
                          activeColor: appPrimaryColor,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Builder(
                          builder: (context) {
                            return DatePicker(
                              DateTime.now().subtract(const Duration(days: 99)),
                              initialSelectedDate: DateTime.now(),
                              selectionColor: appPrimaryColor,
                              selectedTextColor: Colors.white,
                              controller: _controller,
                              // height: 10.h,
                              onDateChange: (date) {
                                setState(
                                  () {
                                    selectedDate = date;
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    StreamBuilder<QuerySnapshot>(
                      stream: DashboardServices().fetchOrdersByDate(
                          restaurantId: data.restaurantModel.restaurantId!,
                          orderDate: DateTime(selectedDate.year,
                                  selectedDate.month, selectedDate.day)
                              .millisecondsSinceEpoch
                              .toString()),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        print(DateTime(selectedDate.year, selectedDate.month,
                                selectedDate.day)
                            .millisecondsSinceEpoch
                            .toString());
                        if (snapshot.hasData && snapshot.data != null) {
                          List? docList = snapshot.data!.docs;
                          double earningToday = 0.0;
                          List<Order> orderList = [];
                          int totalDeliversOrder = 0;
                          for (int i = 0; i < docList.length; i++) {
                            Order order = Order.fromJson(docList[i].data());
                            orderList.add(order);
                            if (order.orderStatus == 2) {
                              earningToday += order.grandTotal;
                              totalDeliversOrder += 1;
                            }
                          }
                          return earningCard(
                            restaurant_id: data.restaurantModel.restaurantId,
                            earningToday: earningToday,
                            orderCount: totalDeliversOrder,
                            orderData: DateTime(selectedDate.year,
                                    selectedDate.month, selectedDate.day)
                                .millisecondsSinceEpoch
                                .toString(),
                          );
                        } else {
                          const SizedBox(
                            height: 30,
                            child: CircularProgressIndicator(
                              color: appPrimaryColor,
                            ),
                          );
                        }
                        return const CircularProgressIndicator(
                          color: appPrimaryColor,
                        );
                      },
                    ),
                    SizedBox(
                      height: 10.sp,
                    ),
                    StreamBuilder(
                      stream: DashboardServices().fetchOrdersByDate(
                          restaurantId: data.restaurantModel.restaurantId!,
                          orderDate: DateTime(selectedDate.year,
                                  selectedDate.month, selectedDate.day)
                              .millisecondsSinceEpoch
                              .toString()),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          List? docList = snapshot.data!.docs;
                          int newOrders = 0;
                          int deliversOrder = 0;
                          double totalTips = 0;

                          List<Order> orderList = [];
                          for (int i = 0; i < docList.length; i++) {
                            Order order = Order.fromJson(docList[i].data());
                            orderList.add(order);
                            if (order.orderStatus == null) {
                              newOrders += 1;
                            } else if (order.orderStatus == 2) {
                              deliversOrder += 1;
                              totalTips += order.tip;
                            }
                          }
                          return orderStatusCard(
                              newOrders: newOrders,
                              orderDelivers: deliversOrder,
                              totalTip: totalTips);
                        } else {
                          const SizedBox(
                            height: 30,
                            child: CircularProgressIndicator(
                              color: appPrimaryColor,
                            ),
                          );
                        }
                        return const CircularProgressIndicator(
                          color: appPrimaryColor,
                        );
                      },
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    // ItemCard(context: context),
                    // SizedBox(
                    //   height: 3.h,
                    // ),
                    // ItemCard(context: context),
                    // SizedBox(
                    //   height: 3.h,
                    // ),
                    // ItemCard(context: context),
                    // SizedBox(
                    //   height: 3.h,
                    // ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget ItemCard({required BuildContext context}) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       // color: Colors.red,
  //       borderRadius: BorderRadius.circular(10),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withOpacity(.5),
  //           offset: const Offset(
  //             3.5,
  //             3.2,
  //           ),
  //           blurRadius: 2.0,
  //           // spreadRadius: 1.0,
  //         ), //BoxShadow
  //         BoxShadow(
  //           color: Colors.white,
  //           offset: const Offset(0.0, 0.0),
  //           blurRadius: 0.0,
  //           spreadRadius: 0.0,
  //         ), //BoxShadow
  //       ],
  //     ),
  //     padding: EdgeInsets.all(10),
  //     height: MediaQuery.of(context).size.height / 4.5,
  //     child: Container(
  //       decoration: BoxDecoration(),
  //       child: Row(
  //         children: [
  //           Container(
  //             decoration: BoxDecoration(
  //               color: gray.withOpacity(.2),
  //               borderRadius: BorderRadius.circular(10),
  //               image: DecorationImage(
  //                 image: AssetImage(imgPizza),
  //                 fit: BoxFit.contain,
  //               ),
  //             ),
  //             height: double.infinity,
  //             width: 150,
  //           ),
  //           SizedBox(
  //             width: 20,
  //           ),
  //           Expanded(
  //             child: Container(
  //               // color: Colors.pink,
  //               height: double.infinity,
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   appText(txtManageMenu,
  //                       color: black,
  //                       fontSize: 14.sp,
  //                       fontWeight: FontWeight.w500),
  //                   SizedBox(
  //                     height: 10,
  //                   ),
  //                   appText(
  //                     txtCheckItemAvailable,
  //                     color: gray,
  //                     fontSize: 10.sp,
  //                   ),
  //                   SizedBox(
  //                     height: 10,
  //                   ),
  //                   appButton(
  //                     onTap: () => {},
  //                     text: 'Add items',
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget earningCard({
    required double earningToday,
    required String orderData,
    String? restaurant_id,
    required int orderCount,
  }) {
    return Container(
      decoration: BoxDecoration(
        // color: Colors.pink,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.5),
            offset: const Offset(
              0.2,
              0.2,
            ),
            blurRadius: 2.0,
            // spreadRadius: 1.0,
          ), //BoxShadow
          const BoxShadow(
            color: Colors.white,
            offset: Offset(0.0, 0.0),
            blurRadius: 0.0,
            spreadRadius: 0.0,
          ), //BoxShadow
        ],
      ),
      // height: MediaQuery.of(context).size.height / 5,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  appText(txtEarningToday,
                      fontSize: 15.sp, fontWeight: FontWeight.w600),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 80,
                  ),
                  appText("\$${earningToday.toString()}",
                      fontSize: 20.sp, fontWeight: FontWeight.w600),
                  const SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot>(
                    stream: DashboardServices().fetchOrdersByDate(
                        restaurantId: restaurant_id!,
                        orderDate: DateTime(selectedDate.year,
                                selectedDate.month, selectedDate.day - 1)
                            .millisecondsSinceEpoch
                            .toString()),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      print(DateTime(selectedDate.year, selectedDate.month,
                              selectedDate.day - 1)
                          .millisecondsSinceEpoch
                          .toString());
                      if (snapshot.hasData && snapshot.data != null) {
                        List? docList = snapshot.data!.docs;
                        double earningYesterday = 0.0;
                        List<Order> orderList = [];
                        for (int i = 0; i < docList.length; i++) {
                          Order order = Order.fromJson(docList[i].data());
                          if (order.orderStatus == 2) {
                            earningYesterday += order.grandTotal;
                          }
                          orderList.add(order);
                        }

                        return appText(
                            "$txtYesterdayEarning \$" +
                                earningYesterday.toString(),
                            color: lightGray);
                      } else {
                        return appText(txtLoading);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 50,
            child: Column(
              children: [
                Container(
                  height: 80,
                  width: double.infinity,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: lineChartWidget(context: context),
                  ),
                ),
                GestureDetector(
                  child: appText("View details", color: appPrimaryColor),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return TotalEarning();
                    }));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget orderStatusCard(
      {required int newOrders,
      required int orderDelivers,
      required double totalTip}) {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              // onTap: () {
              //   Navigator.push(context, MaterialPageRoute(builder: (context) {
              //     return OrderStatusScreen();
              //   }));
              // },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(.5),
                        offset: const Offset(
                          0.2,
                          0.2,
                        ),
                        blurRadius: 2.0,
                        // spreadRadius: 1.0,
                      ), //BoxShadow
                      BoxShadow(
                        color: Colors.white,
                        offset: const Offset(0.0, 0.0),
                        blurRadius: 0.0,
                        spreadRadius: 0.0,
                      ), //BoxShadow
                    ],
                    color: lightGreen),
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.height / 5,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      appText(newOrders.toString(),
                          fontWeight: FontWeight.w500, fontSize: 48),
                      SizedBox(
                        height: 2,
                      ),
                      appText(
                        txtNewOrders,
                        fontWeight: FontWeight.w400,
                        fontSize: 10.sp,
                        color: darkBlack,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 10.sp,
          ),
          Expanded(
            child: Container(
              // color: Colors.teal,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return TotalEarning();
                      }));
                    },
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.width / 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: lightGreen2,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(.5),
                            offset: const Offset(
                              0.2,
                              0.2,
                            ),
                            blurRadius: 2.0,
                            // spreadRadius: 1.0,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            appText(orderDelivers.toString(),
                                fontWeight: FontWeight.w500, fontSize: 20.sp),
                            appText(txtOrdersDelivers,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w400,
                                color: darkBlack),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.sp),
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.width / 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: lightOrange,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(.5),
                          offset: const Offset(
                            0.2,
                            0.2,
                          ),
                          blurRadius: 2.0,
                          // spreadRadius: 1.0,
                        ), //BoxShadow
                        BoxShadow(
                          color: Colors.white,
                          offset: const Offset(0.0, 0.0),
                          blurRadius: 0.0,
                          spreadRadius: 0.0,
                        ), //BoxShadow
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          appText(totalTip.toString(),
                              fontWeight: FontWeight.w500, fontSize: 20.sp),
                          appText(
                            txtTotalTips,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w400,
                            color: darkBlack,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.redAccent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget lineChartWidget({required BuildContext context}) {
    restaurant =
        Provider.of<RestaurantProvider>(context, listen: true).GetRestaurant;

    List<String> dates = [
      DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
          .millisecondsSinceEpoch
          .toString(),
      DateTime(selectedDate.year, selectedDate.month, selectedDate.day - 1)
          .millisecondsSinceEpoch
          .toString(),
      DateTime(selectedDate.year, selectedDate.month, selectedDate.day - 2)
          .millisecondsSinceEpoch
          .toString(),
      DateTime(selectedDate.year, selectedDate.month, selectedDate.day - 3)
          .millisecondsSinceEpoch
          .toString(),
      DateTime(selectedDate.year, selectedDate.month, selectedDate.day - 4)
          .millisecondsSinceEpoch
          .toString(),
      DateTime(selectedDate.year, selectedDate.month, selectedDate.day - 5)
          .millisecondsSinceEpoch
          .toString(),
      DateTime(selectedDate.year, selectedDate.month, selectedDate.day - 6)
          .millisecondsSinceEpoch
          .toString(),
    ];

    dates = dates.reversed.toList();
    for (var date in dates) {
      print(date);
    }
    final List<Color> gradientColors = [appPrimaryColor];
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('restaurant_id', isEqualTo: restaurant!.restaurantId!)
          .where('order_status', isEqualTo: 2)
          .where('order_date', whereIn: dates)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          List? docList = snapshot.data!.docs;
          print("Orders :- ${docList.length}");
          Map<String, double> data = {};
          for (int i = 0; i < dates.length; i++) {
            int counter = 0;
            data[dates[i]] = 0.0;
            for (int j = 0; j < docList.length; j++) {
              if (docList[j]['order_date'] == dates[i]) {
                data[dates[i]] = data[dates[i]]! + docList[j]['grand_total'];
                counter++;
              }
            }
            if (counter == 0) {
              data[dates[i]] = 0.0;
            }
          }
          List<FlSpot> spots = [];
          double counter = 0.0;

          data.forEach((date, amount) {
            print("$counter , $amount");
            spots.add(
                FlSpot(counter++, double.parse(amount.toStringAsFixed(2))));
          });
          return LineChart(
            LineChartData(
              borderData: FlBorderData(border: Border.all(width: 0)),
              //  titlesData: LineTitles.getTitleData(),
              titlesData: FlTitlesData(
                show: true,
                topTitles: SideTitles(showTitles: false),
                rightTitles: SideTitles(showTitles: false),
                bottomTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  getTextStyles: (value, val) => const TextStyle(
                      color: Color(0xff68737d),
                      fontWeight: FontWeight.w500,
                      fontSize: 12),
                  getTitles: (value) {
                    switch (value.toInt()) {
                      case 0:
                        return getOnlyDateFormMilliSecondSinceEpochString(
                            dates[0]);
                      case 1:
                        print(dates[1]);
                        return getOnlyDateFormMilliSecondSinceEpochString(
                            dates[1]);
                      case 2:
                        return getOnlyDateFormMilliSecondSinceEpochString(
                            dates[2]);
                      case 3:
                        return getOnlyDateFormMilliSecondSinceEpochString(
                            dates[3]);
                      case 4:
                        return getOnlyDateFormMilliSecondSinceEpochString(
                            dates[4]);
                      case 5:
                        return getOnlyDateFormMilliSecondSinceEpochString(
                            dates[5]);
                      case 6:
                        return getOnlyDateFormMilliSecondSinceEpochString(
                            dates[6]);
                    }
                    return '';
                  },
                  margin: 8,
                ),
                leftTitles: SideTitles(
                  showTitles: false,
                  getTextStyles: (value, val) => const TextStyle(
                    color: Color(0xff67727d),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  getTitles: (value) {
                    return '';
                  },
                  reservedSize: 28,
                  margin: 12,
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: false,
                drawVerticalLine: false,
              ),

              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  dotData: FlDotData(show: false),
                  isCurved: true,
                  curveSmoothness: 0.4,
                  colors: gradientColors,
                  barWidth: 2,
                  belowBarData: BarAreaData(
                    show: true,
                    colors: gradientColors
                        .map((color) => color.withOpacity(0.3))
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Center(
            child: appText(txtLoading, color: appPrimaryColor),
          );
          return SizedBox();
        }
      },
    );
  }

  String getOnlyDateFormMilliSecondSinceEpochString(
      String milliSecondSinceEpochString) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(
        int.parse(milliSecondSinceEpochString));
    String onlyDate = dateTemplate.format(date);
    return onlyDate;
  }
}

class OrderData {
  OrderData({this.orderCount});

  int? orderCount;
}
