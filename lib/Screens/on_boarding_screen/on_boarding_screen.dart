import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:midika/Screens/login_screen/login_screen.dart';
import 'package:midika/Screens/register_screen/register_screen.dart';
import 'package:midika/common/app_button.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/utils/asset_paths.dart';
import 'package:midika/utils/colors.dart';
import 'package:midika/utils/strings.dart';
import 'package:sizer/sizer.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);

  double currentIndexPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset(assetName, width: width);
  }

  Widget _body(String imgName, String title, String body) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.6.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: _buildImage(imgName),
          ),
          SizedBox(height: 5.h),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: appText(
              title,
              maxLines: 2,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 20.sp,
                color: const Color(0xff212121),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 1.h),
          appText(
            body,
            maxLines: 2,
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w400,
                fontSize: 11.sp,
                color: const Color(0xff7E7E7E)),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pageViewBody = [
      _body(
          imgOnBoarding1, txtSearchForFavouritesFoodNearYou, txtOnBoardingBody),
      _body(
          imgOnBoarding2, txtSearchForFavouritesFoodNearYou, txtOnBoardingBody),
      _body(
          imgOnBoarding3, txtSearchForFavouritesFoodNearYou, txtOnBoardingBody),
      _body(
          imgOnBoarding4, txtSearchForFavouritesFoodNearYou, txtOnBoardingBody),
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: 100.h,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xff37966F),
                Color(0xff17DA8A),
              ],
              begin: FractionalOffset(0.0, 0.0),
              end: FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 80.h,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 76.h,
                      child: PageView.builder(
                        onPageChanged: (value) {
                          setState(() => currentIndexPage = value.toDouble());
                        },
                        itemCount: pageViewBody.length,
                        itemBuilder: (context, index) => pageViewBody[index],
                        controller: _pageController,
                      ),
                    ),
                    DotsIndicator(
                      dotsCount: pageViewBody.length,
                      position: currentIndexPage,
                      decorator: DotsDecorator(
                        color: const Color(0xffA7FFDB),
                        activeColor: const Color(0xff37966F),
                        size: const Size.square(9.0),
                        activeSize: const Size(24.0, 9.0),
                        activeShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    currentIndexPage + 1 == 4
                        ? appButton(
                            onTap: () {
                              //todo login
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                              );
                            },
                            text: txtLogIn,
                            color: white,
                            width: 45.w,
                          )
                        : appButton(
                            width: 45.w,
                            onTap: () {
                              setState(() {
                                currentIndexPage = pageViewBody.length + 1;
                                _pageController
                                    .jumpToPage(pageViewBody.length + 1);
                              });
                            },
                            text: txtSkip,
                            color: Colors.transparent,
                          ),
                    SizedBox(width: 2.w),
                    currentIndexPage + 1 == 4
                        ? appButton(
                            onTap: () {
                              //todo signup
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen()),
                              );
                            },
                            width: 45.w,
                            text: txtSignUp,
                            isOnlyBorder: true,
                          )
                        : appButton(
                            onTap: () {
                              setState(() {
                                currentIndexPage = currentIndexPage + 1;
                                _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeIn);
                              });
                            },
                            color: white,
                            width: 45.w,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  txtNext,
                                  style: GoogleFonts.inter(
                                    color: appPrimaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Icon(
                                  Icons.east,
                                  color: appPrimaryColor,
                                  size: 14.sp,
                                ),
                              ],
                            ),
                            trailingIcon: Icons.east,
                          ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
