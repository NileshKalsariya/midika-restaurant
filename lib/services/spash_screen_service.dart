import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:midika/Screens/bottom_navigation_root_screen/navigation_root_screen.dart';
import 'package:midika/Screens/on_boarding_screen/on_boarding_screen.dart';
import 'package:midika/Screens/register_screen/register_screen.dart';
import 'package:midika/Screens/splash_screen/splash_screen.dart';
import 'package:midika/Screens/subscription/subscription_screen.dart';
import 'package:midika/common/functions.dart';
import 'package:midika/models/restaurant_model.dart';
import 'package:midika/provider/user_provider.dart';
import 'package:midika/services/payment_service.dart';
import 'package:midika/services/profile_services.dart';
import 'package:midika/stripe_keys/stripe_keys.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stripe_sdk/stripe_sdk.dart';

import 'auth_services.dart';

class SpashScreenService extends ChangeNotifier {
  bool is_network = false;
  checkUser(BuildContext context) async {
    await checkNetwork();
    // await AuthServices().signOutFromGoogle();

    // Provider.of<PaymentServiceProvider>(context, listen: false).setStripe = Stripe(
    //     'pk_test_51KGPcvAAUnlvbz4tVyoFUU4MDuVV84atXmNLklmoai7PjvSohO7RXpvO0Ij3VmzKw1zkTeW2u4EKdrRox5SiupDq006RfoYw6k');
    if (is_network) {
      Provider.of<PaymentServiceProvider>(context, listen: false).setStripe =
          Stripe(Stripekey.publicKeytest);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey("onboarding")) {
        if (prefs.getString('onboarding') == 'off') {
          if (prefs.containsKey("uid")) {
            if (prefs.getString('uid') != null) {
              Restaurant currentUser =
                  await ProfileService().getUser(uid: prefs.getString('uid'));
              Provider.of<RestaurantProvider>(context, listen: false)
                  .setUser(currentUser: currentUser);
              Provider.of<AuthServices>(context, listen: false).setCategories();
              Restaurant? restaurant =
                  Provider.of<RestaurantProvider>(context, listen: false)
                      .GetRestaurant;

              String? token = await FirebaseMessaging.instance.getToken();
              if (restaurant!.deviceToken != token) {
                await FirebaseFirestore.instance
                    .collection('users_restaurant')
                    .doc(prefs.getString('uid'))
                    .update(
                  {"device_token": token},
                );
              }

              log('---- currentUser.subscriptionActive! == true   ${currentUser.subscriptionActive! == true}');
              if (currentUser.subscriptionActive! == true) {
                // log('----- currentUser.subscriptionEnd!.isBefore(DateTime.now())  -----${currentUser.subscriptionEnd}-before- ${currentUser.subscriptionEnd!.isBefore(DateTime.now())}----after- ${currentUser.subscriptionEnd!.isAfter(DateTime.now())}');

                if (currentUser.subscriptionEnd!.isAfter(DateTime.now())) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BottomNavigationRootScreen()));
                } else {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SubscriptionScreen()));
                }
              } else {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SubscriptionScreen()));
              }
            } else {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterScreen()));
            }
          } else {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const RegisterScreen()));
          }
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const OnBoardingScreen()));
        }
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const OnBoardingScreen()));
      }
    } else {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const NoNetScreen()));
    }
  }

  checkNetwork() async {
    is_network = await Functions.checkConnectivity();
    notifyListeners();
  }
}
