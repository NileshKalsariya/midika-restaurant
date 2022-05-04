import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:midika/Internationalization/shar_pref.dart';
import 'package:midika/Screens/add_new_item_screen/add_new_item_screen.dart';
import 'package:midika/common/app_button.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/models/item_model.dart';
import 'package:midika/services/item_services.dart';
import 'package:midika/utils/asset_paths.dart';
import 'package:midika/utils/colors.dart';
import 'package:midika/utils/strings.dart';
import 'package:sizer/sizer.dart';

class ItemList extends StatefulWidget {
  const ItemList({Key? key}) : super(key: key);

  @override
  _ItemListState createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  List<String> choices = ["Add New Item", "Add New Modifier"];
  String? uid;
  // List<String> choices = ["Add New Item"];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('hello 1');
    getUid();
  }

  getUid() async {
    uid = await Shared_Preferences.prefGetUID();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: const Icon(
        //   Icons.arrow_back_ios,
        //   color: black,
        // ),

        title: appText(txtItems, fontWeight: FontWeight.w500, fontSize: 13.sp),
        backgroundColor: Colors.white,
        // actions: [
        //   GestureDetector(
        //     child: Image.asset(iconAdd),
        //     onTap: () {
        //       Navigator.push(context, MaterialPageRoute(builder: (context) {
        //         return AddItemScreen();
        //       }));
        //     },
        //   ),
        // ],
        actions: [
          // PopupMenuButton<int>(
          //   padding: EdgeInsets.zero,
          //   elevation: 3,
          //   shape:
          //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          //   child:
          GestureDetector(
              child: Image.asset(icon_add),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return AddItemScreen();
                }));
              }),

          SizedBox(
            width: 10,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, top: 20, bottom: 30),
        child: Container(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(0),
            child: StreamBuilder<QuerySnapshot>(
                stream: ItemServices().FetchItem(context: context, uid: uid),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    var docList = snapshot.data!.docs;

                    if (docList.length == 0) {
                      return Center(
                        child: Container(
                          height: MediaQuery.of(context).size.height / 2,
                          child: Center(child: Text(txtNoItems)),
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
                          Map<String, dynamic> data =
                              docList[index].data() as Map<String, dynamic>;
                          Item item = Item.fromJson(data);
                          return ItemEditCard(
                              itemImage: item.itemImage,
                              ItemName: item.itemName,
                              ItemDesc: item.itemDescription,
                              ItemPrice: item.itemPrice,
                              item: item);
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
                }),
          ),
        ),
      ),
    );
  }

  Widget ItemEditCard({
    String? itemImage,
    String? ItemName,
    double? ItemPrice,
    String? ItemDesc,
    required Item item,
  }) {
    return Stack(
      overflow: Overflow.visible,
      children: [
        Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 1.15,
              margin: EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(.5),
                    offset: const Offset(
                      0.5,
                      0.2,
                    ),
                    blurRadius: 2.0,
                    // spreadRadius: 1.0,
                  ), //BoxShadow
                  BoxShadow(
                    color: Colors.white,
                    offset: const Offset(0.0, 0.0),
                    blurRadius: 0.0,
                    spreadRadius: 0.0,
                  ), //BoxShadow
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    ClipOval(
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) =>
                                CircularProgressIndicator(
                          value: downloadProgress.progress,
                          color: appPrimaryColor,
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        imageUrl: itemImage.toString(),
                        width: 70.0,
                        height: 70.0,
                      ),
                    ),
                    SizedBox(
                      width: 2.h,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 2.5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          appText(
                            ItemName.toString(),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            isTextOverflow: true,
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                          appText(
                            ItemDesc.toString(),
                            fontSize: 10.sp,
                            color: blackgrey,
                            maxLines: 1,
                            isTextOverflow: true,
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                          appText('\$' + ItemPrice.toString(), fontSize: 14.sp),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
          ],
        ),
        Positioned(
          right: MediaQuery.of(context).size.width / 50,
          top: MediaQuery.of(context).size.height / 28,
          child: Container(
            height: MediaQuery.of(context).size.height / 22,
            width: MediaQuery.of(context).size.width / 4,
            child: appButton(
                onTap: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return AddItemScreen(item: item);
                          },
                        ),
                      )
                    },
                text: txtEdit,
                width: MediaQuery.of(context).size.width / 4.2),
          ),
        ),
      ],
    );
  }
}
