import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:midika/Internationalization/controller.dart';
import 'package:midika/Internationalization/shar_pref.dart';
import 'package:midika/common/app_button.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/services/notification_method.dart';
import 'package:midika/services/spash_screen_service.dart';
import 'package:midika/utils/asset_paths.dart';
import 'package:midika/utils/colors.dart';
import 'package:midika/utils/strings.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_io/io.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  NotificationMethods _notification = NotificationMethods();
  final LanguageController _languageController = Get.put(LanguageController());

  @override
  void initState() {
    _notification.notificationPermission();
    _notification.inItNotification();
    _notification.onNotification();

    Shared_Preferences.prefGetLanguage().then((value) {
      if (value != null) {
        _languageController.changeLanguage(languageCode: value);
      } else if (value == null) {
        final String defaultLocale = Platform.localeName;
        log('default local on main --- $defaultLocale ---------${defaultLocale.split('_')[0]} ');
        final LanguageController _languageController =
            Get.put(LanguageController());
        _languageController.changeLanguage(
            languageCode: defaultLocale.split('_')[0]);
        Shared_Preferences.prefSetLanguage(defaultLocale.split('_')[0]);
      }
    });

    super.initState();
    Future.delayed(
      const Duration(seconds: 3),
      () async {
        await SpashScreenService().checkUser(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w),
              child: Image.asset(
                appLogo,
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  txtMi,
                  style: GoogleFonts.josefinSans(
                    fontWeight: FontWeight.w400,
                    fontSize: 36.sp,
                    color: const Color(0xff37966F),
                  ),
                ),
                Text(
                  txtDika,
                  style: GoogleFonts.josefinSans(
                    fontWeight: FontWeight.w400,
                    fontSize: 36.sp,
                    color: const Color(0xffFD5523),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NoNetScreen extends StatefulWidget {
  const NoNetScreen({Key? key}) : super(key: key);

  @override
  _NoNetScreenState createState() => _NoNetScreenState();
}

class _NoNetScreenState extends State<NoNetScreen> {
  @override
  Widget build(BuildContext context) {
    print('here');
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                icon_no_wifi,
                scale: 4,
              ),
              SizedBox(
                height: 2.h,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: appText(txtNoInterNet, textAlign: TextAlign.center),
              ),
              SizedBox(
                height: 3.h,
              ),
              appButton(
                  onTap: () async {
                    await SpashScreenService().checkUser(context);
                  },
                  text: 'Retry',
                  color: appPrimaryColor)
            ],
          ),
        ),
      ),
    );
  }
}
