import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:midika/common/app_button.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/models/order_model.dart';
import 'package:midika/models/user_model.dart';
import 'package:midika/services/order_service.dart';
import 'package:midika/utils/asset_paths.dart';
import 'package:midika/utils/colors.dart';
import 'package:midika/utils/date_functions.dart';
import 'package:midika/utils/strings.dart';
import 'package:sizer/sizer.dart';

class OpenOrderScreen extends StatefulWidget {
  const OpenOrderScreen({Key? key}) : super(key: key);

  @override
  _OpenOrderScreenState createState() => _OpenOrderScreenState();
}

class _OpenOrderScreenState extends State<OpenOrderScreen> {
  bool accept_loader = false;
  bool cancel_order = false;
  bool deliver_order = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: OrderService().getAcceptedOrder(context: context),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: Container(
                          height: MediaQuery.of(context).size.height / 2,
                          child: Center(child: appText(txtNoOrdersYet)),
                        ),
                      );
                    } else {
                      if (snapshot.data!.docs.isNotEmpty) {
                        return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> data =
                                  snapshot.data!.docs[index].data()
                                      as Map<String, dynamic>;

                              Order currentOrder = Order.fromJson(data);
                              UserModel? currentUser;
                              return ItemCard(
                                orderModel: currentOrder,
                              );
                            });
                      } else {
                        return Center(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height / 2,
                            child: Center(
                              child: appText(txtNoOrdersYet),
                            ),
                          ),
                        );
                      }
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget ItemCard({required Order orderModel}) {
    String dateTime = DateFunctions.getFormattedDate(orderModel.addedOn!);

    return ExpandableNotifier(
      // <-- Provides ExpandableController to its children
      child: Column(
        children: [
          Expandable(
            // <-- Driven by ExpandableController from ExpandableNotifier
            collapsed: ExpandableButton(
              // <-- Expands when tapped on the cover photo
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      // color: Colors.black12,
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
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: appText(
                                          '#${orderModel.orderId.toString()}'),
                                    ),
                                    SizedBox(
                                      height: 2.h,
                                    ),
                                    FutureBuilder(
                                      future: OrderService.getUserById(
                                          userId: orderModel.userId!),
                                      builder: (context,
                                          AsyncSnapshot<UserModel> snapshot) {
                                        if (snapshot.hasData &&
                                            snapshot.data != '') {
                                          return Container(
                                            child: appText(
                                                snapshot.data!.userName
                                                    .toString(),
                                                color: orangeClr,
                                                fontWeight: FontWeight.w500),
                                          );
                                        } else {
                                          return Container(
                                            child: appText(txtLoading,
                                                color: orangeClr,
                                                fontWeight: FontWeight.w500),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                Container(
                                  child: appText(dateTime.toString(),
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          thickness: 1.5,
                        ),
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    StreamBuilder(
                                      stream: OrderService.getItemCount(
                                          orderId:
                                              orderModel.orderId.toString()),
                                      builder: (context,
                                          AsyncSnapshot<QuerySnapshot>
                                              snapshot) {
                                        if (snapshot.hasData) {
                                          return appText('$txtItems-' +
                                              snapshot.data!.docs.length
                                                  .toString());
                                        } else {
                                          return appText(txtLoading);
                                        }
                                      },
                                    ),
                                    appText('\$${orderModel.grandTotal}',
                                        fontSize: 14.sp, color: orangeClr)
                                  ],
                                ),
                                SizedBox(
                                  height: 1.sp,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Spacer(),
                                    appText(txtPayWithCard,
                                        fontSize: 11.sp, color: black400),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.sp,
                  ),
                ],
              ),
            ),
            expanded: Column(
              children: [
                ExpandableButton(
                  // <-- Collapses when tapped on
                  child: MainInvoiceCard(
                      ordermodel: orderModel, dateTime: dateTime),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget MainInvoiceCard(
      {required Order ordermodel, required String dateTime}) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: appText('#${ordermodel.orderId}'),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    FutureBuilder(
                      future:
                          OrderService.getUserById(userId: ordermodel.userId!),
                      builder: (context, AsyncSnapshot<UserModel> snapshot) {
                        if (snapshot.hasData && snapshot.data != '') {
                          return Container(
                            child: appText(snapshot.data!.userName.toString(),
                                color: orangeClr, fontWeight: FontWeight.w500),
                          );
                        } else {
                          return Container(
                            child: appText(txtLoading,
                                color: orangeClr, fontWeight: FontWeight.w500),
                          );
                        }
                      },
                    ),
                  ],
                ),
                Container(
                  child: appText('${dateTime.toString()}', fontSize: 13),
                ),
              ],
            ),
          ),
          Divider(thickness: 1.5),
          SizedBox(
            height: 2.h,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder(
                  stream: OrderService.getItemCount(
                      orderId: ordermodel.orderId.toString()),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      return appText(
                          '$txtItems-' + snapshot.data!.docs.length.toString(),
                          fontSize: 14.sp);
                    } else {
                      return appText(txtLoading);
                    }
                  },
                ),
                SizedBox(
                  height: 2.h,
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: OrderService()
                      .getIems(orderId: ordermodel.orderId.toString()),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      var length = snapshot.data!.docs.length;
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> docData =
                              snapshot.data!.docs[index].data()
                                  as Map<String, dynamic>;

                          List data = List.from(docData['modifier']);

                          List<String>? final_modifiers = [];
                          data.forEach(
                            (element) {
                              if (element.split(' - ').last.isNotEmpty) {
                                String dataElement = '';
                                dataElement = element.toString();
                                if (dataElement != null &&
                                    dataElement.length > 0) {
                                  final_modifiers.add(dataElement.substring(
                                      0, dataElement.length - 1));
                                }
                              }
                            },
                          );

                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  appText(
                                    '${docData['item_quantity'] ?? ''} X ${docData['item_name'] ?? ''}',
                                    fontSize: 11.sp,
                                  ),
                                  appText('\$${docData['item_price']}',
                                      color: black400,
                                      fontWeight: FontWeight.w500),
                                ],
                              ),
                              ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: final_modifiers.length,
                                  itemBuilder: (context, modifierIndex) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 3),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          child: appText(
                                              "  • ${final_modifiers[modifierIndex].toString()}",
                                              fontSize: 13),
                                        ),
                                      ),
                                    );
                                  }),
                              SizedBox(
                                height: 1.h,
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      return Center(
                        child: appText(txtLoading),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          // Divider(
          //   thickness: 1.5,
          // ),
          // SizedBox(
          //   height: 2.h,
          // ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       appText('Order Instruction', fontSize: 14.sp),
          //       SizedBox(
          //         height: 1.h,
          //       ),
          //       appText(
          //           'Send extra sugar saches with order and avoid choclate syrup',
          //           fontSize: 10.sp,
          //           color: black400)
          //     ],
          //   ),
          // ),
          // SizedBox(
          //   height: 2.h,
          // ),
          Divider(
            thickness: 1.5,
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                appText('Notes:', fontSize: 14.sp),
                SizedBox(
                  height: 5,
                ),
                appText(
                    ordermodel.orderNotes ?? 'No notes written for this order'),
              ],
            ),
          ),

          Divider(
            thickness: 1.5,
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                appText('Table no:', fontSize: 14.sp),
                SizedBox(
                  height: 5,
                ),
                appText(ordermodel.table_number ??
                    'No table written for this order'),
              ],
            ),
          ),
          SizedBox(
            height: 2.h,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    appText('\$${ordermodel.salesTax.toString()}',
                        fontSize: 11.sp),
                    SizedBox(
                      height: 1.h,
                    ),
                    appText('\$${ordermodel.grandTotal}',
                        fontSize: 14.sp, color: orangeClr)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    appText(txtTax, fontSize: 11.sp),
                    SizedBox(
                      height: 1.h,
                    ),
                    appText(txtPayWithCard, fontSize: 11.sp, color: black400),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: ordermodel.orderStatus == null
                ? Row(
                    children: [
                      Expanded(
                          child: appButton(
                              onTap: () async {
                                setState(() {
                                  cancel_order = true;
                                });

                                var status = await OrderService()
                                    .changeOrderStatusToCancel(
                                        orderModel: ordermodel);
                                if (status == 1) {
                                  setState(() {
                                    cancel_order = false;
                                  });
                                }
                              },
                              text: cancel_order ? txtLoading : txtCancel,
                              color: orangeClr)),
                      SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: appButton(
                            onTap: () async {
                              showDialog(
                                context: context,
                                useRootNavigator: false,
                                builder: (_) {
                                  return AlertDialog(
                                    titlePadding: EdgeInsets.zero,
                                    title: Image.asset(
                                      foodModifier,
                                      height: 100,
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        appText(
                                            txtAreYouSureYouWantToAcceptOrder),
                                        SizedBox(
                                          height: 30,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: appButton(
                                                  color: Colors.red.shade400,
                                                  onTap: () async {
                                                    Navigator.pop(context);
                                                    setState(() {
                                                      accept_loader = true;
                                                    });

                                                    var status =
                                                        await OrderService()
                                                            .changeOrderStatusToAccept(
                                                                orderModel:
                                                                    ordermodel,
                                                                context:
                                                                    context);
                                                    if (status == 1) {
                                                      setState(() {
                                                        accept_loader = false;
                                                      });
                                                    }

                                                    Fluttertoast.showToast(
                                                        msg: txtOrderAccepted);
                                                  },
                                                  text: txtYesAccept),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            text: accept_loader ? txtLoading : txtAccept),
                      ),
                    ],
                  )
                : ordermodel.orderStatus == 1
                    ? appButton(
                        onTap: () {
                          showDialog(
                            context: context,
                            useRootNavigator: false,
                            builder: (_) {
                              return AlertDialog(
                                titlePadding: EdgeInsets.zero,
                                title: Image.asset(
                                  iconOffer,
                                  height: 60,
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    appText(
                                        txtAreYouSureYouWantToDeliverThisOrder),
                                    SizedBox(height: 30),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: appButton(
                                              color: Colors.green,
                                              onTap: () async {
                                                Navigator.pop(context);
                                                setState(() {
                                                  deliver_order = true;
                                                });

                                                var status = await OrderService()
                                                    .changeOrderStatusToDeliver(
                                                        orderModel: ordermodel,
                                                        context: context);
                                                if (status == 1) {
                                                  setState(() {
                                                    deliver_order = false;
                                                  });
                                                }

                                                Fluttertoast.showToast(
                                                    msg:
                                                        txtOrderDeliveredSuccessfully);
                                              },
                                              text: txtYesDeliver),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        text: deliver_order ? txtLoading : txtDeliver,
                        width: double.infinity)
                    : ordermodel.orderStatus == 0
                        ? appButton(
                            onTap: () {},
                            text: txtCancelled,
                            color: Colors.grey.shade500,
                            width: double.infinity)
                        : Container(),
          )
        ],
      ),
    );
  }
}
