import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:midika/Screens/bottom_navigation_root_screen/navigation_root_screen.dart';
import 'package:midika/Screens/otp_verification/mobile_otp_verification.dart';
import 'package:midika/models/item_category_model.dart';
import 'package:midika/models/operational_hours_model.dart';
import 'package:midika/models/restaurant_model.dart';
import 'package:midika/provider/user_provider.dart';
import 'package:midika/services/profile_services.dart';
import 'package:midika/services/storage_method.dart';
import 'package:midika/utils/firebase_references.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'category_services.dart';

List<String> days = [
  "Sunday",
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
];

class AuthServices extends ChangeNotifier {
  bool isLoggedIn = false;
  bool otpSent = false;
  String? uid;
  bool isLoading = false;
  String _verificationId = 'null';
  int _resendToken = 0;

  String emailId = "null";

  get getEmailId => emailId;

  get getIsLoggedIn => isLoggedIn;

  get getOtpSent => otpSent;

  get getUid => uid;

  get getIsLoading => isLoading;

  get getVerificationId => _verificationId;

  get getReSendToken => _resendToken;

  List<ItemCategory> categoryList = [];

  List<ItemCategory> get getCategoryList => categoryList;

  setCategories() async {
    CategoryService categoryService = CategoryService();
    categoryList = await categoryService.getCategories();
    notifyListeners();
  }

  GoogleSignInAccount? _user;

  GoogleSignInAccount? get getGoogleuser => _user!;

  setLoaderState(bool state) {
    isLoading = state;
    notifyListeners();
  }

  setUid(String val) {
    uid = val;
    notifyListeners();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future verifyPhoneNumber({
    required String phoneNumber,
    required BuildContext context,
    bool? otpScreen,
    Function? setData,
    String? countryCode,
  }) async {
    PhoneVerificationCompleted phoneVerificationCompleted =
        (PhoneAuthCredential phoneAuthCredential) {
      // showSnackBar(context: context, text: 'Verification Completed');
    };

    PhoneCodeSent phoneCodeSent =
        (String verificationID, [int? forceResendinToken]) {
      if (otpScreen == true) {
        print('call on auth service');
        setData!(verificationID: verificationID);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MobileOtpVerification(
              phoneNumber: phoneNumber,
              verificationID: verificationID,
            ),
          ),
        );
      }
    };

