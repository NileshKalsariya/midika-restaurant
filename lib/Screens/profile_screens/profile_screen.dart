import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/route_manager.dart';
import 'package:midika/Internationalization/controller.dart';
import 'package:midika/Internationalization/shar_pref.dart';
import 'package:midika/Screens/home_screen/home_screen_widget.dart';
import 'package:midika/Screens/login_screen/login_screen.dart';
import 'package:midika/Screens/webview/privacy_policy.dart';
import 'package:midika/Screens/webview/terms_condition.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/models/location_mode.dart';
import 'package:midika/models/restaurant_model.dart';
import 'package:midika/provider/location_provider.dart';
import 'package:midika/provider/user_provider.dart';
import 'package:midika/services/auth_services.dart';
import 'package:midika/services/profile_services.dart';
import 'package:midika/utils/asset_paths.dart';
import 'package:midika/utils/colors.dart';
import 'package:midika/utils/strings.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'my_profile_screen.dart';

class LanguageModel {
  String name;
  Locale locale;

  LanguageModel({required this.locale, required this.name});
}

class ProfileScreen1 extends StatefulWidget {
  const ProfileScreen1({Key? key}) : super(key: key);

  @override
  _ProfileScreen1State createState() => _ProfileScreen1State();
}

class _ProfileScreen1State extends State<ProfileScreen1> {
  AuthServices auth = new AuthServices();

  final List<LanguageModel> _languageList = [
    LanguageModel(locale: const Locale('en', 'us'), name: 'English'),
    LanguageModel(locale: const Locale('it', 'CH'), name: 'Italian'),
  ];

  String _selectedLan = 'English';
  String? uid;

  final LanguageController _languageController = Get.put(LanguageController());

  @override
  void initState() {
    // TODO: implement initState
    setSelectedLanAndUid();
    super.initState();
    getData();
  }

  setSelectedLanAndUid() async {
    Shared_Preferences.prefGetLanguage().then((value) {
      if (value != null) {
        for (LanguageModel model in _languageList) {
          if (model.locale.languageCode == value) {
            setState(() => _selectedLan = model.name);
          }
        }
      }
    });

    uid = await Shared_Preferences.prefGetUID();
  }

  Restaurant profile = Restaurant(
      restaurantEmail: txtEmailHint,
      restaurantPhoneNumber: txtMobileNumberHint,
      // profileImageUrl: "",
      restaurantName: "restaurant name",
      restaurantImage:
          'https://www.exemplars.health/-/media/placeholders/feature/data-visualization/dataexplorer-noimage-placeholder.png');

  getData() {
    setState(() {
      profile = Provider.of<RestaurantProvider>(context, listen: false)
          .GetRestaurant!;
      print(profile.restaurantId);
      print('this is uid of user');
    });

    // ProfileService().getUser().then((value) {
    //   setState(() {
    //     profile = value;
    //   });
    // });
  }

