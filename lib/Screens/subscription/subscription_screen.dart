import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:midika/Screens/subscription/add_card_screen.dart';
import 'package:midika/Screens/subscription/card_screen.dart';
import 'package:midika/common/app_button.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/services/card_services.dart';
import 'package:midika/utils/strings.dart';
import 'package:sizer/sizer.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  SubscriptionScreenState createState() => SubscriptionScreenState();
}

class SubscriptionScreenState extends State<SubscriptionScreen> {
  _payAmount({required double amount, required int month}) {
    CardServices().fetchUserCards().then((value) {
      if (value.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CardScreen(amount: amount, month: month),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddCardScreen(amount: amount, month: month),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: appText(txtMembership, fontWeight: FontWeight.w500),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  appText(txtPlansThatHelpYouGrow,
                      fontSize: 28, fontWeight: FontWeight.w500),
                  const SizedBox(height: 10),
                  appText(
                    'Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint.',
                    color: const Color(0xff7E7E7E),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              _subscriptionCard(
                onTap: () => _payAmount(amount: 69.99, month: 12),
                amount: 69.99,
                month: 12,
              ),
              _subscriptionCard(
                onTap: () => _payAmount(amount: 97.99, month: 6),
                amount: 97.99,
                month: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _subscriptionCard({
  required int month,
  required double amount,
  required Function() onTap,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            color: const Color(0xffAFE2CD),
            border: Border.all(color: const Color(0xff37966F), width: 1)),
        child: Center(
          child: appText(
            '$month $txtMonthPlan',
            fontWeight: FontWeight.bold,
          ),
        ),
        height: 45,
      ),
      Container(
        height: 20.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(30)),
          color: const Color(0xffF7F7F7),
          border: Border.all(color: const Color(0xff37966F), width: 1),
        ),
        child: Column(
          children: [
            appText(
              '$txtMembershipFor $month $txtMonthPlan',
              color: const Color(0xff7E7E7E),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                appText('\$$amount/ ',
                    fontSize: 28, fontWeight: FontWeight.w500),
                appText(txtMonth)
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child:
                  appButton(onTap: onTap, text: txtPay, width: double.infinity),
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        ),
      ),
    ],
  );

  // return Card(
  //   child: SizedBox(

  //     height: 20.h,
  //     child: Padding(
  //       padding: const EdgeInsets.all(20.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //         children: [
  //           appText('MEMBERSHIP FOR $month MONTH PLAN'),
  //           appButton(onTap: onTap, text: 'Pay')
  //         ],
  //       ),
  //     ),
  //   ),
  // );
}
