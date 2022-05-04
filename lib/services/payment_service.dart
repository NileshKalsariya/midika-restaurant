import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:midika/Screens/bottom_navigation_root_screen/navigation_root_screen.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/models/restaurant_model.dart';
import 'package:midika/provider/user_provider.dart';
import 'package:midika/services/auth_services.dart';
import 'package:midika/stripe_keys/stripe_keys.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';

class PaymentServiceProvider extends ChangeNotifier {
  bool _isLoading = false;

  Stripe? stripe;

  String? stripe_acc_id;
  get getStripe => stripe;

  set setStripe(Stripe value) {
    stripe = value;
    notifyListeners();
  }

  get getIsLoading => _isLoading;

  set setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> makePayment(
    context, {
    required StripeCard card,
    required int month,
    required double amount,
  }) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    stripe_acc_id = pref.getString('stripe_acc');

    setIsLoading = true;
    final StripeCard stripeCard = card;
    if (!stripeCard.validateCVC()) {
      paymentStatusDialog(
          context: context, title: "Error", msg: "CVC not valid.");
      setIsLoading = false;
      return;
    }
    if (!stripeCard.validateDate()) {
      paymentStatusDialog(
          context: context, title: "Error", msg: "Date not valid.");
      setIsLoading = false;

      return;
    }
    if (!stripeCard.validateNumber()) {
      paymentStatusDialog(
          context: context, title: "Error", msg: "Number not valid.");
      setIsLoading = false;

      return;
    }

    Map<String, dynamic> paymentIntentRes =
        await createPaymentIntent(context, stripeCard, amount: amount);

    String clientSecret = paymentIntentRes['client_secret'];
    String paymentMethodId = paymentIntentRes['payment_method'];
    String status = paymentIntentRes['status'];

    if (status == 'requires_action') {
      paymentIntentRes =
          await confirmPayment3DSecure(context, clientSecret, paymentMethodId);
    }

    if (paymentIntentRes['status'] != 'succeeded') {
      paymentStatusDialog(
          context: context, title: "Status", msg: "Canceled Transaction.");
      Provider.of<PaymentServiceProvider>(context, listen: false).setIsLoading =
          false;
      return;
    }

    if (paymentIntentRes['status'] == 'succeeded') {
      DateTime _now = DateTime.now();
      DateTime _end = DateTime.now();

      _end = DateTime(_now.year, _now.month + month, _now.day);

      Provider.of<AuthServices>(context, listen: false)
          .updateRestaurantUser(date: _end);

      setIsLoading = false;

      Restaurant? restaurantProvider =
          Provider.of<RestaurantProvider>(context, listen: false).GetRestaurant;
      restaurantProvider!.subscriptionStart = DateTime.now();
      restaurantProvider.subscriptionEnd = _end;
      restaurantProvider.subscriptionActive = true;

      Provider.of<RestaurantProvider>(context, listen: false)
          .setUser(currentUser: restaurantProvider);
      Provider.of<PaymentServiceProvider>(context, listen: false).setIsLoading =
          false;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => BottomNavigationRootScreen()));
      // Functions.showDialogBox(context: context, text: text, onPressed: onPressed)
      showAlertDialog(context, "Success", "Thanks for buying!");
      return;
    }
    setIsLoading = false;
    showAlertDialog(
        context, "Warning", "Transaction rejected.\nSomething went wrong");
  }

  Future<Map<String, dynamic>> createPaymentIntent(
      BuildContext context, StripeCard stripeCard,
      {required double amount}) async {
    String clientSecret;

    Map<String, dynamic>? paymentIntentRes, paymentMethod;
    try {
      paymentMethod = await stripe!.api.createPaymentMethodFromCard(stripeCard);
      print('payment method ' + paymentMethod.toString());

      clientSecret =
          await postCreatePaymentIntent(paymentMethod['id'], amount: amount);
      print('client secret' + clientSecret.toString());
      paymentIntentRes = await stripe!.api.retrievePaymentIntent(clientSecret);
    } catch (e) {
      print("ERROR_CreatePaymentIntentAndSubmit: $e");
      showAlertDialog(context, "Error", "Something went wrong");
      setIsLoading = false;
    }
    return paymentIntentRes!;
  }

  Future<Map<String, dynamic>> confirmPayment3DSecure(
      BuildContext context, String clientSecret, String paymentMethodId) async {
    Map<String, dynamic>? paymentIntentRes_3dSecure;
    try {
      await stripe!
          .confirmPayment(clientSecret, context,
              paymentMethodId: paymentMethodId)
          .then((value) => print("value : ${value.toString()}"));
      paymentIntentRes_3dSecure =
          await stripe!.api.retrievePaymentIntent(clientSecret);
    } catch (e) {
      print("ERROR_ConfirmPayment3DSecure: $e");
      showAlertDialog(context, "Error", "Something went wrong.");
    }
    return paymentIntentRes_3dSecure!;
  }

  Future<String> postCreatePaymentIntent(String paymentMethodId,
      {required double amount}) async {
    final uri = Uri.parse("https://api.stripe.com/v1/payment_intents");
    double finalGrandTotal = amount * 100;
    // double finalPaidToClubGrubAdmin = 5 * 100;
    // double finalGrandTotal = order!.grandTotal * 100;
    // double finalPaidToClubGrubAdmin = order!.paidToClubgrubAdmin * 100;
    print("final paid to grandTotal :- $finalGrandTotal");
    // print("final paid to clubGrubAdmin :- $finalPaidToClubGrubAdmin");
    // print(finalPaidToClubGrubAdmin.truncate().toString());
    // print('my current stripe id :' + stripe_acc_id.toString());
    final response = await http.post(uri, headers: {
      'Authorization': 'Bearer ${Stripekey.secretKeytest}',
      'Content-Type': 'application/x-www-form-urlencoded',
      // 'Stripe-Account': 'acct_1KEFBXF14MM4EOZ3'
      // 'Stripe-Account': stripe_acc_id!
    }, body: {
      "payment_method_types[]": "card",
      "amount": finalGrandTotal.truncate().toString(),
      "currency": "usd",
      "confirm": 'true',
      "payment_method": paymentMethodId,
      // "application_fee_amount": finalPaidToClubGrubAdmin.truncate().toString(),
    });

    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      var paymentIntent = jsonDecode(response.body);
      // _refundUrl = paymentIntent['charges']['data'][0]['refunds']['url'];
      // _refundId = paymentIntent['charges']['data'][0]['id'];
      setIsLoading = false;
      return paymentIntent['client_secret']!;
    } else {
      print(response.statusCode);
      print(jsonDecode(response.body));
      setIsLoading = false;
      return '';
    }
  }

  showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            FlatButton(
              child: Text("OK"),
              onPressed: () => Navigator.of(context).pop(), // dismiss dialog
            ),
          ],
        );
      },
    );
  }

  paymentStatusDialog({
    required BuildContext context,
    required String title,
    required String msg,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: appText(title),
          content: appText(msg),
          actions: [
            FlatButton(
              child: appText("OK"),
              onPressed: () => Navigator.of(context).pop(), // dismiss dialog
            ),
          ],
        );
      },
    );
  }
}
