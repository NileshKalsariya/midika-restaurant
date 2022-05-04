import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:midika/Screens/home_screen/home_screen_widget.dart';
import 'package:midika/Screens/qr_screen/create_qr_code_screen.dart';
import 'package:midika/Screens/qr_screen/qr_sk.dart';
import 'package:midika/common/app_button.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/common/loader_layout.dart';
import 'package:midika/common/small_loader.dart';
import 'package:midika/models/qr_code_model.dart';
import 'package:midika/models/restaurant_model.dart';
import 'package:midika/provider/user_provider.dart';
import 'package:midika/services/auth_services.dart';
import 'package:midika/services/qr_code_services.dart';
import 'package:midika/utils/asset_paths.dart';
import 'package:midika/utils/colors.dart';
import 'package:midika/utils/strings.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class ManageQRCodeScreen extends StatefulWidget {
  const ManageQRCodeScreen({Key? key}) : super(key: key);

  @override
  _ManageQRCodeScreenState createState() => _ManageQRCodeScreenState();
}

class _ManageQRCodeScreenState extends State<ManageQRCodeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('4');
  }

  bool checkdeleteIcon = false;
  @override
  Widget build(BuildContext context) {
    Restaurant? restaurant =
        Provider.of<RestaurantProvider>(context, listen: false).GetRestaurant;
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: white,
            // leading: Icon(
            //   Icons.arrow_back_ios,
            //   color: black,
            // ),
            actions: [
              StreamBuilder(
                stream: QrCodeServices().FetchQrCode(context: context),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.docs.length > 0) {
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Delete Qr Codes !'),
                                  content: Text(
                                      'Are you sure you want to delete qr codes?'),
                                  actions: [
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors.red),
                                        onPressed: () async {
                                          await QrCodeServices()
                                              .deleteAllQrcode(
                                                  context: context);
                                          Navigator.pop(context);
                                        },
                                        child:
                                            appText('Ok', color: Colors.white)),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors.white),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: appText('Cancel',
                                            color: Colors.black)),
                                  ],
                                );
                              });
                        },
                        child: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      );
                    } else {
                      return SizedBox();
                    }
                  } else {
                    return SizedBox();
                  }
                },
              ),
              SizedBox(
                width: 20,
              ),
            ],
            title: appText(txtManageQRCode,
                fontWeight: FontWeight.w500, fontSize: 14.sp),
            elevation: 1,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 1.5,
                  // color: Colors.red,
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.all(0),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: QrCodeServices().FetchQrCode(context: context),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasData) {
                          var docList = snapshot.data!.docs;

                          if (docList.length == 0) {
                            return Center(
                              child: Container(
                                height: MediaQuery.of(context).size.height / 2,
                                child: Center(child: appText(txtNoItems)),
                              ),
                            );
                          } else {
                            return ListView.builder(
                              scrollDirection: Axis.vertical,
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.all(0),
                              //reverse: true,
                              itemCount: docList.length,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, index) {
                                Map<String, dynamic> data = docList[index]
                                    .data() as Map<String, dynamic>;
                                QrCodeModel item = QrCodeModel.fromJson(data);

                                return qrCodeRowWidget(item.qrCodeUrl!,
                                    item.tableNo!, context, item, restaurant);
                              },
                            );
                          }
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: appPrimaryColor,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                appButton(
                  width: double.infinity,
                  onTap: () {
                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (context) {
                    //   return CreateQRCodeScreen();
                    // }));
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const QrNewScreen();
                    }));
                  },
                  isOnlyBorder: false,
                  color: white,
                  text: txtCreateQRCode,
                ),
                // SizedBox(height: 5.h),
                // appButton(
                //     color: Colors.red,
                //     onTap: () {
                //       Restaurant? restaurant = Provider.of<RestaurantProvider>(
                //               context,
                //               listen: false)
                //           .GetRestaurant;
                //       FirebaseFirestore.instance
                //           .collection(FirebaseReferences.qr_code_collection)
                //           .where('restaurant_id',
                //               isEqualTo: restaurant!.restaurantId!)
                //           .get()
                //           .then((value) {
                //         print('value :: ${value.size}');
                //         for (int i = 0; i < value.size; i++) {
                //           FirebaseFirestore.instance
                //               .collection(FirebaseReferences.qr_code_collection)
                //               .doc(value.docs[i].id)
                //               .delete();
                //           log('-----${value.docs[i].id}------deleted');
                //         }
                //       });
                //     },
                //     text: 'delete all qr')
              ],
            ),
          ),
        ),
        Provider.of<AuthServices>(context, listen: true).isLoading
            ? LoaderLayoutWidget()
            : Container(),
      ],
    );
  }
}

Widget qrCodeRowWidget(String image_url, int table_no, context, QrCodeModel qr,
    Restaurant? restaurant) {
  return Column(
    children: [
      GestureDetector(
        onTap: () {
          showBottomSheet(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            context: context,
            builder: (context) => GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              appText(txtTableNo + table_no.toString()),
                              const SizedBox(height: 5),
                              appText(Provider.of<RestaurantProvider>(context,
                                          listen: false)
                                      .restaurantModel
                                      .restaurantName ??
                                  '')
                            ],
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                child: appIcon(path: iconEditOrange),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return CreateQRCodeScreen(
                                            qr_model: qr, edit_mode: true);
                                      },
                                    ),
                                  );
                                },
                              ),
                              SizedBox(width: 20),
                              GestureDetector(
                                child: appIcon(
                                    path: iconTrash, color: Colors.black),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    useRootNavigator: false,
                                    builder: (_) {
                                      return AlertDialog(
                                        titlePadding: EdgeInsets.zero,
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            appText(
                                                '$txtAreYouSureYouWantToDeleteTableNo $table_no ?'),
                                            SizedBox(height: 30),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: appButton(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                      },
                                                      text: txtCancel,
                                                      isOnlyBorder: true,
                                                      borderColor:
                                                          appPrimaryColor,
                                                      color: Colors.white),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Expanded(
                                                  child: appButton(
                                                      color:
                                                          Colors.red.shade400,
                                                      onTap: () async {
                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
                                                        final provider = Provider
                                                            .of<AuthServices>(
                                                                context,
                                                                listen: false);
                                                        provider.setLoaderState(
                                                            true);
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'qr_codes')
                                                            .doc(qr.qrCodeId)
                                                            .delete();
                                                        provider.setLoaderState(
                                                            false);
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                txtQrCodeDeletedSuccessfully);
                                                      },
                                                      text: txtDelete),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height / 3,
                      child: new Container(
                        child: Center(
                          child: Container(
                            height: 150,
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) =>
                                      SmallLoader(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              imageUrl: image_url.toString(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  appText(
                    '$txtTableNo $table_no',
                    fontSize: 11.sp,
                  ),
                  appText(
                    restaurant!.restaurantName ??= '',
                    fontSize: 10.sp,
                    color: black400,
                  ),
                ],
              ),
              CachedNetworkImage(
                fit: BoxFit.cover,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    SmallLoader(),
                errorWidget: (context, url, error) => Icon(Icons.error),
                imageUrl: image_url.toString(),
                width: 48,
                height: 48,
              ),
            ],
          ),
        ),
      ),
      SizedBox(height: 10),
    ],
  );
}
