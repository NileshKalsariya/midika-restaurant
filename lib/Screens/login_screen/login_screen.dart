import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:midika/Screens/otp_verification/otp_varification_screen.dart';
import 'package:midika/Screens/register_screen/register_screen.dart';
import 'package:midika/Screens/webview/privacy_policy.dart';
import 'package:midika/Screens/webview/terms_condition.dart';
import 'package:midika/common/app_button.dart';
import 'package:midika/common/app_divider.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/common/app_text_form_field.dart';
import 'package:midika/common/loader_layout.dart';
import 'package:midika/services/auth_services.dart';
import 'package:midika/utils/colors.dart';
import 'package:midika/utils/strings.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:the_apple_sign_in/scope.dart';

import '../../common/functions.dart';
import '../../services/apple_login_service/apple_auth_service.dart';
import '../../services/apple_login_service/apple_sign_in_available.dart';
import '../../services/profile_services.dart';
import '../../utils/asset_paths.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? mobileNo;
  String? countryCode = '+39';

  AuthServices authServices = new AuthServices();
  static FirebaseAuth auth = FirebaseAuth.instance;

  String? mobileNumberValidation(String? value) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10}$)';
    RegExp regExp = RegExp(pattern);
    if (value!.isEmpty) {
      return txtPleaseEnterValue;
    } else if (!regExp.hasMatch(value)) {
      return txtPleaseEnterValidMobileNumber;
    }
    return null;
  }

  Future<bool?> verifyPhoneNumber({
    required String phoneNumber,
    required BuildContext context,
  }) async {
    PhoneCodeSent phoneCodeSent =
        (String verificationID, [int? forceResendinToken]) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(
            countryCode: countryCode!,
            phoneNumber: mobileNo!,
            verificationID: verificationID,
          ),
        ),
      );
    };

    try {
      await auth.verifyPhoneNumber(
          phoneNumber: "$countryCode $phoneNumber",
          timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) {},
          verificationFailed: (FirebaseAuthException exception) {
            if (exception.code == 'invalid-phone-number') {
              Provider.of<AuthServices>(context, listen: false)
                  .setLoaderState(false);
              showSnackBar(
                  context: context, text: txtTheProvidedPhoneNumberIsNotValid);
            }
          },
          codeSent: phoneCodeSent,
          codeAutoRetrievalTimeout: (String verificationId) {});
    } catch (e) {
      Provider.of<AuthServices>(context, listen: false).setLoaderState(false);
      showSnackBar(context: context, text: txtSomethingWentWrongTryAgain);
    }
  }

  static void showSnackBar(
      {required BuildContext context, required String text}) {
    final snackBar = SnackBar(
      content: Text(text),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  bool backbutton = true;

  PreventBackButton() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("onboarding")) {
      if (prefs.getString('onboarding') == 'off') {
        setState(() {
          backbutton = false;
        });
      }
    }
  }

  Future<void> loginInWithApple(BuildContext context) async {
    try {
      final authService = Provider.of<AuthServiceApple>(context, listen: false);
      /* final user =*/ await authService.signInWithApple(
          scopes: [Scope.email, Scope.fullName]).then((value) async {
        print('uid: ${value.uid}');
        print('email------>: ${value.providerData[0].email}');

        QuerySnapshot snapshot =
            await ProfileService.checkUserByEmail(value.providerData[0].email!);
        if (snapshot.docs.length > 0) {
          await AuthServices.ifLoginSetDataAndSendToDashBoard(
              email_id: value.providerData[0].email!, context: context);
          // Restaurant restaurant = await ProfileService.getUserByEmailID(
          //     email: value.providerData[0].email!);
          // if (restaurant.restaurantId != '' ||
          //     restaurant.restaurantId != null) {
          //   SharedPreferences _prefs = await SharedPreferences.getInstance();
          //   _prefs.setString('uid', restaurant.restaurantId!);
          //   _prefs.setString('onboarding', 'off');
          //   Provider.of<RestaurantProvider>(context, listen: false)
          //       .setUser(currentUser: restaurant);
          //   Navigator.of(context).pushAndRemoveUntil(
          //       MaterialPageRoute(
          //           builder: (context) => BottomNavigationRootScreen()),
          //       (Route<dynamic> route) => false);
          // } else {
          //   Fluttertoast.showToast(
          //       msg: 'Something went wrong with apple signIn');
          // }
        } else {
          Fluttertoast.showToast(
              msg:
                  'The email address you have entered is not registered with us, please register');
          // Navigator.push(context, MaterialPageRoute(builder: (context) {
          //   return OtherDetail(
          //     is_apple_register: true,
          //     uid: value.uid,
          //     email_id: value.providerData[0].email,
          //   );
          // }));
        }

        // getUserBy(email);
      });
    } catch (e) {
      print(e);
    }
  }

  Future<UserCredential?> loginWithFacebook() async {
    // final _provider = Provider.of<AuthServices>(context, listen: false);
    // _provider.setLoaderState(true);
    try {
      // markwinz20@gmail.com
      // mark@winz20

      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance
          .login(permissions: ['public_profile', 'email']);

      if (loginResult.status == LoginStatus.success) {
        debugPrint('loginResult.accessToken : ${loginResult.accessToken}');
        // Create a credential from the access token
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(loginResult.accessToken!.token);

        // Once signed in, return the UserCredential
        FirebaseAuth.instance.signInWithCredential(facebookAuthCredential).then(
          (value) async {
            print(value);

            if (value.user!.uid != '' || value.user!.uid != null) {
              if (value.user!.email != '' || value.user!.email != null) {
                QuerySnapshot snapshot =
                    await ProfileService.checkUserByEmail(value.user!.email!);
                if (snapshot.docs.length > 0) {
                  await AuthServices.ifLoginSetDataAndSendToDashBoard(
                      email_id: value.user!.email!, context: context);

                  // Restaurant restaurant = await ProfileService.getUserByEmailID(
                  //     email: value.user!.email!);
                  // if (restaurant.restaurantId != null ||
                  //     restaurant.restaurantEmail != null) {
                  //   SharedPreferences _prefs =
                  //       await SharedPreferences.getInstance();
                  //   _prefs.setString('uid', restaurant.restaurantId!);
                  //   _prefs.setString('onboarding', 'off');
                  //   Provider.of<RestaurantProvider>(context, listen: false)
                  //       .setUser(currentUser: restaurant);
                  //   Navigator.of(context).pushAndRemoveUntil(
                  //       MaterialPageRoute(
                  //           builder: (context) => BottomNavigationRootScreen()),
                  //       (Route<dynamic> route) => false);
                  // }
                } else {
                  Fluttertoast.showToast(
                      msg:
                          'The email address you have entered is not registered with us, please register');
                  // Navigator.of(context).push(MaterialPageRoute(
                  //     builder: (context) => OtherDetail(
                  //           is_facebook_regster: true,
                  //           uid: value.user!.uid,
                  //           email_id: value.user!.email,
                  //         )));
                }
              }
            }
          },
        );
        // _provider.setLoaderState(false);
        // setState(() => _loading = false);
      } else if (loginResult.status == LoginStatus.cancelled) {
        // _provider.setLoaderState(false);
        // setState(() => _loading = false);

        Functions.toast(loginResult.message ?? "cancelled");
      } else if (loginResult.status == LoginStatus.failed) {
        // _provider.setLoaderState(false);
        // setState(() => _loading = false);
        //
        Functions.toast(loginResult.message ?? "failed");
      }
    } catch (e) {
      // _provider.setLoaderState(false);
      // setState(() => _loading = false);

      Functions.toast(e.toString());
      debugPrint('fb error  $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    PreventBackButton();
  }

  @override
  Widget build(BuildContext context) {
    final appleSignInAvailable =
        Provider.of<AppleSignInAvailable>(context, listen: false);
    return Stack(
      children: [
        Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: SizedBox(
                height: 100.h,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        backbutton
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(Icons.arrow_back_ios_new),
                              )
                            : SizedBox(),
                        SizedBox(height: 2.8.h),
                        appText(
                          txtLoginAccount,
                          color: appPrimaryColor,
                        ),
                        const SizedBox(height: 5),
                        appDivider(),
                        SizedBox(height: 3.2.h),
                        appText(
                          txtContinueWithPhone,
                          color: black,
                          fontWeight: FontWeight.w500,
                          fontSize: 20.sp,
                        ),
                        SizedBox(height: 1.5.h),
                        appText(txtWeWillSendOtp, fontSize: 12.sp),
                        SizedBox(height: 3.h),
                        Row(
                          children: [
                            Container(
                              width: 100,
                              child: CountryCodePicker(
                                onChanged: (value) {
                                  setState(
                                    () {
                                      countryCode = value.toString();
                                    },
                                  );
                                  print(value);
                                },
                                // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                initialSelection: 'IT',
                                favorite: ['+31', 'IT'],

                                // optional. Shows only country name and flag
                                showCountryOnly: false,
                                showOnlyCountryWhenClosed: false,
                                alignLeft: false,
                              ),
                            ),
                            Expanded(
                              child: appTextFormField(
                                title: txtMobileNumber,
                                hintText: txtMobileNumberHint,
                                controller: _mobileNumberController,
                                validator: (value) {
                                  return mobileNumberValidation(value);
                                },
                              ),
                              // prefixText: "+91"),
                            ),
                          ],
                        ),
                        SizedBox(height: 3.2.h),
                        appButton(
                          width: 100.w,
                          text: txtSendOTP,
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              final provider = Provider.of<AuthServices>(
                                  context,
                                  listen: false);
                              setState(() {
                                mobileNo = _mobileNumberController.text;
                              });
                              provider.setLoaderState(true);
                              int check = await authServices.checkEmail(
                                  phone: _mobileNumberController.text);
                              if (check == 0) {
                                provider.setLoaderState(false);
                                Fluttertoast.showToast(
                                    msg:
                                        txtThisNumberIsNotRegisteredWithUsPleaseRegister);
                              } else {
                                await verifyPhoneNumber(
                                    context: context,
                                    phoneNumber: _mobileNumberController.text);
                              }
                            }
                          },
                        ),
                        SizedBox(height: 1.5.h),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: txtByProvidingMyPhoneNumberHerebyAgreeAnd,
                            style: defaultTextStyle(height: 1.4),
                            children: [
                              TextSpan(
                                  text: txtAcceptThe,
                                  style: defaultTextStyle()),
                              TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return AppWebView(
                                        url:
                                            'https://www.iubenda.com/terms-and-conditions/10753089',
                                      );
                                    }));
                                    print('terms and conditions');
                                  },
                                text: txtTermsOfService,
                                style: defaultTextStyle(
                                  decoration: TextDecoration.underline,
                                  color: appPrimaryColor,
                                ),
                              ),
                              TextSpan(text: txtAnd, style: defaultTextStyle()),
                              TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return PrivacyPolicyWebView(
                                              url:
                                                  'https://www.iubenda.com/privacy-policy/24473998',
                                            );
                                          },
                                        ),
                                      );
                                      print('privacy pollicy');
                                    },
                                  text: txtPrivacyPolicy,
                                  style: defaultTextStyle(
                                    decoration: TextDecoration.underline,
                                    color: appPrimaryColor,
                                  )),
                              TextSpan(
                                  text: txtInUse, style: defaultTextStyle()),
                              TextSpan(
                                  text: txtOfTheCommunityApp,
                                  style: defaultTextStyle())
                            ],
                          ),
                        ),
                        // SizedBox(height: 4.h),
                        // Divider(
                        //   height: 1,
                        //   color: Colors.black12,
                        //   thickness: 1,
                        //   indent: 35.w,
                        //   endIndent: 35.w,
                        // ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                height: 1,
                                color: Colors.black12,
                                thickness: 1,
                              ),
                            ),
                            appText(txtContinueWith),
                            const Expanded(
                              child: Divider(
                                height: 1,
                                color: Colors.black12,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        // Spacer(),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              if (appleSignInAvailable.isAvailable)
                                imageButton(
                                  path: iconAppleLogo,
                                  onTap: () async {
                                    await loginInWithApple(context);
                                  },
                                ),
                              imageButton(
                                path: iconGoogleLogo,
                                onTap: () async {
                                  await AuthServices()
                                      .googleLoginLoginScreen(context: context);
                                },
                              ),
                              imageButton(
                                path: iconFbLogo,
                                onTap: () async {
                                  await loginWithFacebook();
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 6.h,
                        ),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: txtYouHaveNotAcc,
                              style: defaultTextStyle(fontSize: 12.sp),
                              children: [
                                TextSpan(
                                  text: txtSignUp,
                                  style: defaultTextStyle(
                                      color: appPrimaryColor, fontSize: 12.sp),
                                  recognizer: new TapGestureRecognizer()
                                    ..onTap = () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return RegisterScreen();
                                            },
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 3.h),
                      ],
                    ),
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
}
