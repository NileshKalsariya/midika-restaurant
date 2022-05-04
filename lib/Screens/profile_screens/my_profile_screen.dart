import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:midika/Screens/location_screen/location_screen.dart';
import 'package:midika/Screens/profile_screens/edit_cafe_screen.dart';
import 'package:midika/common/app_button.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/common/app_text_form_field.dart';
import 'package:midika/common/loader_layout.dart';
import 'package:midika/models/location_mode.dart';
import 'package:midika/models/restaurant_model.dart';
import 'package:midika/provider/location_provider.dart';
import 'package:midika/provider/user_provider.dart';
import 'package:midika/services/auth_services.dart';
import 'package:midika/services/notification_service.dart';
import 'package:midika/services/profile_services.dart';
import 'package:midika/services/storage_method.dart';
import 'package:midika/utils/asset_paths.dart';
import 'package:midika/utils/colors.dart';
import 'package:midika/utils/strings.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'cafe_details_screen.dart';

class MyProfileScreen extends StatefulWidget {
  Restaurant profile;

  MyProfileScreen({Key? key, required Restaurant this.profile})
      : super(key: key);

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool showImage = false;
  ImagePicker picker = ImagePicker();
  File? image;
  String? state = txtNotSelected;
  String? city = txtNotSelected;
  String? lat = '';
  String? long = '';
  String? added_on = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setData();
  }

  final _formKey = GlobalKey<FormState>();

  setData() {
    setState(
      () {
        Restaurant restaurant =
            Provider.of<RestaurantProvider>(context, listen: false)
                .restaurantModel;
        _zipCodeController.text = restaurant.zipcode.toString();
        _addressController.text = restaurant.restaurantAddress.toString();
        state = restaurant.restaurantState.toString();
        city = restaurant.restaurantCity.toString();
        lat = restaurant.restaurantLat.toString();
        long = restaurant.restaurantLng.toString();
        added_on = restaurant.addedOn.toString();
      },
    );
    print(added_on);
    ;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back_ios,
                color: black,
              ),
            ),
            title: appText(txtMyProfile,
                fontWeight: FontWeight.w500, fontSize: 13.sp),
            backgroundColor: Colors.white,
          ),
          body: Consumer<RestaurantProvider>(
            builder: (context, data, child) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 170,
                          width: double.infinity,
                          child: Stack(
                            children: [
                              image != null
                                  ? Image.file(
                                      image!,
                                      fit: BoxFit.cover,
                                      width: 100.w,
                                      height: 150,
                                    )
                                  : CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      progressIndicatorBuilder:
                                          (context, url, downloadProgress) =>
                                              CircularProgressIndicator(
                                        value: downloadProgress.progress,
                                        color: appPrimaryColor,
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                      imageUrl: data
                                          .restaurantModel.restaurantImage
                                          .toString(),
                                      width: 100.w,
                                      height: 150,
                                    ),
                              // : Image.network(
                              //     data.restaurantModel.restaurantImage
                              //         .toString(),
                              //     fit: BoxFit.cover,
                              //     width: 100.w,
                              //     height: 150,
                              //   ),
                              GestureDetector(
                                onTap: getImage,
                                child: const Align(
                                  alignment: Alignment.bottomCenter,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: Icon(Icons.camera),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 30.0),
                        Row(
                          children: [
                            Expanded(
                              child: appText(
                                txtPersonalDetails,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return CafeDetailsScreen(
                                      profile: widget.profile);
                                }));
                              },
                              child: Container(
                                height: 27,
                                width: 65,
                                decoration: BoxDecoration(
                                  color: const Color(0xffF55800),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: appText(txtEdit,
                                      fontSize: 10.sp, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        appText(
                          data.restaurantModel.restaurantName!,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        appText(
                          data.restaurantModel.restaurantEmail.toString(),
                          color: black400,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        appText(
                          data.restaurantModel.restaurantPhoneNumber ?? '',
                          color: black400,
                        ),
                        const SizedBox(height: 30.0),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return EditCafe();
                            }));
                          },
                          child: appText(
                            txtSetOperationalHours,
                            color: const Color(0xffF55800),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        appTextFormField(
                          validator: (value) {
                            if (value == '') {
                              return txtPleaseEnterAddress;
                            } else {
                              return null;
                            }
                          },
                          title: txtAddress,
                          hintText: "1560899",
                          isReadOnly: false,
                          controller: _addressController,
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          children: [
                            Image.asset(
                              iconLocation,
                              color: Colors.green,
                              height: 20,
                              width: 20,
                            ),
                            const SizedBox(width: 8.0),
                            GestureDetector(
                              onTap: () {
                                print('hello');
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return LocationScreen();
                                })).then((value) => setState(() {
                                      LocationModel location =
                                          Provider.of<LocationProvider>(context,
                                                  listen: false)
                                              .getLocationModel;
                                      _addressController.text =
                                          location.address!;
                                      _zipCodeController.text =
                                          location.zipCode!;
                                      state = location.state!;
                                      city = location.city!;
                                      long = location.long!;
                                      lat = location.lat!;
                                    }));
                              },
                              child: appText(
                                txtChangeLiveLocation,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  appText(
                                    txtState,
                                    color: black,
                                    fontSize: 11.sp,
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(.2),
                                        borderRadius:
                                            BorderRadius.circular(10)),
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
                                        decoration: BoxDecoration(
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
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 30),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  appText(
                                    txtCity,
                                    color: black,
                                    fontSize: 11.sp,
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(.2),
                                        borderRadius:
                                            BorderRadius.circular(10)),
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
                                        //     city = newValue!;
                                        //   },
                                        // );
                                      },
                                      items: <String>[city!]
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: appText(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        appTextFormField(
                          validator: (value) {
                            if (value == '') {
                              return txtPleaseEnterZipcode;
                            } else {
                              return null;
                            }
                          },
                          title: txtZipcode,
                          hintText: "1560899",
                          isReadOnly: false,
                          controller: _zipCodeController,
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        appButton(
                          text: txtUpdate,
                          width: 100.w,
                          onTap: () async {
                            final _provider = Provider.of<AuthServices>(context,
                                listen: false);
                            FocusScope.of(context).unfocus();
                            if (_formKey.currentState!.validate() &&
                                ((data.restaurantModel.restaurantImage !=
                                            null ||
                                        data.restaurantModel.restaurantImage !=
                                            '') ||
                                    image != null)) {
                              _provider.setLoaderState(true);
                              print('ok');
                              var newImage;
                              if (image != null) {
                                var data = await StorageMethods()
                                    .uplaodImageToServer(
                                        image, 'restaurant_image');
                                newImage = data['url'];
                              } else {
                                newImage = data.restaurantModel.restaurantImage;
                              }

                              Restaurant profile = Restaurant(
                                  zipcode: _zipCodeController.text.toString(),
                                  restaurantState: state,
                                  restaurantCity: city,
                                  restaurantAddress: _addressController.text,
                                  restaurantPhoneNumber: "",
                                  restaurantLng: double.parse(long!),
                                  restaurantLat: double.parse(lat!),
                                  // profileImageUrl:
                                  //     data.restaurantModel.profileImageUrl,
                                  restaurantEmail:
                                      data.restaurantModel.restaurantEmail,
                                  loginType: data.restaurantModel.loginType,
                                  restaurantManagerName: data
                                      .restaurantModel.restaurantManagerName,
                                  restaurantImage: newImage,
                                  restaurantIsActive: true,
                                  addedOn: added_on,
                                  subscriptionStart:
                                      data.restaurantModel.subscriptionStart,
                                  subscriptionEnd:
                                      data.restaurantModel.subscriptionEnd,
                                  subscriptionActive:
                                      data.restaurantModel.subscriptionActive,
                                  restaurantOpen:
                                      data.restaurantModel.restaurantOpen,
                                  deviceToken: data.restaurantModel.deviceToken,
                                  restaurantName:
                                      data.restaurantModel.restaurantName,
                                  restaurantId:
                                      data.restaurantModel.restaurantId);

                              await NotificationServices().profileUpdate(
                                  RestaurantId:
                                      data.restaurantModel.restaurantId!);

                              await ProfileService().updateUser(profile);
                              Provider.of<RestaurantProvider>(context,
                                      listen: false)
                                  .setUser(currentUser: profile);

                              _provider.setLoaderState(false);
                              Fluttertoast.showToast(
                                  msg: txtProfileUpdatedSuccessfully);
                              // Navigator.pop(context, true);
                            } else if ((image == '' || image == null) &&
                                data.restaurantModel.restaurantImage == '') {
                              Fluttertoast.showToast(
                                  msg: txtPleaseSelectRestaurantImage);
                            }
                          },
                        ),
                        SizedBox(
                          height: 5.h,
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Provider.of<AuthServices>(context).isLoading
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
        androidUiSettings: AndroidUiSettings(
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
}

Widget dropDownWithTitleWidget(
  String title,
) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      appText(title),
    ],
  );
}