  final List<String> _months = [
    txtJan,
    txtFeb,
    txtMar,
    txtApr,
    txtMay,
    txtJun,
    txtJul,
    txtAug,
    txtSep,
    txtOct,
    txtNov,
    txtDec,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<RestaurantProvider>(
          builder: (context, data, child) {
            return SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 30.0),
                  restaurantModelInfo1(
                    restaurant: profile,
                    context: context,
                    imgUrl: data.restaurantModel.restaurantImage,
                    userName: data.restaurantModel.restaurantName,
                    email: profile.restaurantEmail == ''
                        ? 'user email'
                        : data.restaurantModel.restaurantEmail,
                  ),
                  const SizedBox(height: 5.0),
                  FutureBuilder<Restaurant>(
                    future: ProfileService().getUser(uid: uid),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(30)),
                                  color: const Color(0xffF7F7F7),
                                  border: Border.all(
                                      color: const Color(0xffE1E1E1), width: 1),
                                ),
                                child: Center(
                                  child: appText(
                                    '$txtPlanPuchasedOn : ${snapshot.data!.subscriptionStart!.day} ${_months[snapshot.data!.subscriptionStart!.month - 1]} ${snapshot.data!.subscriptionStart!.year}',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                height: 45,
                              ),
                              Container(
                                height: 100,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(30)),
                                  color: const Color(0xffF7F7F7),
                                  border: Border.all(
                                      color: const Color(0xffE1E1E1), width: 1),
                                ),
                                child: Column(
                                  children: [
                                    appText(
                                      '$txtValidThrough : ${snapshot.data!.subscriptionEnd!.day} ${_months[snapshot.data!.subscriptionEnd!.month - 1]} ${snapshot.data!.subscriptionEnd!.year}',
                                      color: const Color(0xff7E7E7E),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        appText(
                                            '${(snapshot.data!.subscriptionEnd!).difference(DateTime.now()).inDays}',
                                            fontSize: 28,
                                            fontWeight: FontWeight.w500),
                                        appText(' $txtDayLeft')
                                      ],
                                    )
                                  ],
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                ),
                              ),
                            ],
                          ),
                        );

                        // return Align(
                        //   alignment: Alignment.center,
                        //   child: Padding(
                        //     padding: const EdgeInsets.symmetric(horizontal: 30),
                        //     child: Column(
                        //       crossAxisAlignment: CrossAxisAlignment.start,
                        //       children: [
                        //         appText(
                        //             'purchased on : ${snapshot.data!.subscriptionStart!.day}/${snapshot.data!.subscriptionStart!.month}/${snapshot.data!.subscriptionStart!.year}'),
                        //         appText(
                        //             'valid through : ${snapshot.data!.subscriptionEnd!.day}/${snapshot.data!.subscriptionEnd!.month}/${snapshot.data!.subscriptionEnd!.year}'),
                        //         appText(
                        //             'day lefts : ${(snapshot.data!.subscriptionEnd!).difference(snapshot.data!.subscriptionStart!).inDays}'),
                        //       ],
                        //     ),
                        //   ),
                        // );
                      } else {
                        return Container();
                      }
                    },
                  ),
                  DropdownButton(
                    borderRadius: BorderRadius.circular(12),
                    elevation: 1,
                    value: _selectedLan,
                    underline: const Text(''),
                    items: _languageList
                        .map(
                          (e) => DropdownMenuItem(
                            child: Text(e.name),
                            value: e.name,
                            onTap: () {
                              //todo change language here
                              Shared_Preferences.prefSetLanguage(
                                  e.locale.languageCode);
                              _languageController.changeLanguage(
                                languageCode: e.locale.languageCode,
                                countryCode: e.locale.countryCode!,
                              );
                            },
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedLan = value.toString());
                    },
                  ),
                  const SizedBox(height: 30.0),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return MyProfileScreen(profile: profile);
                              },
                            ),
                          );
                        },
                        leading: appIcon(
                          path: iconUser,
                          height: 40,
                          width: 40,
                        ),
                        title: appText(txtMyProfile),
                        trailing:
                            appIcon(path: iconNext, width: 24, height: 24),
                      ),
                      // const SizedBox(height: 10.0),
                      // ListTile(
                      //   leading: appIcon(
                      //     path: iconEye,
                      //     height: 40,
                      //     width: 40,
                      //   ),
                      //   title: appText('Change Password'),
                      //   trailing:
                      //       appIcon(path: iconNext, width: 24, height: 24),
                      // ),
                      const SizedBox(height: 10.0),

                      ListTile(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return PrivacyPolicyWebView(
                                url:
                                    'https://www.iubenda.com/privacy-policy/24473998');
                          }));
                        },
                        leading: appIcon(
                          path: iconSecure,
                          height: 40,
                          width: 40,
                        ),
                        title: appText(txtPrivacyPolicy),
                        trailing:
                            appIcon(path: iconNext, width: 24, height: 24),
                      ),
                      const SizedBox(height: 10.0),
                      ListTile(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return AppWebView(
                                url:
                                    'https://www.iubenda.com/terms-and-conditions/10753089');
                          }));
                        },
                        leading: appIcon(
                          path: iconList,
                          height: 40,
                          width: 40,
                        ),
                        title: appText(txtTermsAndCondition),
                        trailing:
                            appIcon(path: iconNext, width: 24, height: 24),
                      ),
                      ListTile(
                        leading: appIcon(
                          path: icon_logout,
                          height: 40,
                          width: 40,
                        ),
                        onTap: () => {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (ctx) => AlertDialog(
                              // title: Text("Alert Dialog Box"),
                              content: appText(txtAreYouSureYouWantToLogout),
                              actions: <Widget>[
                                FlatButton(
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                  },
                                  child: appText(txtNo, color: black),
                                ),
                                FlatButton(
                                  color: appPrimaryColor,
                                  onPressed: () async {
                                    Provider.of<AuthServices>(context,
                                            listen: false)
                                        .isLoading = true;
                                    Provider.of<AuthServices>(context,
                                            listen: false)
                                        .uid = null;
                                    await auth.signOutFromGoogle();
                                    LocationModel currentLocation =
                                        LocationModel();
                                    Provider.of<LocationProvider>(context,
                                            listen: false)
                                        .setLocationModel(currentLocation);
                                    Provider.of<AuthServices>(context,
                                            listen: false)
                                        .isLoading = false;
                                    Navigator.of(context, rootNavigator: true)
                                        .pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (BuildContext context) {
                                          return LoginScreen();
                                        },
                                      ),
                                      (_) => false,
                                    );
                                  },
                                  child: appText(txtYes, color: white),
                                ),
                              ],
                            ),
                          ),
                        },
                        title: appText(txtLogout),
                        trailing:
                            appIcon(path: iconNext, width: 24, height: 24),
                      ),
                      const SizedBox(height: 30.0),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

Widget restaurantModelInfo1({
  required String? imgUrl,
  required String? userName,
  required String? email,
  required BuildContext context,
  required Restaurant restaurant,
}) {
  bool noimage = false;
  if (imgUrl == appLogo) {
    noimage = true;
  }
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(height: 2.h),
      Stack(
        children: [
          ClipOval(
            child: CachedNetworkImage(
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(
                value: downloadProgress.progress,
                color: appPrimaryColor,
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
              imageUrl: imgUrl.toString(),
              width: 125.0,
              height: 125.0,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return MyProfileScreen(profile: restaurant);
                }));
              },
              child: Container(
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.camera),
                ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10.0),
      appText(
        userName!,
        fontSize: 20.sp,
        fontWeight: FontWeight.w500,
      ),
      const SizedBox(height: 6.0),
      appText(
        email!,
        color: black400,
      ),
    ],
  );
}
