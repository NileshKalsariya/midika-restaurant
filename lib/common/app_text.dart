import 'package:flutter/cupertino.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:midika/utils/colors.dart';
import 'package:sizer/sizer.dart';

Widget appText(
  String data, {
  TextStyle? style,
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  TextAlign? textAlign,
  bool isUnderLine = false,
  int? maxLines,
  bool isTextOverflow = false,
}) {
  return Text(
    data.tr,
    overflow: isTextOverflow ? TextOverflow.ellipsis : null,
    maxLines: maxLines,
    style: style ??
        GoogleFonts.rubik(
          fontSize: fontSize ?? 12.sp,
          fontWeight: fontWeight ?? FontWeight.w400,
          color: isUnderLine ? appPrimaryColor : color ?? black800,
          decoration:
              isUnderLine ? TextDecoration.underline : TextDecoration.none,
        ),
    textAlign: textAlign,
  );
}

TextStyle defaultTextStyle(
    {Color? color,
    double? height,
    double? fontSize,
    FontWeight? fontWeight,
    TextDecoration? decoration}) {
  return GoogleFonts.rubik(
    fontSize: fontSize ?? 11.sp,
    fontWeight: fontWeight ?? FontWeight.w400,
    color: color ?? black800,
    decoration: decoration,
    height: height,
  );
}
