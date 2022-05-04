import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:midika/utils/colors.dart';
import 'package:sizer/sizer.dart';

Widget appButton(
    {double? width,
    Widget? child,
    IconData? leadingIcon,
    IconData? trailingIcon,
    String? text,
    Color? color,
    Color? borderColor,
    bool isOnlyBorder = false,
    required Function() onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 5.5.h,
      width: width ?? 50.w,
      decoration: BoxDecoration(
        color: isOnlyBorder ? Colors.transparent : color ?? appPrimaryColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(100),
        ),
        border: Border.all(
          color: isOnlyBorder
              ? borderColor ?? white
              : color == Colors.transparent
                  ? Colors.transparent
                  : appPrimaryColor,
          width: isOnlyBorder ? 2 : 0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: child ??
            Row(
              children: [
                Icon(
                  leadingIcon,
                  size: 14.sp,
                  color: white,
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      text!,
                      style: GoogleFonts.rubik(
                        color: color == Colors.white ? appPrimaryColor : white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Icon(
                  trailingIcon,
                  size: 14.sp,
                  color: color,
                )
              ],
            ),
      ),
    ),
  );
}

Widget imageButton({
  required String path,
  required void Function() onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Image.asset(
      path,
      width: 40,
      height: 40,
    ),
  );
}

Widget appButtonWithOnlyBorder(
    {double? width,
    Widget? child,
    IconData? leadingIcon,
    IconData? trailingIcon,
    String? text,
    Color? color,
    bool isOnlyBorder = false,
    required Function() onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 5.5.h,
      width: width ?? 50.w,
      decoration: BoxDecoration(
        color: isOnlyBorder ? Colors.transparent : color ?? appPrimaryColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(100),
        ),
        border: Border.all(
          color: isOnlyBorder
              ? appPrimaryColor
              : color == Colors.transparent
                  ? Colors.transparent
                  : appPrimaryColor,
          width: isOnlyBorder ? 2 : 0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: child ??
            Row(
              children: [
                Icon(
                  leadingIcon,
                  size: 14.sp,
                  color: white,
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      text!,
                      style: GoogleFonts.rubik(
                        color: color == Colors.white ? appPrimaryColor : white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Icon(
                  trailingIcon,
                  size: 14.sp,
                  color: color,
                )
              ],
            ),
      ),
    ),
  );
}
