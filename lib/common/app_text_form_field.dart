import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:midika/Screens/home_screen/home_screen_widget.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/utils/colors.dart';
import 'package:sizer/sizer.dart';

Widget appTextFormField({
  required String title,
  required String hintText,
  required TextEditingController controller,
  Widget? suffix,
  String prefixText = "",
  bool isPrefix = false,
  bool isTitle = true,
  bool isPrefixIcon = false,
  String path = "",
  double radius = 12,
  double fontSize = 12,
  bool isReadOnly = false,
  String? Function(String?)? validator,
  TextInputAction? textInputAction,
  TextInputType? keyboardType,
  int? maxline = 5,
  int? minLine = 1,
  String? Function(String?)? onchanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      isTitle ? appText(title) : Container(),
      isTitle ? SizedBox(height: 0.8.h) : Container(),
      Container(
        // padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
        decoration: BoxDecoration(
          color: textFieldColor,
          borderRadius: BorderRadius.all(
            Radius.circular(radius),
          ),
        ),
        child: Row(
          children: [
            isPrefix ? appText(prefixText) : Container(),
            isPrefixIcon
                ? appIcon(
                    path: path,
                    color: black,
                  )
                : Container(),
            SizedBox(width: isPrefix || isPrefixIcon ? 10 : 0),
            Expanded(
              child: TextFormField(
                minLines: minLine,
                maxLines: maxline,
                cursorColor: appPrimaryColor,
                controller: controller,
                decoration: InputDecoration(
                  hintText: hintText,
                  filled: true,
                  fillColor: Colors.grey.withOpacity(.2),
                  focusColor: Colors.grey.withOpacity(0.05),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey.withOpacity(0.05),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey.withOpacity(0.05),
                    ),
                  ),
                ),
                validator: validator,
                readOnly: isReadOnly,
                textInputAction: textInputAction,
                keyboardType: keyboardType,
                onChanged: onchanged,
              ),
            ),
          ],
        ),
      )
    ],
  );
}
