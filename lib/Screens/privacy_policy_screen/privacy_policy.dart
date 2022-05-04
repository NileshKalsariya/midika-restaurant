import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/utils/asset_paths.dart';
import 'package:midika/utils/colors.dart';
import 'package:midika/utils/strings.dart';
import 'package:sizer/sizer.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        title: appText(txtPrivacyPolicy),
        leading: GestureDetector(
          child: const Icon(Icons.arrow_back_ios_new, color: black),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 36.w),
                    child: Image.asset(
                      appLogo,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        txtMi,
                        style: GoogleFonts.josefinSans(
                          fontWeight: FontWeight.w400,
                          fontSize: 26.sp,
                          color: const Color(0xff37966F),
                        ),
                      ),
                      Text(
                        txtDika,
                        style: GoogleFonts.josefinSans(
                          fontWeight: FontWeight.w400,
                          fontSize: 26.sp,
                          color: const Color(0xffFD5523),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              appText(
                'Terms of use',
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: 1.h),
              appText(
                'Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit. xercitation veniam consequat sunt nostrud amet.Amet inim mollit non deserunt ullamco est sit aliqua dolor do met sint. Velit officia consequat duis enim velit mollit. xercitation eniam consequat sunt nostrud amet.Amet minim mollit non eserunt ullamco est sit aliqua dolor do amet sint. Velit officia onsequat duis enim velit mollit. Exercitation veniam consequat sunt.',
                color: black400,
                fontSize: 11.sp,
              ),
              SizedBox(height: 3.h),
              appText(
                txtPrivacyPolicy,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: 1.h),
              appText(
                'Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit. xercitation veniam consequat sunt nostrud amet.Amet inim mollit non deserunt ullamco est sit aliqua dolor do met sint. Velit officia consequat duis enim velit mollit. xercitation eniam consequat sunt nostrud amet.Amet minim mollit non eserunt ullamco est sit aliqua dolor do amet sint. Velit officia onsequat duis enim velit mollit. Exercitation veniam consequat sunt.',
                color: black400,
                fontSize: 11.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
