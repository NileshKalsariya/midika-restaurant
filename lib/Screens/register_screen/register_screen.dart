import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:midika/Screens/bottom_navigation_root_screen/navigation_root_screen.dart';
import 'package:midika/Screens/login_screen/login_screen.dart';
import 'package:midika/Screens/other_detail_screen/other_detail_screen.dart';
import 'package:midika/Screens/otp_verification/mobile_otp_verification.dart';
import 'package:midika/Screens/webview/privacy_policy.dart';
import 'package:midika/Screens/webview/terms_condition.dart';
import 'package:midika/common/app_button.dart';
import 'package:midika/common/app_divider.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/common/app_text_form_field.dart';
import 'package:midika/common/loader_layout.dart';
import 'package:midika/services/apple_login_service/apple_auth_service.dart';
import 'package:midika/services/apple_login_service/apple_sign_in_available.dart';
import 'package:midika/services/auth_services.dart';
import 'package:midika/services/profile_services.dart';
import 'package:midika/utils/asset_paths.dart';
import 'package:midika/utils/colors.dart';
import 'package:midika/utils/strings.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:the_apple_sign_in/scope.dart';

import '../../common/functions.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _managernameController = TextEditingController();
  final TextEditingController _restaurantnameController =
      TextEditingController();
  final TextEditingController _emailIDController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();

  String? restaurant_name;
  String? manager_name;
  String? email_id;
  String? mobile_no;
  String? countryCode = '+39';

  final _formKey = GlobalKey<FormState>();

  static FirebaseAuth auth = FirebaseAuth.instance;

  bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(p);
    return regExp.hasMatch(em);
  }

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

  bool backbutton = true;

  String uid = '';

  @override
  void initState() {
    super.initState();
    chekUserLogedIn();
  }

  chekUserLogedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final currentUid = prefs.getString('uid') ?? '';

    if (prefs.containsKey("onboarding")) {
      if (prefs.getString('onboarding') == 'off') {
        setState(() {
          backbutton = false;
        });
      }
    }

    if (currentUid != null && currentUid != '') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return BottomNavigationRootScreen();
      }));
    }
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
          builder: (context) => MobileOtpVerification(
            phoneNumber: phoneNumber,
            verificationID: verificationID,
            mobile_no: mobile_no,
            countryCode: countryCode,
            manager_name: manager_name,
            email_id: email_id,
            restaurant_name: restaurant_name,
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

  Future<void> _signInWithApple(BuildContext context) async {
    try {
      final authService = Provider.of<AuthServiceApple>(context, listen: false);
      /* final user =*/ await authService.signInWithApple(
          scopes: [Scope.email, Scope.fullName]).then((value) async {
        print('uid: ${value.uid}');
        print('email------>: ${value.providerData[0].email}');

        QuerySnapshot snapshot =
            await ProfileService.checkUserByEmail(value.providerData[0].email!);
        if (snapshot.docs.length > 0) {
          Fluttertoast.showToast(
              msg: 'Registration already exist with this email please login');
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
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return OtherDetail(
              is_apple_register: true,
              uid: value.uid,
              email_id: value.providerData[0].email,
            );
          }));
        }

        // getUserBy(email);
      });
    } catch (e) {
      print(e);
    }
  }

  Future<UserCredential?> signInWithFacebook() async {
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
                  Fluttertoast.showToast(
                      msg:
                          'Registration already exist with this email please login');
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
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => OtherDetail(
                            is_facebook_regster: true,
                            uid: value.user!.uid,
                            email_id: value.user!.email,
                          )));
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
  Widget build(BuildContext context) {
    final appleSignInAvailable =
        Provider.of<AppleSignInAvailable>(context, listen: false);
    return Stack(
      children: [
        Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
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
                          txtSignUpAccount,
                          color: appPrimaryColor,
                        ),
                        const SizedBox(height: 5),
                        appDivider(),
                        SizedBox(height: 3.2.h),
                        appText(
                          txtRegisterYourAccount,
                          color: black,
                          fontWeight: FontWeight.w500,
                          fontSize: 20.sp,
                        ),
                        SizedBox(height: 1.5.h),
                        appText(txtRegisterDesc, fontSize: 12.sp),
                        SizedBox(height: 3.h),
                        appTextFormField(
                          validator: (value) {
                            if (value == null || value == '') {
                              return txtPleaseEnterRestaurantName;
                            } else {
                              return null;
                            }
                          },
                          title: txtRestaurantName,
                          hintText: txtRestaurantName,
                          controller: _restaurantnameController,
                        ),
                        SizedBox(height: 3.h),
                        appTextFormField(
                          validator: (value) {
                            if (value == null || value == '') {
                              return txtPleaseEnterManagerName;
                            } else {
                              return null;
                            }
                          },
                          title: txtManagerName,
                          hintText: txtManagerName,
                          controller: _managernameController,
                        ),
                        SizedBox(height: 3.h),
                        appTextFormField(
                          validator: (value) {
                            if (value == null || value == '') {
                              return txtPleaseEnterYourEmail;
                            } else if (!isEmail(value)) {
                              return txtPleaseEnterValidEmail;
                            } else {
                              return null;
                            }
                          },
                          title: txtEmailID,
                          hintText: txtEnterEmailAddress,
                          controller: _emailIDController,
                        ),
                        SizedBox(height: 3.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 100,
                              child: CountryCodePicker(
                                onChanged: (value) {
                                  setState(() {
                                    countryCode = value.toString();
                                  });
                                  print(value);
                                },
                                // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                initialSelection: 'IT',
                                favorite: ['+39', 'IT'],
                                // optional. Shows only country name and flag
                                showCountryOnly: false,
                                showOnlyCountryWhenClosed: false,
                                alignLeft: false,
                              ),
                            ),
                            Expanded(
                              child: appTextFormField(
                                validator: (value) {
                                  return mobileNumberValidation(value);
                                },
                                title: txtMobileNumber,
                                hintText: txtEnterMobileNumber,
                                controller: _mobileNoController,
                                isPrefix: false,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 3.h),
                        appButton(
                          width: 100.w,
                          text: txtNext,
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              restaurant_name = _restaurantnameController.text;
                              manager_name = _managernameController.text;
                              email_id = _emailIDController.text;
                              mobile_no = _mobileNoController.text;

                              final provider = Provider.of<AuthServices>(
                                  context,
                                  listen: false);
                              provider.setLoaderState(true);

                              int check =
                                  await provider.checkEmailAndMobileExist(
                                      email: _emailIDController.text,
                                      mobile: _mobileNoController.text);

                              if (check == 1) {
                                Fluttertoast.showToast(
                                    msg: txtThisEmailAddressAlreadyExist);
                                provider.setLoaderState(false);
                              } else if (check == 2) {
                                Fluttertoast.showToast(
                                    msg: txtThisMobileNumberAlreadyExist);
                                provider.setLoaderState(false);
                              } else {
                                await verifyPhoneNumber(
                                    context: context,
                                    phoneNumber: _mobileNoController.text);
                                // provider.setLoaderState(false);
                              }
                            }
                          },
                        ),
                        SizedBox(height: 1.5.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: txtByClickingIAcceptThe,
                              style: defaultTextStyle(height: 1.5),
                              children: [
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
                                  text: txtTermsAndCondition,
                                  style: defaultTextStyle(
                                    decoration: TextDecoration.underline,
                                    color: appPrimaryColor,
                                  ),
                                ),
                                TextSpan(
                                  text: " & ",
                                  style: defaultTextStyle(),
                                ),
                                TextSpan(
                                  text: txtPrivacyPolicy,
                                  style: defaultTextStyle(
                                    decoration: TextDecoration.underline,
                                    color: appPrimaryColor,
                                  ),
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
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
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
                        SizedBox(height: 3.h),
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
                                    await _signInWithApple(context);
                                  },
                                ),
                              imageButton(
                                path: iconGoogleLogo,
                                onTap: () async {
                                  final _provider = Provider.of<AuthServices>(
                                      context,
                                      listen: false);
                                  _provider.setLoaderState(true);
                                  try {
                                    await _provider.googleLogin(
                                        context: context);
                                    if (_provider.uid != null &&
                                        _provider.uid != 'registered') {
                                      print(_provider.uid);

                                      Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                              builder: (context) => OtherDetail(
                                                    email_id: _provider.emailId,
                                                  )),
                                          (Route<dynamic> route) => false);
                                    } else if (_provider.uid == 'registered') {
                                      Fluttertoast.showToast(
                                          msg:
                                              'Registration already exist with this email please login');
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: txtPleaseSelectAccountToLogin);
                                    }
                                  } catch (e) {
                                    print('login error' + e.toString());
                                    _provider.setLoaderState(false);
                                  }
                                  _provider.setLoaderState(false);
                                },
                              ),
                              imageButton(
                                path: iconFbLogo,
                                onTap: () async {
                                  await signInWithFacebook();
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: txtAlreadyHaveAnAccount,
                              style: defaultTextStyle(fontSize: 12.sp),
                              children: [
                                TextSpan(
                                  text: txtSignIn,
                                  style: defaultTextStyle(
                                      color: appPrimaryColor, fontSize: 12.sp),
                                  recognizer: new TapGestureRecognizer()
                                    ..onTap = () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return LoginScreen();
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
        Provider.of<AuthServices>(context).isLoading
            ? LoaderLayoutWidget()
            : SizedBox.shrink(),
      ],
    );
  }
}
