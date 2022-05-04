import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/models/order_model.dart';
import 'package:midika/models/user_model.dart';
import 'package:midika/provider/user_provider.dart';
import 'package:midika/services/earnings_services.dart';
import 'package:midika/services/order_service.dart';
import 'package:midika/utils/asset_paths.dart';
import 'package:midika/utils/colors.dart';
import 'package:midika/utils/date_functions.dart';
import 'package:midika/utils/strings.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class TotalEarning extends StatefulWidget {
  const TotalEarning({Key? key}) : super(key: key);

  @override
  _TotalEarningState createState() => _TotalEarningState();
}

class _TotalEarningState extends State<TotalEarning> {
  TextEditingController _dateController = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  int myIndex = 0;

  String _selectedDate = '';
  DateTime? _startDate = DateTime.now();
  DateTime? _endDate = DateTime.now();
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is PickerDateRange) {
        // if (args.value.startDate != null && args.value.endDate != null) {
        //   setState(() {
        //     _startDate = DateFormat('dd/MM/yyyy').format(args.value.startDate);
        //     _endDate = DateFormat('dd/MM/yyyy').format(args.value.endDate);
        //   });
        // }

        _range = '${DateFormat('dd/MM/yyyy').format(args.value.startDate)} -'
            // ignore: lines_longer_than_80_chars
            ' ${DateFormat('dd/MM/yyyy').format(args.value.endDate ?? args.value.startDate)}';
      } else if (args.value is DateTime) {
        _selectedDate = args.value.toString();
      } else if (args.value is List<DateTime>) {
        _dateCount = args.value.length.toString();
      } else {
        _rangeCount = args.value.length.toString();
      }
      // print(_range);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        leading: InkWell(
          child: Icon(
            Icons.arrow_back_ios,
            color: black,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        title: appText(txtTotalEarnings,
            fontWeight: FontWeight.w500, fontSize: 14.sp),
        elevation: 1,
      ),
      body: Consumer<RestaurantProvider>(
        builder: (context, data, child) {
          String startDay = _startDate!.toString().split(' ')[0].split('-')[2];
          String startMonth =
              _startDate!.toString().split(' ')[0].split('-')[1];
          String startYear = _startDate!.toString().split(' ')[0].split('-')[0];

          String endDay = _endDate!.toString().split(' ')[0].split('-')[2];
          String endMonth = _endDate!.toString().split(' ')[0].split('-')[1];
          String endYear = _endDate!.toString().split(' ')[0].split('-')[0];

          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: black,
                  ),
                  height: MediaQuery.of(context).size.height / 6.5,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              appText(txtTotalRevenue, color: white),
                              SizedBox(
                                height: 5,
                              ),
                              StreamBuilder<QuerySnapshot>(
                                stream: TotalEarningsClass()
                                    .getTotalEarningCount(
                                        restaurantid:
                                            data.restaurantModel.restaurantId),
                                builder: (context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.hasData && snapshot.data != '') {
                                    List docList = snapshot.data!.docs;
                                    double total_earning = 0;
                                    for (int i = 0; i < docList.length; i++) {
                                      Order orders =
                                          Order.fromJson(docList[i].data());
                                      if (orders.orderStatus == 2) {
                                        total_earning += orders.grandTotal;
                                      }
                                    }

                                    return appText(
                                        "\$${total_earning.toString()}",
                                        color: white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 24.sp);
                                  } else {
                                    appText(txtLoading,
                                        color: white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 24.sp);
                                  }
                                  return appText(txtLoading,
                                      color: white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 24.sp);
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: Image.asset(iconRevenue),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300.withOpacity(.9),
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        appText(
                            '${startDay}-${startMonth}-${startYear} to ${endDay}-${endMonth}-${endYear}'),
                        GestureDetector(
                          child: Container(
                            child: Image.asset(iconDate),
                          ),
                          onTap: () {
                            showDialog(
                                useRootNavigator: false,
                                context: context,
                                builder: (_) => AlertDialog(
                                      title: appText(txtSelectDateRange),
                                      content: Container(
                                          height: 300,
                                          width: 150,
                                          // height: double.infinity,
                                          // width: double.infinity,
                                          child: SfDateRangePicker(
                                            selectionMode:
                                                DateRangePickerSelectionMode
                                                    .extendableRange,
                                            selectionColor: Colors.red,
                                            startRangeSelectionColor:
                                                appPrimaryColor,
                                            endRangeSelectionColor:
                                                appPrimaryColor,
                                            onSelectionChanged:
                                                _onSelectionChanged,
                                            showActionButtons: true,
                                            onSubmit: (value) {
                                              if (value is PickerDateRange) {
                                                if (value.startDate != null &&
                                                    value.endDate != null) {
                                                  final DateTime
                                                      rangeStartDate =
                                                      value.startDate!;
                                                  final DateTime rangeEndDate =
                                                      value.endDate!;
                                                  if (rangeStartDate != null &&
                                                      rangeEndDate != null) {
                                                    setState(() {
                                                      _startDate =
                                                          rangeStartDate;
                                                      _endDate = rangeEndDate;
                                                      rangeEndDate;
                                                    });

                                                    Navigator.of(context).pop();
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            txtPleaseSelectValidDateRange);
                                                  }
                                                } else {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          txtPleaseSelectValidDateRange);
                                                }
                                              } else {
                                                Fluttertoast.showToast(
                                                    msg:
                                                        txtPleaseSelectValidDateRange);
                                              }
                                            },
                                            onCancel: () {
                                              Navigator.of(context).pop();
                                            },
                                          )),
                                    ));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Expanded(
                  child: DefaultTabController(
                      initialIndex: 0,
                      length: 3,
                      child: Scaffold(
                        backgroundColor: Colors.white,
                        appBar: TabBar(
                          onTap: (index) {
                            setState(() {
                              myIndex = index;
                            });
                          },
                          indicatorWeight: 3,
                          indicatorColor: appPrimaryColor,
                          unselectedLabelColor: Color(0xffB1B1B1),
                          tabs: [
                            Tab(
                              child: appText(txtAll,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: myIndex == 0
                                      ? appPrimaryColor
                                      : const Color(0xffB1B1B1)),
                            ),
                            Tab(
                              child: appText(
                                txtCard,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: myIndex == 1
                                    ? appPrimaryColor
                                    : const Color(0xffB1B1B1),
                              ),
                            ),
                            Tab(
                              child: appText(
                                txtCash,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: myIndex == 2
                                    ? appPrimaryColor
                                    : const Color(0xffB1B1B1),
                              ),
                            ),
                          ],
                        ),
                        body: TabBarView(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 1, vertical: 10),
                              child: Container(
                                child: SingleChildScrollView(
                                  child: StreamBuilder(
                                    stream: TotalEarningsClass()
                                        .fetchallOrdersByrange(
                                      restaurantId:
                                          data.restaurantModel.restaurantId!,
                                      startDate: DateTime(
                                              _startDate!.year,
                                              _startDate!.month,
                                              _startDate!.day)
                                          .millisecondsSinceEpoch
                                          .toString(),
                                      endDate: DateTime(_endDate!.year,
                                              _endDate!.month, _endDate!.day)
                                          .millisecondsSinceEpoch
                                          .toString(),
                                    ),
                                    builder: (context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.data!.docs.length > 0) {
                                        List docList = snapshot.data!.docs;
                                        List<Order> orderlist = [];
                                        for (int i = 0;
                                            i < docList.length;
                                            i++) {
                                          Order order =
                                              Order.fromJson(docList[i].data());
                                          orderlist.add(order);
                                        }
                                        var length = snapshot.data!.docs.length;
                                        return ListView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: length,
                                            itemBuilder: (context, index) {
                                              return EarningsCard(
                                                  currentOrder:
                                                      orderlist[index]);
                                            });
                                      } else {
                                        return Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              3,
                                          child: Center(
                                            child: appText(
                                                txtNoOrdersAvailableOnThisDate),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 1, vertical: 10),
                              child: Container(
                                child: SingleChildScrollView(
                                  child: StreamBuilder(
                                    stream: TotalEarningsClass()
                                        .fetchallOrdersByrange(
                                      restaurantId:
                                          data.restaurantModel.restaurantId!,
                                      startDate: DateTime(
                                              _startDate!.year,
                                              _startDate!.month,
                                              _startDate!.day)
                                          .millisecondsSinceEpoch
                                          .toString(),
                                      endDate: DateTime(_endDate!.year,
                                              _endDate!.month, _endDate!.day)
                                          .millisecondsSinceEpoch
                                          .toString(),
                                    ),
                                    builder: (context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.data!.docs.length > 0) {
                                        List docList = snapshot.data!.docs;
                                        List<Order> orderlist = [];
                                        for (int i = 0;
                                            i < docList.length;
                                            i++) {
                                          Order order =
                                              Order.fromJson(docList[i].data());
                                          orderlist.add(order);
                                        }
                                        var length = snapshot.data!.docs.length;
                                        return ListView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: length,
                                            itemBuilder: (context, index) {
                                              return EarningsCard(
                                                  currentOrder:
                                                      orderlist[index]);
                                            });
                                      } else {
                                        return Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              3,
                                          child: Center(
                                            child: appText(
                                                txtNoOrdersAvailableOnThisDate),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 1, vertical: 10),
                              child: Container(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                3,
                                        child: Center(
                                            child: appText(
                                                txtNoCashOrderReceived)),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget EarningsCard({required Order currentOrder}) {
    String dateTime = DateFunctions.getFormattedDate(currentOrder.addedOn!);
    return Column(
      children: [
        Container(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    appText("#${currentOrder.orderId}", fontSize: 11.sp),
                    appText(dateTime, fontSize: 11.sp),
                  ],
                ),
                SizedBox(
                  height: 2.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FutureBuilder(
                          future: OrderService.getUserById(
                              userId: currentOrder.userId!),
                          builder:
                              (context, AsyncSnapshot<UserModel> snapshot) {
                            if (snapshot.hasData && snapshot.data != '') {
                              return Container(
                                child: appText(
                                    snapshot.data!.userName.toString(),
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500),
                              );
                            } else {
                              return Container(
                                child: appText(txtLoading,
                                    color: orangeClr,
                                    fontWeight: FontWeight.w500),
                              );
                            }
                          },
                        ),
                        SizedBox(height: 3),
                        appText(txtCreditCard,
                            fontWeight: FontWeight.w500,
                            fontSize: 10.sp,
                            color: gray3),
                      ],
                    ),
                    appText('${currentOrder.grandTotal.toString()}',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.deepOrange),
                  ],
                ),
              ],
            ),
          ),
        ),
        Divider(height: 10)
      ],
    );
  }
}
