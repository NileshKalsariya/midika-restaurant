import 'package:checkbox_grouped/checkbox_grouped.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/models/operational_hours_model.dart';
import 'package:midika/utils/colors.dart';
import 'package:midika/utils/strings.dart';
import 'package:sizer/sizer.dart';

class OperationalHoursScreen extends StatefulWidget {
  final bool skipButton;

  OperationalHoursScreen({required this.skipButton});

  @override
  _OperationalHoursScreen createState() => _OperationalHoursScreen();
}

class _OperationalHoursScreen extends State<OperationalHoursScreen> {
  bool showTimeSelection = false;

  // RestaurantSetupServices _restaurantSetupServices = RestaurantSetupServices();
  TimeOfDay? selectedOpenTime;
  TimeOfDay? selectedCloseTime;
  int selectedOption = 0;
  bool isLoading = false;

  // Restaurant? restaurant;

  TextEditingController openingTimeController = TextEditingController();
  TextEditingController closingTimeController = TextEditingController();

  GroupController controller = GroupController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    // restaurant =
    //     Provider.of<RestaurantProvider>(context, listen: false).getRestaurant;

    return Scaffold(
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
        title:
            appText(txtEditCafe, fontWeight: FontWeight.w500, fontSize: 13.sp),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Container(
            height: size.height,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Expanded(
                //     child: StreamBuilder<QuerySnapshot>(
                //         stream: _restaurantSetupServices.fetchOperationalHours(
                //             restaurantId: restaurant!.restaurantId!),
                //         builder: (context, snapshot) {
                //           if (snapshot.hasData) {
                //             var docList = snapshot.data!.docs;
                //
                //             if (docList.length == 0) {
                //               return Container(
                //                 height: MediaQuery.of(context).size.height - 56,
                //                 child: Center(child: Text("No Data Available")),
                //               );
                //             } else {
                //               return ListView.builder(
                //                   itemCount: docList.length,
                //                   itemBuilder: (context, index) {
                //                     Map<String, dynamic> data = docList[index]
                //                         .data() as Map<String, dynamic>;
                //                     OperationalHours hours =
                //                         OperationalHours.fromJson(data);
                //                     return operationalHourTile(
                //                         operationalHours: hours);
                //                   });
                //             }
                //           } else {
                //             return Center(
                //               child: Loader(),
                //             );
                //           }
                //         })),
                SizedBox(
                  height: 16,
                ),
                widget.skipButton
                    ? appText(
                        txtYouCanSkipThisForLater,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey),
                      )
                    : Container(),
                widget.skipButton
                    ? SizedBox(
                        height: 16,
                      )
                    : Container(),
                widget.skipButton
                    ? InkWell(
                        onTap: () {
                          // Navigator.pushAndRemoveUntil(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => ScreenContainer()),
                          //     (Route<dynamic> route) => false);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Container(
                                height: 45,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(30)),
                                child: Center(
                                    child: Text(
                                  txtSkip,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )),
                              )),
                            ],
                          ),
                        ),
                      )
                    : Container(),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  TimeOfDay stringToTimeOfDay(String tod) {
    final format = DateFormat("hh:mm a"); //"6:00 AM"
    return TimeOfDay.fromDateTime(format.parse(tod));
  }

  Widget operationalHourTile({required OperationalHours operationalHours}) {
    return ListTile(
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: operationalHours.isClose
            ? Colors.red.withOpacity(0.15)
            : (operationalHours.isOpen24
                ? Colors.blue.withOpacity(0.15)
                : Theme.of(context).primaryColor.withOpacity(0.15)),
        child: Icon(
          Icons.calendar_today_outlined,
          color: operationalHours.isClose
              ? Colors.red
              : (operationalHours.isOpen24
                  ? Colors.blue
                  : Theme.of(context).primaryColor),
          size: 20,
        ),
      ),
      title: Text(
        operationalHours.day!,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        operationalHours.isClose == false
            ? (operationalHours.isOpen24 == true
                ? txtOpen24Hours
                : '${operationalHours.openingTime} - ${operationalHours.closingTime}')
            : txtClosed,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
      ),
      trailing: GestureDetector(
        onTap: () {
          showHoursBottomSheet(operationalHours: operationalHours);
        },
        child: Container(
          height: 28,
          width: 65,
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(20)),
          child: const Center(
              child: Text(
            txtChange,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white),
          )),
        ),
      ),
    );
  }

  double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;

  showHoursBottomSheet({required OperationalHours operationalHours}) {
    return showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                height: MediaQuery.of(context).size.height / 1.5,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 20
                    ),
                    appText(
                      txtOperationalHours,
                      style: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 20),
                    SimpleGroupedCheckbox<int>(
                      groupTitleAlignment: Alignment.centerLeft,
                      onItemSelected: (value) {
                        setState(() {
                          selectedOption = value;
                          value == 2
                              ? showTimeSelection = true
                              : showTimeSelection = false;
                        });
                        print(selectedOption);
                      },
                      controller: controller,
                      itemsTitle: const [
                        txtOpen24Hours,
                        txtClosed,
                        txtSelectCustomTime,
                      ],
                      values: [
                        0,
                        1,
                        2,
                      ],
                      checkFirstElement: false,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    showTimeSelection
                        ? Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                        onTap: () async {
                                          TimeOfDay? time =
                                              await showTimePicker(
                                                  context: context,
                                                  initialTime: TimeOfDay(
                                                      hour: 8, minute: 0));
                                          if (time != null) {
                                            MaterialLocalizations
                                                localizations =
                                                MaterialLocalizations.of(
                                                    context);
                                            setState(() {
                                              selectedOpenTime = time;
                                              openingTimeController.text =
                                                  localizations.formatTimeOfDay(
                                                      time,
                                                      alwaysUse24HourFormat:
                                                          false);
                                            });
                                          }
                                        },
                                        child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 5),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            child: appText(
                                              txtPickOpeningTime,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ))),
                                    Spacer(),
                                    Row(
                                      children: [
                                        GestureDetector(
                                            onTap: () async {
                                              TimeOfDay? time =
                                                  await showTimePicker(
                                                      context: context,
                                                      initialTime: TimeOfDay(
                                                          hour: 8, minute: 0));
                                              if (time != null) {
                                                MaterialLocalizations
                                                    localizations =
                                                    MaterialLocalizations.of(
                                                        context);
                                                setState(() {
                                                  selectedCloseTime = time;
                                                  closingTimeController.text =
                                                      localizations.formatTimeOfDay(
                                                          time,
                                                          alwaysUse24HourFormat:
                                                              false);
                                                });
                                              }
                                            },
                                            child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 5),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                                child: appText(
                                                  txtPickClosingTime,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ))),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        TimeOfDay? time = await showTimePicker(
                                            context: context,
                                            initialTime:
                                                TimeOfDay(hour: 8, minute: 0));
                                        if (time != null) {
                                          MaterialLocalizations localizations =
                                              MaterialLocalizations.of(context);
                                          setState(() {
                                            selectedOpenTime = time;
                                            openingTimeController.text =
                                                localizations.formatTimeOfDay(
                                                    time,
                                                    alwaysUse24HourFormat:
                                                        false);
                                          });
                                        }
                                      },
                                      child: Container(
                                        height: 30,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3,
                                        child: TextField(
                                          enabled: false,
                                          textAlign: TextAlign.center,
                                          controller: openingTimeController,
                                        ),
                                      ),
                                    ),
                                    Spacer(),
                                    GestureDetector(
                                      onTap: () async {
                                        TimeOfDay? time = await showTimePicker(
                                            context: context,
                                            initialTime:
                                                TimeOfDay(hour: 8, minute: 0));
                                        if (time != null) {
                                          MaterialLocalizations localizations =
                                              MaterialLocalizations.of(context);
                                          setState(() {
                                            selectedCloseTime = time;
                                            closingTimeController.text =
                                                localizations.formatTimeOfDay(
                                                    time,
                                                    alwaysUse24HourFormat:
                                                        false);
                                          });
                                        }
                                      },
                                      child: Container(
                                        height: 30,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3,
                                        child: TextField(
                                          enabled: false,
                                          textAlign: TextAlign.center,
                                          controller: closingTimeController,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    const SizedBox(height: 30),
                    InkWell(
                      onTap: () async {
                        print(selectedOption);
                        final now = DateTime.now();

                        switch (selectedOption) {
                          case 0:
                            operationalHours.isOpen24 = true;
                            operationalHours.isClose = false;
                            operationalHours.openingTime = "";
                            operationalHours.closingTime = "";
                            // await Provider.of<OperationalHoursProvider>(context,
                            //         listen: false)
                            //     .changeOperationalHours(
                            //         context: context,
                            //         operationalHours: operationalHours);
                            Navigator.pop(context);

                            // OperationalHours(
                            // day: day,
                            // addedOn: ,
                            // isOpen24: true,
                            // isClose: false,
                            // openingTime: "",
                            // closingTime: "");
                            break;
                          case 1:
                            operationalHours.isOpen24 = false;
                            operationalHours.isClose = true;
                            operationalHours.openingTime = "";
                            operationalHours.closingTime = "";
                            // await Provider.of<OperationalHoursProvider>(context,
                            //         listen: false)
                            //     .changeOperationalHours(
                            //         context: context,
                            //         operationalHours: operationalHours);
                            Navigator.pop(context);
                            break;
                          case 2:
                            operationalHours.isOpen24 = false;
                            operationalHours.isClose = false;
                            operationalHours.openingTime =
                                selectedOpenTime!.format(context);
                            operationalHours.closingTime =
                                selectedCloseTime!.format(context);
                            TimeOfDay ot = stringToTimeOfDay(
                                operationalHours.openingTime!);
                            TimeOfDay ct = stringToTimeOfDay(
                                operationalHours.closingTime!);
                            if (toDouble(ct) <= toDouble(ot)) {
                              // Functions.toast(
                              //     "Please select valid time duration!");
                              break;
                            } else {
                              // await Provider.of<OperationalHoursProvider>(
                              //         context,
                              //         listen: false)
                              //     .changeOperationalHours(
                              //         context: context,
                              //         operationalHours: operationalHours);
                              Navigator.pop(context);
                              break;
                            }
                        }
                      },
                      child: Row(
                        children: [
                          Expanded(
                              child: Container(
                            height: 40,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(30)),
                            child: Center(
                                child: appText(
                              txtSUBMIT,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        }).whenComplete(() {
      setState(() {
        selectedCloseTime = null;
        selectedOpenTime = null;
        openingTimeController.text = "";
        closingTimeController.text = "";
        showTimeSelection = false;
      });
    });
  }
}
