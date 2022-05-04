import 'package:flutter/material.dart';
import 'package:midika/Screens/home_screen/home_screen_widget.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/common/app_text_form_field.dart';
import 'package:midika/utils/asset_paths.dart';
import 'package:midika/utils/colors.dart';
import 'package:midika/utils/strings.dart';
import 'package:sizer/sizer.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({Key? key}) : super(key: key);

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final TextEditingController _itemNameController = TextEditingController();

  String dropdownValue = txtOne;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(
          Icons.arrow_back_ios,
          color: black,
        ),
        title:
            appText(txtAddItem, fontWeight: FontWeight.w500, fontSize: 13.sp),
        backgroundColor: Colors.white,
        actions: [
          GestureDetector(
            child: appIcon(path: iconAdd),
            onTap: () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) {
              //   return AddItemScreen();
              // }));
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            appTextFormField(
                title: txtItemName,
                hintText: txtPizza,
                controller: _itemNameController),
            SizedBox(height: 3.h),
            Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      appText(
                        txtSelectGroup,
                        color: black,
                        fontSize: 11.sp,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            color: textFieldColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: dropdownValue,
                          icon: const Icon(
                            Icons.expand_more_outlined,
                            color: appPrimaryColor,
                          ),
                          elevation: 16,
                          style: defaultTextStyle(
                            color: Colors.black26,
                          ),
                          underline: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            height: 2,
                            // color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (String? newValue) {
                            setState(
                              () {
                                dropdownValue = newValue!;
                              },
                            );
                          },
                          items: <String>[txtOne, txtTwo, txtThree, txtFour]
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: EditDelete())
              ],
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      appText(
                        txtSelectGroup,
                        color: black,
                        fontSize: 11.sp,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            color: textFieldColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: dropdownValue,
                          icon: const Icon(
                            Icons.expand_more_outlined,
                            color: appPrimaryColor,
                          ),
                          elevation: 16,
                          style: defaultTextStyle(
                            color: Colors.black26,
                          ),
                          underline: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            height: 2,
                            // color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (String? newValue) {
                            setState(
                              () {
                                dropdownValue = newValue!;
                              },
                            );
                          },
                          items: <String>[txtOne, txtTwo, txtThree, txtFour]
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: EditDelete())
              ],
            ),
            SizedBox(
              height: 3.h,
            ),
            appText(txtAddModifierScreen,
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
                color: Colors.deepOrange),
          ],
        ),
      ),
    );
  }

  Widget EditDelete() {
    return Row(
      children: [
        appIcon(
          path: iconEditOrange,
          height: 40,
          width: 40,
        ),
        appIcon(
          path: iconTrash,
          height: 40,
          width: 40,
        ),
      ],
    );
  }
}
