import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as Auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:midika/Screens/bottom_navigation_root_screen/navigation_root_screen.dart';
import 'package:midika/Screens/register_screen/register_screen.dart';
import 'package:midika/Screens/subscription/subscription_screen.dart';
import 'package:midika/common/app_button.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/common/loader_layout.dart';
import 'package:midika/models/restaurant_model.dart';
import 'package:midika/provider/user_provider.dart';
import 'package:midika/services/auth_services.dart';
import 'package:midika/services/profile_services.dart';
import 'package:midika/utils/colors.dart';
import 'package:midika/utils/strings.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationID;
  final String countryCode;

  OtpVerificationScreen({
    Key? key,
    required this.phoneNumber,
    required this.verificationID,
    required String this.countryCode,
  }) : super(key: key);

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  // final _formKey = GlobalKey<FormState>();
  final _pinPutController = TextEditingController();
  final _pinPutFocusNode = FocusNode();

  // final _pageController = PageController();

  int start = 30;
  bool wait = true;
  Timer? timer;
  String verificationIDFinal = "";
  Auth.FirebaseAuth _auth = Auth.FirebaseAuth.instance;

  Future<void> phoneCredential(
      {required BuildContext context, required String otp}) async {
    try {
      Provider.of<AuthServices>(context, listen: false).setLoaderState(true);
      Auth.PhoneAuthCredential credential = Auth.PhoneAuthProvider.credential(
          verificationId: verificationIDFinal, smsCode: otp);
      final Auth.User? user =
          (await _auth.signInWithCredential(credential)).user;

      if (user != null) {
        print(Auth.FirebaseAuth.instance.currentUser!.phoneNumber);

        if (Auth.FirebaseAuth.instance.currentUser!.phoneNumber != null &&
            user != null) {
          print(
              Auth.FirebaseAuth.instance.currentUser!.uid + 'this is user id');
          // Restaurant currentUser = await ProfileService.getUserById(
          //     id: Auth.FirebaseAuth.instance.currentUser!.uid);
          Restaurant currentUser =
              await ProfileService.getUserByPhone(phone: widget.phoneNumber);
          if (currentUser != null) {
            SharedPreferences _prefs = await SharedPreferences.getInstance();
            _prefs.setString('uid', currentUser.restaurantId!);
            _prefs.setString('onboarding', 'off');
            Provider.of<RestaurantProvider>(context, listen: false)
                .setUser(currentUser: currentUser);

            String? token = await FirebaseMessaging.instance.getToken();
            if (currentUser.deviceToken != token) {
              await FirebaseFirestore.instance
                  .collection('users_restaurant')
                  .doc(currentUser.restaurantId!)
                  .update(
                {"device_token": token},
              );
            }

            Provider.of<AuthServices>(context, listen: false)
                .setLoaderState(false);
            log('---- currentUser.subscriptionActive! == true   ${currentUser.subscriptionActive! == true}');

            if (currentUser.subscriptionActive! == true) {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => BottomNavigationRootScreen()),
                  (Route<dynamic> route) => false);
            } else {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const SubscriptionScreen()),
                  (Route<dynamic> route) => false);
            }
          }
        } else {
          Provider.of<AuthServices>(context, listen: false)
              .setLoaderState(false);
          Fluttertoast.showToast(msg: txtSomethingWentWrong);
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => RegisterScreen()),
              (Route<dynamic> route) => false);
        }
        // await authServices.signIn(context: context);
        Provider.of<AuthServices>(context, listen: false).setLoaderState(false);
      } else {
        print("Authentication failed");
        Provider.of<AuthServices>(context, listen: false).setLoaderState(false);
      }
    } on Auth.FirebaseAuthException catch (e) {
      Provider.of<AuthServices>(context, listen: false).setLoaderState(false);
      if (e.code == "invalid-verification-code") {
        showSnackBar(context: context, text: txtInvalidOtp);
        print(e.toString());
      } else {
        showSnackBar(context: context, text: e.toString());
        print(e.toString());
      }
    }
  }

  static void showSnackBar(
      {required BuildContext context, required String text}) {
    final snackBar = SnackBar(
      content: appText(
        text,
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: black800),
      borderRadius: BorderRadius.circular(15.0),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    verificationIDFinal = widget.verificationID;
    startTimer();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Provider.of<AuthServices>(context, listen: false).setLoaderState(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    _pinPutFocusNode.requestFocus();
    return Stack(
      children: [
        Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: SizedBox(
                height: 100.h,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.arrow_back_ios_new),
                      ),
                      SizedBox(height: 2.8.h),
                      appText(
                        txtOTPVerification,
                        fontSize: 20.sp,
                      ),
                      SizedBox(height: 1.6.h),
                      appText(
                        txtForTheSecurityOfYouAcPlease,
                      ),
                      appText(
                        txtEnterTheSecurityCode,
                      ),
                      SizedBox(height: 3.h),
                      Container(
                        color: Colors.transparent,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(20.0),
                        child: PinPut(
                          fieldsCount: 6,
                          onSubmit: (String pin) {
                            print('on submit : $pin');
                          },
                          focusNode: _pinPutFocusNode,
                          controller: _pinPutController,
                          submittedFieldDecoration: _pinPutDecoration.copyWith(
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(color: appPrimaryColor)),
                          selectedFieldDecoration: _pinPutDecoration,
                          followingFieldDecoration: _pinPutDecoration.copyWith(
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(
                              color: appPrimaryColor.withOpacity(.5),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      appButton(
                        width: 100.w,
                        text: txtLoginAccount,
                        onTap: () async {
                          print('pin number is : ${_pinPutController.text}');
                          if (_pinPutController.text.length == 6) {
                            await phoneCredential(
                                context: context, otp: _pinPutController.text);

                            // await _auth.verifyOtp(
                            //     otp: _pinPutController.text,
                            //     id: id,
                            //     context: context);
                          } else {
                            Fluttertoast.showToast(
                                msg: txtPleaseEnterOtpWith6Digit);
                          }
                        },
                      ),
                      SizedBox(height: 2.4.h),
                      RichText(
                        textAlign: TextAlign.start,
                        text: TextSpan(
                          text: txtDidNotYouReceivedTheOTP,
                          style: defaultTextStyle(),
                          children: [
                            TextSpan(
                              text: ' ' + txtResendOTP,
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  print('hello');
                                  if (start == 0) {
                                    {
                                      print('hello');
                                      AuthServices.verifyPhoneNumber(
                                          countryCode: widget.countryCode,
                                          phoneNumber: widget.phoneNumber,
                                          context: context,
                                          otpScreen: true,
                                          setData: setData);
                                    }
                                  } else {
                                    print('hello else');
                                  }

                                  // await _provider
                                  //     .sendOtp(widget.mobileNumber.toString());
                                },
                              style: defaultTextStyle(
                                color:
                                    start == 0 ? appPrimaryColor : Colors.grey,
                              ),
                            ),
                            TextSpan(
                              text: " (00:${start})",
                              style: defaultTextStyle(
                                color:
                                    start == 0 ? appPrimaryColor : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Provider.of<AuthServices>(context, listen: true).isLoading
            ? LoaderLayoutWidget()
            : SizedBox.shrink(),
      ],
    );
  }

  void startTimer() {
    setState(() {
      start = 60;
    });
    const onsec = Duration(seconds: 1);
    timer = Timer.periodic(onsec, (timer) {
      if (start == 0) {
        if (mounted) {
          setState(() {
            print(start);
            timer.cancel();
            wait = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            start--;
            print(start);
          });
        }
      }
    });
  }

  void setData({String? verificationID}) {
    setState(() {
      if (mounted) {
        print('call on otp screen');
        verificationIDFinal = verificationID!;
      }
    });
    startTimer();
  }
}
