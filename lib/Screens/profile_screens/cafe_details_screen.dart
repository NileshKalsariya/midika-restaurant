import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:midika/common/app_button.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/common/app_text_form_field.dart';
import 'package:midika/common/loader_layout.dart';
import 'package:midika/models/restaurant_model.dart';
import 'package:midika/provider/user_provider.dart';
import 'package:midika/services/auth_services.dart';
import 'package:midika/services/notification_service.dart';
import 'package:midika/services/profile_services.dart';
import 'package:midika/utils/colors.dart';
import 'package:midika/utils/strings.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class CafeDetailsScreen extends StatefulWidget {
  Restaurant profile;
  CafeDetailsScreen({Key? key, required Restaurant this.profile})
      : super(key: key);

  @override
  _CafeDetailsScreenState createState() => _CafeDetailsScreenState();
}

class _CafeDetailsScreenState extends State<CafeDetailsScreen> {
  final GlobalKey<FormState> _formGlobalKey = GlobalKey();
  Restaurant? restaurantModel;
  final TextEditingController _restaurantNameController =
      TextEditingController();
  final TextEditingController _mangerNameController = TextEditingController();
  final TextEditingController _emailIdController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setdata();
  }

  setdata() {
    setState(() {
      final provider = Provider.of<RestaurantProvider>(context, listen: false)
          .restaurantModel;
      restaurantModel = provider;
      print(restaurantModel!.toJson());
      _restaurantNameController.text = provider.restaurantName.toString();
      _emailIdController.text = provider.restaurantEmail.toString();
      _mangerNameController.text = provider.restaurantManagerName.toString();
      _mobileNumberController.text = provider.restaurantPhoneNumber.toString();
    });
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final _provider = Provider.of<AuthServices>(context, listen: false);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back_ios,
                color: black,
              ),
            ),
            title: appText('Cafe Details',
                fontWeight: FontWeight.w500, fontSize: 13.sp),
            backgroundColor: Colors.white,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 16.0, bottom: 30.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          appTextFormField(
                            validator: (value) {
                              if (value == '') {
                                return txtPleaseEnterRestaurantName;
                              } else {
                                return null;
                              }
                            },
                            title: txtRestaurantName,
                            hintText: txtUserNameHint,
                            controller: _restaurantNameController,
                          ),
                          const SizedBox(height: 10.0),
                          appTextFormField(
                            validator: (value) {
                              if (value == '') {
                                return txtPleaseEnterManagerName;
                              } else {
                                return null;
                              }
                            },
                            title: txtManagerName,
                            hintText: txtUserNameHint,
                            controller: _mangerNameController,
                          ),
                          // const SizedBox(height: 10.0),
                          // appTextFormField(
                          //   validator: (value) {
                          //     if (value == '') {
                          //       return 'please enter your email';
                          //     } else {
                          //       return null;
                          //     }
                          //   },
                          //   title: txtEmailID,
                          //   hintText: txtEmailHint,
                          //   controller: _emailIdController,
                          // ),
                          // const SizedBox(height: 10.0),
                          // appTextFormField(
                          //   validator: (value) {
                          //     if (value == '') {
                          //       return 'please enter mobile number';
                          //     } else {
                          //       return null;
                          //     }
                          //   },
                          //   title: txtMobileNumber,
                          //   hintText: txtMobileNumberHint,
                          //   controller: _mobileNumberController,
                          // ),
                          // const SizedBox(height: 10.0),
                        ],
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      appButton(
                        text: txtSave,
                        width: 100.w,
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          if (_formKey.currentState!.validate()) {
                            _provider.setLoaderState(true);

                            // int check =
                            //     await _provider.checkEmailAndMobileExist(
                            //         email: _emailIdController.text,
                            //         mobile: _mobileNumberController.text);
                            // if (check == 1) {
                            //   _provider.setLoaderState(false);
                            //   Fluttertoast.showToast(
                            //       msg: 'email address already exists');
                            // } else if (check == 2) {
                            //   _provider.setLoaderState(false);
                            //   Fluttertoast.showToast(
                            //       msg: 'mobile no already exists');
                            // } else {

                            Restaurant newProfile = Restaurant(
                                restaurantName:
                                    _restaurantNameController.text.toString(),
                                restaurantImage: widget.profile.restaurantImage,
                                restaurantManagerName:
                                    widget.profile.restaurantManagerName,
                                loginType: widget.profile.loginType,
                                restaurantEmail:
                                    _emailIdController.text.toString(),
                                // profileImageUrl: widget.profile.profileImageUrl,
                                restaurantLat: widget.profile.restaurantLat,
                                restaurantLng: widget.profile.restaurantLng,
                                restaurantPhoneNumber:
                                    widget.profile.restaurantPhoneNumber,
                                restaurantAddress:
                                    widget.profile.restaurantAddress,
                                restaurantCity: widget.profile.restaurantCity,
                                restaurantState: widget.profile.restaurantState,
                                addedOn: widget.profile.addedOn,
                                subscriptionStart:
                                    widget.profile.subscriptionStart,
                                restaurantOpen: restaurantModel!.restaurantOpen,
                                subscriptionEnd:
                                    restaurantModel!.subscriptionEnd,
                                subscriptionActive:
                                    restaurantModel!.subscriptionActive,
                                restaurantIsActive:
                                    restaurantModel!.restaurantIsActive,
                                zipcode: widget.profile.zipcode,
                                deviceToken: widget.profile.deviceToken,
                                restaurantId: widget.profile.restaurantId);
                            await ProfileService().updateUser(newProfile);
                            await NotificationServices().profileUpdate(
                                RestaurantId: widget.profile.restaurantId!);
                            Provider.of<RestaurantProvider>(context,
                                    listen: false)
                                .setUser(currentUser: newProfile);
                            _provider.setLoaderState(false);
                            Fluttertoast.showToast(
                                msg: txtYourDetailsSavedSuccessfully);
                            Navigator.pop(context);
                            Navigator.pop(context);
                            // }
                          } else {
                            Fluttertoast.showToast(
                                msg: txtPleaseEnterAllDetails);
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Provider.of<AuthServices>(context).isLoading
            ? LoaderLayoutWidget()
            : SizedBox.shrink(),
      ],
    );
  }
}
