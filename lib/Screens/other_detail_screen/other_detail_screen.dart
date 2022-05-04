import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:midika/Screens/location_screen/location_screen.dart';
import 'package:midika/Screens/subscription/subscription_screen.dart';
import 'package:midika/common/app_button.dart';
import 'package:midika/common/app_divider.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/common/app_text_form_field.dart';
import 'package:midika/common/loader_layout.dart';
import 'package:midika/models/location_mode.dart';
import 'package:midika/provider/location_provider.dart';
import 'package:midika/services/auth_services.dart';
import 'package:midika/utils/asset_paths.dart';
import 'package:midika/utils/colors.dart';
import 'package:midika/utils/strings.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class OtherDetail extends StatefulWidget {
  String? restaurant_name;
  String? manager_name;
  String? email_id;
  String? mobile_no;
  bool? is_mobile_register;
  bool? is_apple_register;
  bool? is_facebook_regster;
  String? uid;

  OtherDetail({
    Key? key,
    String? this.restaurant_name,
    String? this.manager_name,
    String? this.email_id,
    String? this.mobile_no,
    bool? this.is_mobile_register,
    bool? this.is_apple_register,
    String? this.uid,
    bool? this.is_facebook_regster = false,
  }) : super(key: key);

  @override
  _OtherDetailState createState() => _OtherDetailState();
}

class _OtherDetailState extends State<OtherDetail> {
  TextEditingController _addressController = new TextEditingController();
  TextEditingController _zipCodeController = new TextEditingController();

  AuthServices _auth = AuthServices();

  final _formKey = GlobalKey<FormState>();

  bool showImage = false;
  ImagePicker picker = ImagePicker();
  File? image;
  String dropdownValue = txtOne;
  bool notImage = false;

  String? latitude = '';
  String? longitude = '';

  String? state = txtChooseState;
  String? city = 'Choose city';
  String? uid;
  String? RestaurantName;
  String? emailId;
  String? managerName;
  String? mobileNumber;
  bool? IsMobileRegister;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setdata();
      RestaurantName = widget.restaurant_name;
      emailId = widget.restaurant_name;
      managerName = widget.manager_name;
      mobileNumber = widget.mobile_no;
      IsMobileRegister = widget.is_mobile_register;

