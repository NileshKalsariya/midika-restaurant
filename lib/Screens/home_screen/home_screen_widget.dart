import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/utils/asset_paths.dart';
import 'package:midika/utils/colors.dart';
import 'package:midika/utils/strings.dart';
import 'package:sizer/sizer.dart';

Widget homeScreenAppBar() {
  return Row(
    children: [
      appIcon(path: iconBranding, height: 43, width: 43),
      Expanded(
        child: SizedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              appIcon(
                path: iconLocation,
                color: appPrimaryColor,
              ),
              const SizedBox(width: 5),
              appText('Al Bahah'),
              const SizedBox(width: 5),
              appIcon(path: iconArrowDown)
            ],
          ),
        ),
      ),
      appIcon(path: iconNotification),
    ],
  );
}

///offer card
Widget offerCard({required int offerPercentage}) {
  return Container(
    width: 260,
    height: 170,
    decoration: const BoxDecoration(
      color: black50,
      borderRadius: BorderRadius.all(
        Radius.circular(12.0),
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, top: 16, bottom: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    appText(
                      "$offerPercentage% $txtOff",
                      fontSize: 24.sp,
                      color: black700,
                      fontWeight: FontWeight.w500,
                    ),
                    appText(txtInside, color: gray),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    appText(
                      txtOfferDesc,
                      color: lightPrimaryColor,
                    ),
                    appText(
                      txtOfferDesc1,
                      color: lightPrimaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        appIcon(path: iconOffer, width: 80, height: 80),
      ],
    ),
  );
}

///home screen
Widget itemWidget({
  required String path,
  required String title,
  required Color bgColor,
  required Color borderColor,
}) {
  return SizedBox(
    height: 100,
    width: 80,
    child: Column(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: borderColor,
          child: CircleAvatar(
            backgroundColor: bgColor,
            radius: 34,
            child: Center(
              child:
                  appIcon(path: path, height: 36, width: 36, fit: BoxFit.fill),
            ),
          ),
        ),
        const SizedBox(height: 6),
        appText(title, fontSize: 11.sp),
      ],
    ),
  );
}

///see all
Widget titleIndicatorWidget({
  required String path,
  required String title,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 20.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        appIcon(path: path),
        const SizedBox(width: 10.0),
        Expanded(
          child: appText(
            title,
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            appText(txtSeeAll, color: black600),
            const SizedBox(width: 6),
            appIcon(path: iconArrowRight),
          ],
        ),
      ],
    ),
  );
}

///restaurant Widget
Widget restaurantWidget({
  required String title,
  required String address,
  required String path,
}) {
  return SizedBox(
    height: 160,
    width: 200,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 70,
          width: 200,
          child: appIcon(path: path, height: 70, width: 200),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
        ),
        const SizedBox(height: 16),
        appText(title, fontSize: 13.sp),
        Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 6),
                  appText(
                    address,
                    color: black400,
                  ),
                ],
              ),
            ),
            appIcon(path: iconForwardArrowWithBg),
          ],
        ),
      ],
    ),
  );
}

///app icon
Widget appIcon(
    {required String path,
    Color? color,
    double width = 24,
    double height = 24,
    void Function()? onTap,
    BoxFit? fit}) {
  return GestureDetector(
    onTap: onTap,
    child: SvgPicture.asset(
      path,
      width: width,
      height: height,
      color: color,
      fit: fit != null ? fit : BoxFit.none,
    ),
  );
}
