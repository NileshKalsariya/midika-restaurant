import 'package:flutter/material.dart';
import 'package:midika/common/app_button.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/utils/asset_paths.dart';
import 'package:midika/utils/colors.dart';
import 'package:midika/utils/strings.dart';
import 'package:sizer/sizer.dart';

class ItemAdded extends StatefulWidget {
  const ItemAdded({Key? key}) : super(key: key);

  @override
  _ItemAddedState createState() => _ItemAddedState();
}

class _ItemAddedState extends State<ItemAdded> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width,
                    child: Image.asset(itemAddedImg),
                  ),
                  Positioned(
                    bottom: MediaQuery.of(context).size.height / 10,
                    left: MediaQuery.of(context).size.width / 2.3,
                    child: Image.asset(
                      iconChecked,
                      height: 40,
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: appText(
                        txtYourItemHasBeenAddedSuccessfully,
                        fontSize: 12.sp,
                        color: gray2clr,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5.h,
              ),
              appButton(
                  width: MediaQuery.of(context).size.width / 1.2,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  text: txtMenu,
                  isOnlyBorder: true,
                  color: Colors.white,
                  borderColor: appPrimaryColor),
              SizedBox(
                height: 3.h,
              ),
              appButton(
                width: MediaQuery.of(context).size.width / 1.2,
                onTap: () {
                  Navigator.pop(context);
                },
                text: txtAddMoreItem,
                isOnlyBorder: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