      print(widget.restaurant_name.toString() + 'resto name');
      print(widget.email_id.toString() + 'resto email');
      print(widget.mobile_no.toString() + 'resto mobile');
      print(widget.is_mobile_register.toString() + 'resto is mobile register');
    });
  }

  setdata() {
    setState(() {
      uid = FirebaseAuth.instance.currentUser!.uid;
      Provider.of<AuthServices>(context, listen: false).setUid(uid!);
    });
    print('this uid from provider' +
        Provider.of<AuthServices>(context, listen: false).uid!);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // IconButton(
                      //   padding: EdgeInsets.zero,
                      //   constraints: BoxConstraints(),
                      //   onPressed: () {},
                      //   icon: const Icon(Icons.arrow_back_ios_new),
                      // ),
                      const Icon(Icons.arrow_back_ios_new),
                      SizedBox(height: 2.8.h),
                      appText(
                        txtAddOtherDetail,
                        color: appPrimaryColor,
                      ),
                      const SizedBox(height: 5),
                      appDivider(),
                      SizedBox(height: 3.2.h),
                      appText(
                        txtAddYourDetail,
                        color: black,
                        fontWeight: FontWeight.w500,
                        fontSize: 20.sp,
                      ),
                      SizedBox(height: 1.5.h),
                      appText(txtRegisterDesc, fontSize: 12.sp),
                      SizedBox(height: 3.h),
                      appTextFormField(
                        validator: (val) {
                          if (val == '' || val == null) {
                            return txtPleaseEnterAddress;
                          } else {
                            return null;
                          }
                        },
                        minLine: 2,
                        title: txtAddress,
                        isReadOnly: false,
                        hintText: txtRegisterDesc,
                        controller: _addressController,
                      ),
                      SizedBox(height: 1.5.h),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return LocationScreen();
                          })).then(
                            (value) => setState(() {
                              LocationModel location =
                                  Provider.of<LocationProvider>(context,
                                          listen: false)
                                      .getLocationModel;
                              _addressController.text = location.address!;
                              _zipCodeController.text = location.zipCode!;
                              state = location.state!;
                              city = location.city!;
                              longitude = location.long!;
                              latitude = location.lat!;
                            }),
                          );
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_sharp,
                              color: appPrimaryColor,
                            ),
                            const SizedBox(width: 10),
                            appText(
                              txtAddYourDetail,
                              color: appPrimaryColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 10.sp,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 1.5.h),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                appText(
                                  txtCity,
                                  color: black,
                                  fontSize: 11.sp,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(.2),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: city,
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
                                      // setState(
                                      //   () {
                                      //     dropdownValue = newValue!;
                                      //   },
                                      // );
                                    },
                                    items: <String>[
                                      city!,
                                    ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                appText(
                                  txtState,
                                  color: black,
                                  fontSize: 11.sp,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(.2),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: state,
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
                                      // setState(
                                      //   () {
                                      //     dropdownValue = newValue!;
                                      //   },
                                      // );
                                    },
                                    items: <String>[
                                      state!,
                                    ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      appTextFormField(
                        validator: (val) {
                          if (val == '' || val == null) {
                            return txtPleaseEnterZipCode;
                          } else {
                            return null;
                          }
                        },
                        title: txtZipcode,
                        hintText: txtZipnumber,
                        controller: _zipCodeController,
                        keyboardType: TextInputType.number,
                        isReadOnly: false,
                      ),
                      SizedBox(height: 3.h),
                      itemImage(),

                      SizedBox(height: 3.h),
                      appButton(
                          onTap: () async {
                            FocusScope.of(context).unfocus();

                            if (_formKey.currentState!.validate() &&
                                image != null) {
                              final _provider = Provider.of<AuthServices>(
                                  context,
                                  listen: false);

                              // String? RestaurantName;
                              // String? emailId;
                              // String? managerName;
                              // String? mobileNumber;
                              // bool? IsMobileRegister;

                              int login_type = 3;
                              String? manager_name;
                              String? restaurant_name;

                              if (IsMobileRegister == true) {
                                login_type = 1;
                                manager_name = widget.manager_name;
                                restaurant_name = widget.restaurant_name;
                              }
                              if (widget.is_apple_register == true) {
                                login_type = 2;
                              }
                              _provider.setLoaderState(true);
                              await _provider.saveRestaurantUser(
                                  context: context,
                                  image: image,
                                  address: _addressController.text,
                                  city: city!,
                                  state: state!,
                                  zipcode: _zipCodeController.text,
                                  longitude: longitude!,
                                  latitude: latitude!,
                                  login_type: login_type,
                                  phone_number: widget.mobile_no,
                                  restaurant_name: restaurant_name,
                                  manager_name: manager_name,
                                  appleUid: widget.uid,
                                  email: widget.email_id,
                                  is_facebook_login: widget.is_facebook_regster,
                                  is_apple_login:
                                      widget.is_apple_register == true
                                          ? true
                                          : false);
                              _provider.setLoaderState(false);
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SubscriptionScreen(),
                                ),
                                (context) => false,
                              );

                              // Navigator.pushAndRemoveUntil(context,
                              //     MaterialPageRoute(builder: (context) {
                              //   return BottomNavigationRootScreen();
                              // }), (context) => false);
                              _provider.setLoaderState(false);
                            } else if (image == null) {
                              Fluttertoast.showToast(msg: txtPleaseEnterImage);
                            }
                          },
                          text: txtSignUp,
                          width: double.infinity),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Provider.of<AuthServices>(context, listen: true).isLoading
            ? LoaderLayoutWidget()
            : SizedBox.shrink(),
      ],
    );
  }

  Future<File> cropImage(File image) async {
    File? croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        cropStyle: CropStyle.rectangle,
        aspectRatioPresets: [CropAspectRatioPreset.ratio16x9],
        androidUiSettings: const AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: appPrimaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.ratio16x9,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(title: "Cropper"));

    return croppedFile!;
  }

  Future getImage() async {
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 50);
    final File croppedFile = await cropImage(File(pickedFile!.path));

    setState(
      () {
        if (croppedFile != null) {
          image = File(croppedFile.path);
          showImage = true;
        } else {
          print('No image selected.');
        }
      },
    );
  }

  Widget itemImage() {
    return showImage
        ? Container(
            child: Stack(
              children: [
                DottedBorder(
                  dashPattern: [10, 7],
                  color: Colors.grey,
                  borderType: BorderType.RRect,
                  strokeCap: StrokeCap.round,
                  strokeWidth: 1,
                  padding: const EdgeInsets.all(6),
                  radius: const Radius.circular(12),
                  child: SizedBox(
                      height: MediaQuery.of(context).size.height / 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          image!,
                          width: double.infinity,
                          fit: BoxFit.fill,
                        ),
                      )),
                ),
                Positioned(
                  left: 80,
                  right: 80,
                  bottom: 20,
                  child: GestureDetector(
                    onTap: () async {
                      await getImage();
                    },
                    child: Container(
                      height: 30,
                      width: 100,
                      decoration: BoxDecoration(
                          color: appPrimaryColor,
                          borderRadius: BorderRadius.circular(30)),
                      child: Center(
                        child: appText(
                          txtChange,
                          color: white,
                          fontWeight: FontWeight.w500,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : DottedBorder(
            dashPattern: [10, 7],
            color: Colors.grey,
            borderType: BorderType.RRect,
            strokeCap: StrokeCap.round,
            strokeWidth: 1,
            padding: EdgeInsets.all(6),
            radius: Radius.circular(12),
            child: ClipRRect(
              child: SizedBox(
                height: 170,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Center(
                        child: Image.asset(
                      imgUpload,
                      width: 70,
                      height: 70,
                    )),
                    appText(
                      txtUploadRestoImg,
                      color: black,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                    ),
                    GestureDetector(
                      onTap: () async {
                        await getImage();
                      },
                      child: Container(
                        height: 30,
                        width: MediaQuery.of(context).size.width / 3,
                        decoration: BoxDecoration(
                            color: appPrimaryColor,
                            borderRadius: BorderRadius.circular(30)),
                        child: Center(
                          child: appText(
                            txtUpload,
                            color: white,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 0,
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
