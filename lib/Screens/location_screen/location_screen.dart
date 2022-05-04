import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:midika/common/app_button.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/common/loader_layout.dart';
import 'package:midika/models/location_mode.dart';
import 'package:midika/provider/location_provider.dart';
import 'package:midika/utils/asset_paths.dart';
import 'package:midika/utils/strings.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class LocationScreen extends StatefulWidget {
  // final String mobileNumber, emailId, userName;
  // final bool isGoogle;

  const LocationScreen({
    Key? key,
    // required this.mobileNumber,
    // required this.emailId,
    // required this.userName,
    // required this.isGoogle,
  }) : super(key: key);

  @override
  LocationScreenState createState() => LocationScreenState();
}

class LocationScreenState extends State<LocationScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? newGoogleMapController;
  List<Marker> _marker = [];
  LocationModel currentLocation = LocationModel();

  String address = "";
  String state = '';
  String city = '';
  String lat = '';
  String long = '';
  String zipcode = '';
  LatLng finalLatLng = const LatLng(0, 0);

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('in service enabled start');
      Geolocator.openLocationSettings().then((value) {
        print('open location setting : $value');
      });
      await Geolocator.requestPermission().then((value) {
        print('request permission : $value');
      });
      Fluttertoast.showToast(msg: txtLocationServiceAreDisabled);
      return Future.error(txtLocationServiceAreDisabled);
      print('in service enabled end');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: txtLocationServiceAreDisabled);
        return Future.error(txtLocationServiceAreDisabled);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      Fluttertoast.showToast(msg: txtLocationServiceArePermanentlyDenied);

      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.whileInUse) {
      return await Geolocator.getCurrentPosition();
    }

    return await Geolocator.getCurrentPosition();
  }

  CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  _getLocation() {
    LatLng _latlng = LatLng(0, 0);

    _determinePosition().then((value) {
      print('latlng on get location : $value');
      _latlng = LatLng(value.latitude, value.longitude);
      CameraPosition cameraPosition = CameraPosition(
        target: LatLng(value.latitude, value.longitude),
        zoom: 14,
      );

      _getAddressFromLatLng(LatLng(value.latitude, value.longitude));
      setState(() {
        newGoogleMapController!
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      });
    }).whenComplete(() {
      print('lat long : $_latlng');
      Marker marker = Marker(
        markerId: MarkerId("test"),
        position: _latlng,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        ),
      );

      _marker.add(marker);
      setState(() {});
    });
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    print(position);
    List<Placemark> _placeMark =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    print(_placeMark);
    Placemark place = _placeMark[0];
    setState(() {
      finalLatLng = position;
      state = place.administrativeArea!.toString();
      city = place.subAdministrativeArea!.toString();
      address =
          "${place.street}, ${place.subLocality}, ${place.locality} (${place.postalCode}), ${place.country}.";
      zipcode = place.postalCode!.toString();
      lat = finalLatLng.latitude.toString();
      long = finalLatLng.longitude.toString();
    });
    // address =
    //     "${place.street}, ${place.subLocality}, ${place.locality} (${place.postalCode}), ${place.country}.";
  }

  @override
  void initState() {
    _getLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var provider_manage = Provider.of<LocationProvider>(context, listen: true);
    return Stack(
      children: [
        Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GoogleMap(
                    mapType: MapType.hybrid,
                    initialCameraPosition: _kGooglePlex,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                      newGoogleMapController = controller;
                      _getLocation();
                    },
                    myLocationButtonEnabled: true,
                    myLocationEnabled: true,
                    onTap: (LatLng latlng) {
                      Marker marker = Marker(
                        markerId: MarkerId("test"),
                        position: latlng,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed,
                        ),
                      );
                      _getAddressFromLatLng(
                        LatLng(latlng.latitude, latlng.longitude),
                      );
                      _marker.add(marker);
                      setState(() {});
                    },
                    markers: _marker.map((e) => e).toSet(),
                  ),
                ),
                Container(
                  height: 22.h,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              iconLocation,
                              height: 24.sp,
                              width: 24.sp,
                            ),
                            Expanded(
                              child: appText(
                                address,
                                maxLines: 3,
                                fontSize: 11.sp,
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 2.h),
                        appButton(
                          width: 100.w,
                          text: txtConfirmLocation,
                          onTap: () async {
                            //todo location and set data on database

                            print("marker length : ${_marker.length}");

                            if (_marker.isNotEmpty) {
                              final _provider = Provider.of<LocationProvider>(
                                  context,
                                  listen: false);
                              _provider.changeLoaderState(true);
                              LocationModel newLocation = LocationModel(
                                  state: state,
                                  city: city,
                                  address: address,
                                  lat: lat,
                                  long: long,
                                  zipCode: zipcode);
                              await _provider.setLocationModel(newLocation);
                              LocationModel locPro = _provider.getLocationModel;
                              print('=========================');
                              print(locPro.zipCode);
                              print(locPro.address);
                              print(locPro.long);
                              print(locPro.lat);
                              print(locPro.city);
                              print(locPro.state);
                              print('=========================');

                              _provider.changeLoaderState(false);
                              Fluttertoast.showToast(
                                  msg: txtLocationSelectedSuccessfully);
                              Navigator.pop(context, true);
                            } else {
                              Fluttertoast.showToast(
                                  msg: txtPleaseMarkLocation);
                            }
                            // if (_marker.isNotEmpty) {
                            //   UserModel _userProfile = UserModel();
                            //
                            //   _userProfile.uid =
                            //       FirebaseAuth.instance.currentUser!.uid;
                            //
                            //   if (widget.isGoogle == true) {
                            //     _userProfile.uid =
                            //         FirebaseAuth.instance.currentUser!.uid;
                            //     _userProfile.email =
                            //         FirebaseAuth.instance.currentUser!.email;
                            //     _userProfile.userName =
                            //         FirebaseAuth.instance.currentUser!.displayName;
                            //     _userProfile.mobileNumber =
                            //         FirebaseAuth.instance.currentUser!.phoneNumber;
                            //     _userProfile.profileImageUrl =
                            //         FirebaseAuth.instance.currentUser!.photoURL;
                            //   } else {
                            //     _userProfile.email = widget.emailId;
                            //     _userProfile.userName = widget.userName;
                            //     _userProfile.mobileNumber = widget.mobileNumber;
                            //     _userProfile.profileImageUrl =
                            //     'https://www.seekpng.com/png/detail/966-9665493_my-profile-icon-blank-profile-image-circle.png';
                            //   }

                            // _userProfile.address = address;
                            // _userProfile.latitude =
                            //     finalLatLng.latitude.toString();
                            // _userProfile.longitude =
                            //     finalLatLng.longitude.toString();
                            //
                            // ProfileService()
                            //     .setUser(_userProfile)
                            //     .whenComplete(() {
                            //   Functions.toast('register successfully');
                            //
                            //   final _provider = Provider.of<UiFlowManage>(context,
                            //       listen: false);
                            //   _provider.setIsLogin(true);

                            //     Navigator.pushAndRemoveUntil(
                            //       context,
                            //       MaterialPageRoute(
                            //           builder: (context) => const CheckLogin()),
                            //           (route) => false,
                            //     );
                            //   });
                            // }

                            // _getLocation();
                            // _determinePosition().then((value) {
                            //   print(
                            //       'location : ${value.latitude} and ${value.longitude}');
                            // });
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => BottomNavigationRootScreen(),
                            //   ),
                            //   // (_) => false,
                            // );

                            // Get.to(const BottomNavigationRootScreen());
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const HomeScreen(),
                            //   ),
                            // );
                          },
                        ),
                        SizedBox(height: 2.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        provider_manage.is_loading ? LoaderLayoutWidget() : SizedBox.shrink(),
      ],
    );
  }
}