    PhoneCodeAutoRetrievalTimeout phoneCodeAutoRetrievalTimeout =
        (String verificationID) {};

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: "$countryCode $phoneNumber",
          timeout: const Duration(seconds: 60),
          verificationCompleted: phoneVerificationCompleted,
          verificationFailed: (FirebaseAuthException exception) {
            if (exception.code == 'invalid-phone-number') {
              showSnackBar(
                  context: context,
                  text: 'The provided phone number is not valid.');
            }
          },
          codeSent: phoneCodeSent,
          codeAutoRetrievalTimeout: phoneCodeAutoRetrievalTimeout);
    } catch (e) {
      print(e.toString());
      showSnackBar(context: context, text: "Something went wrong, try Again!");
    }
  }

  static void showSnackBar(
      {required BuildContext context, required String text}) {
    final snackBar = SnackBar(content: Text(text));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future googleLoginLoginScreen({required BuildContext context}) async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        if (googleSignInAuthentication.accessToken != null &&
            googleSignInAuthentication.idToken != null) {
          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken,
          );
          GoogleSignInAccount googleUser = googleSignInAccount;
          if (googleUser.email != '' && googleUser.email != null) {
            QuerySnapshot snapshot =
                await ProfileService.checkUserByEmail(googleUser.email);
            if (snapshot.docs.length > 0) {
              await ifLoginSetDataAndSendToDashBoard(
                  context: context, email_id: googleUser.email);
            } else {
              Fluttertoast.showToast(
                  msg:
                      'The email address you have entered is not registered with us, please register');
            }
          } else {
            Fluttertoast.showToast(
                msg:
                    'something went wrong with google sigin in try again later');
          }
        }
        notifyListeners();
      } else {
        notifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      notifyListeners();
      return 0;
    }
    notifyListeners();
  }

  Future googleLogin({required BuildContext context}) async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        if (googleSignInAuthentication.accessToken != null &&
            googleSignInAuthentication.idToken != null) {
          // print(googleSignInAuthentication.accessToken);
          // print(googleSignInAuthentication.idToken);
          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken,
          );
          _user = googleSignInAccount;
          emailId = googleSignInAccount.email;
          print(_user.toString() + 'this is in sign in user');

          await _auth.signInWithCredential(credential);
          uid = FirebaseAuth.instance.currentUser!.uid;

          await _googleSignIn.signOut();

          print(_user!.email.toString() + 'this is email');
          final QuerySnapshot querySnapshot =
              await ProfileService.checkUserByEmail(_user!.email);

          final docExistOrNot = querySnapshot.docs.length;
          if (docExistOrNot > 0) {
            uid = 'registered';

            // print('hello');
            // final doc_id = querySnapshot.docs[0].id;
            // print(doc_id);
            // if (doc_id != '' && doc_id != null) {
            //   await saveUidPref(doc_id);
            //   await saveOnboardingooff();
            //   Restaurant default_user =
            //       await ProfileService.getUserById(id: doc_id);
            //
            //   Provider.of<RestaurantProvider>(context, listen: false)
            //       .setUser(currentUser: default_user);
            //
            //   setCategories();
            //   setLoaderState(false);
            //   ChangeNotifier();
            //   return Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
            //     builder: (context) {
            //       return BottomNavigationRootScreen();
            //     },
            //   ), (route) => false);
            // }
          }
        } else {
          setLoaderState(false);
        }
      } else {
        _user = null;
        uid = null;
        setLoaderState(false);
      }
    } on FirebaseAuthException catch (e) {
      setLoaderState(false);
      await signOutFromGoogle();
      await FirebaseAuth.instance.signOut();
      print(e.message);
      throw e;
    }
    notifyListeners();
  }

  Future saveRestaurantUser({
    File? image,
    required BuildContext context,
    required String address,
    required String city,
    required String state,
    required String zipcode,
    required String latitude,
    required String longitude,
    required int login_type,
    String? phone_number,
    String? restaurant_name,
    String? manager_name,
    String? email,
    String? appleUid,
    required bool is_apple_login,
    bool? is_facebook_login,
  }) async {
    var data =
        await StorageMethods().uplaodImageToServer(image, 'restaurant_image');
    final restaurantImage = data['url'];

    print(phone_number.toString() + 'in flunction.......');
    print(restaurant_name.toString() + 'in flunction.......');
    print(manager_name.toString() + 'in flunction.......');
    print(email.toString() + 'in function........');

    final token = await FirebaseMessaging.instance.getToken();
    print(token.toString() + 'this is token');

    // /connected account api call
    // final uri = Uri.parse(
    //     "http://brainwaves.rivaaninfotech.com/api/v1/stripe-user-generate-link");
    // final response = await http.post(uri, body: {
    //   "email": email,
    // });

    // SharedPreferences preferences = await SharedPreferences.getInstance();
    // preferences.setString('stripe_acc', jsonDecode(response.body)['acc_id']);
    // print(response.body.toString() + 'hllo');

    Restaurant createUser = Restaurant(
      restaurantAddress: address,
      restaurantCity: city,
      restaurantState: state,
      zipcode: zipcode,
      restaurantName: phone_number != null ? restaurant_name : '',
      restaurantManagerName: is_facebook_login!
          ? ''
          : is_apple_login
              ? ''
              : phone_number != null
                  ? manager_name.toString()
                  : _user!.displayName,
      restaurantEmail: is_facebook_login
          ? email
          : is_apple_login
              ? email
              : phone_number != null
                  ? email.toString()
                  : _user!.email,
      restaurantId: is_facebook_login
          ? uid
          : appleUid == null
              ? uid
              : appleUid,
      restaurantImage: restaurantImage,
      deviceToken: token,
      // profileImageUrl: _user!.photoUrl,
      restaurantIsActive: true,
      loginType: login_type.toString(),
      // phone =1 ,apple =2, google =3 , facebook =4
      restaurantLat: double.parse(latitude),
      restaurantLng: double.parse(longitude),
      restaurantPhoneNumber: phone_number ?? '',

      // stripeAccountId: jsonDecode(response.body)['acc_id'],
      stripeAccountId: null,
      addedOn: DateTime.now().millisecondsSinceEpoch.toString(),
      stripeAccountIsVerified: false,
      subscriptionActive: false,
    );

    ProfileService.setUser(createUser);
    Provider.of<RestaurantProvider>(context, listen: false)
        .setUser(currentUser: createUser);

    setCategories();

    for (int i = 0; i < days.length; i++) {
      OperationalHours hours = OperationalHours(
        number: i + 1,
        day: days[i],
        isClose: false,
        isOpen24: true,
        addedOn: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      DocumentReference documentReference = await FirebaseFirestore.instance
          .collection(FirebaseReferences.user_collection)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('operational_hours')
          .doc(days[i]);

      await documentReference.set(hours.toJson());
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('uid', appleUid != null ? appleUid : uid!);

    prefs.setString('onboarding', 'off');
  }

  ///update subscription end
  void updateRestaurantUser({required DateTime date}) {
    log('---on update---------- $date');

    FirebaseFirestore.instance
        .collection(FirebaseReferences.user_collection)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'subscription_start': DateTime.now(),
      'subscription_end': date,
      'subscription_active': true,
    });
  }

  Future<void> signOutFromGoogle() async {
    await _googleSignIn.signOut();
    _user = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('uid');
    await _auth.signOut();
    uid = null;
    notifyListeners();
  }

  saveUidPref(userId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('uid', userId!);
  }

  Future saveOnboardingooff() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('onboarding', 'off');
  }

  Future<int> checkEmailAndMobileExist(
      {required String email, required String mobile}) async {
    QuerySnapshot querySnap = await ProfileService.checkUserByEmail(email);
    if (querySnap.docs.length > 0) {
      return 1; // email exist
    } else {
      QuerySnapshot mobileSnap = await ProfileService.checkUserByMobile(mobile);
      if (mobileSnap.docs.length > 0) {
        return 2; // mobile exist
      } else {
        return 0; // everything ok
      }
    }
  }

  Future<int> checkEmail({required String phone}) async {
    QuerySnapshot querySnap = await ProfileService.checkUserByMobile(phone);
    if (querySnap.docs.length > 0) {
      return 1;
    } else {
      return 0;
    }
  }

  static Future ifLoginSetDataAndSendToDashBoard(
      {required String email_id, required BuildContext context}) async {
    Restaurant restaurant =
        await ProfileService.getUserByEmailID(email: email_id);
    if (restaurant.restaurantId != '' || restaurant.restaurantId != null) {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      _prefs.setString('uid', restaurant.restaurantId!);
      _prefs.setString('onboarding', 'off');
      Provider.of<RestaurantProvider>(context, listen: false)
          .setUser(currentUser: restaurant);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => BottomNavigationRootScreen()),
          (Route<dynamic> route) => false);
    }
  }
}
