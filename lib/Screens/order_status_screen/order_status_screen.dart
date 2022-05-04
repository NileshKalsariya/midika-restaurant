import 'package:flutter/material.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/utils/colors.dart';
import 'package:midika/utils/strings.dart';
import 'package:sizer/sizer.dart';

import 'new_order_screen.dart';
import 'open_order_screen.dart';

class OrderStatusScreen extends StatefulWidget {
  const OrderStatusScreen({Key? key}) : super(key: key);

  @override
  _OrderStatusScreenState createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('2');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          // leading: Icon(
          //   Icons.arrow_back_ios,
          //   color: black,
          // ),
          title: appText(txtOrderStatus,
              fontWeight: FontWeight.w500, fontSize: 13.sp),
          backgroundColor: Colors.white,
          bottom: TabBar(
            indicatorColor: appPrimaryColor,
            indicatorWeight: 5,
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 50),
            tabs: [
              Tab(
                child: appText(txtNewOrders,
                    color: appPrimaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 13.sp),
              ),
              Tab(
                child: appText(txtOpenOrders,
                    color: appPrimaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 13.sp),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            NewOrderScreen(),
            OpenOrderScreen(),
          ],
        ),
      ),
    );
  }
}
