import 'package:checkbox_grouped/checkbox_grouped.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:midika/common/app_button.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/common/loader.dart';
import 'package:midika/models/operational_hours_model.dart';
import 'package:midika/provider/operational_hours_provider.dart';
import 'package:midika/services/profile_services.dart';
import 'package:midika/utils/colors.dart';
import 'package:midika/utils/strings.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class EditCafe extends StatefulWidget {
  const EditCafe({Key? key}) : super(key: key);

  @override
  _EditCafeState createState() => _EditCafeState();
}

class _EditCafeState extends State<EditCafe> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  bool showTimeSelection = false;

  TimeOfDay? selectedOpenTime;
  TimeOfDay? selectedCloseTime;
  int selectedOption = 0;
  bool isLoading = false;

  TextEditingController openingTimeController = TextEditingController();
  TextEditingController closingTimeController = TextEditingController();

  GroupController controller = GroupController();

  // final selectedItems = controller.selectedItem;
  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SizedBox(
                height: 80.h,
                child: StreamBuilder<QuerySnapshot>(
                  stream: ProfileService().fetchOperationalHours(
                      restaurantId: FirebaseAuth.instance.currentUser!.uid),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var docList = snapshot.data!.docs;

                      if (docList.isEmpty) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height - 56,
                          child:  Center(child: Text(txtNoDataAvailable)),
                        );
                      } else {
                        return SingleChildScrollView(
                          physics:  const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              ListView.builder(
                                physics:  NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: docList.length,
                                itemBuilder: (context, index) {
                                  Map<String, dynamic> data = docList[index]
                                      .data() as Map<String, dynamic>;

                                  OperationalHours hours =
                                      OperationalHours.fromJson(data);

                                  return operationalHourTile(
                                      operationalHours: hours);
                                },
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                            ],
                          ),
                        );
                      }
                    } else {
                      return const Center(
                        child: Loader(),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;

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
      title: appText(
        operationalHours.day!,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: appText(
        operationalHours.isClose == false
            ? (operationalHours.isOpen24 == true
                ? txtOpen24Hours
                : '${operationalHours.openingTime} - ${operationalHours.closingTime}')
            : txtClosed,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
      ),
      trailing: GestureDetector(
        onTap: () {
          showHoursBottomSheet(operationalHours: operationalHours);
        },
        child: Container(
          height: 28,
          width: 65,
          decoration: BoxDecoration(
              color:  Color(0xffF55800),
              borderRadius: BorderRadius.circular(20)),
          child: Center(
              child: appText(
            txtChange,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white),
          )),
        ),
      ),
    );
  }

  TimeOfDay stringToTimeOfDay(String tod) {
    final format = DateFormat('hh:mm:a'); //"6:00 AM"
    return TimeOfDay.fromDateTime(format.parseLoose(tod));
  }

  // String getAMandPM(String tod) {
  //   return DateFormat.jm().format(DateFormat("hh:mm").parse(tod));
  // }

  showHoursBottomSheet({required OperationalHours operationalHours}) {
    setState(() {
      controller = GroupController(
        initSelectedItem: [
          operationalHours.isOpen24
              ? 0
              : operationalHours.isClose
                  ? 1
                  : 2,
        ],
      );
      operationalHours.isOpen24 || operationalHours.isClose
          ? showTimeSelection = false
          : showTimeSelection = true;

      selectedOption = operationalHours.isOpen24
          ? 0
          : operationalHours.isClose
              ? 1
              : 2;
      if (showTimeSelection) {
        openingTimeController.text = operationalHours.openingTime!;
        closingTimeController.text = operationalHours.closingTime!;

        selectedOpenTime = stringToTimeOfDay(operationalHours.openingTime!);
        selectedCloseTime = stringToTimeOfDay(operationalHours.closingTime!);
      }
    });
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
                height: MediaQuery.of(context).size.height / 1.2,
                width: double.infinity,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    appText(
                      txtOperationalHours,
                      fontWeight: FontWeight.w700,
                      fontSize: 20.sp,
                    ),
                    const SizedBox(height: 20),
                    SimpleGroupedCheckbox<int>(
                      groupTitleAlignment: Alignment.centerLeft,
                      groupStyle: GroupStyle(activeColor: appPrimaryColor),
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
                      values: const [
                        0,
                        1,
                        2,
                      ],
                      checkFirstElement: false,
                    ),
                    const SizedBox(height: 10),
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
                                        TimeOfDay? time;

                                        TimeOfDay _initialTime =
                                            operationalHours.openingTime ==
                                                        null ||
                                                    operationalHours
                                                            .openingTime ==
                                                        ""
                                                ? const TimeOfDay(
                                                    hour: 8, minute: 0)
                                                : stringToTimeOfDay(
                                                    operationalHours
                                                        .openingTime!);

                                        time = _initialTime;

                                        time = await showTimePicker(
                                          context: context,
                                          initialTime: _initialTime,
                                        );
                                        if (time != null) {
                                          MaterialLocalizations localizations =
                                              MaterialLocalizations.of(context);
                                          setState(
                                            () {
                                              selectedOpenTime = time;

                                              openingTimeController.text =
                                                  localizations.formatTimeOfDay(
                                                      time!,
                                                      alwaysUse24HourFormat:
                                                          false);
                                            },
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 5),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: appPrimaryColor,
                                        ),
                                        child:  appText(
                                          txtPickOpeningTime,
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            TimeOfDay? time;

                                            TimeOfDay _initialTime =
                                                operationalHours.closingTime ==
                                                            null ||
                                                        operationalHours
                                                                .closingTime ==
                                                            ""
                                                    ? const TimeOfDay(
                                                        hour: 8, minute: 0)
                                                    : stringToTimeOfDay(
                                                        operationalHours
                                                            .closingTime!);
                                            time = _initialTime;

                                            time = await showTimePicker(
                                              context: context,
                                              initialTime: _initialTime,
                                            );
                                            if (time != null) {
                                              MaterialLocalizations
                                                  localizations =
                                                  MaterialLocalizations.of(
                                                      context);
                                              setState(() {
                                                selectedCloseTime = time;
                                                closingTimeController.text =
                                                    localizations.formatTimeOfDay(
                                                        time!,
                                                        alwaysUse24HourFormat:
                                                            false);
                                              });
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 5),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: appPrimaryColor,
                                            ),
                                            child:  appText(
                                              txtPickClosingTime,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        TimeOfDay? time;
                                        TimeOfDay _initialTime =
                                            operationalHours.openingTime ==
                                                        null ||
                                                    operationalHours
                                                            .openingTime ==
                                                        ""
                                                ? const TimeOfDay(
                                                    hour: 8, minute: 0)
                                                : stringToTimeOfDay(
                                                    operationalHours
                                                        .openingTime!);

                                        // setState(() => time = _initialTime);
                                        time = _initialTime;
                                        time = await showTimePicker(
                                          context: context,
                                          initialTime: _initialTime,
                                        );
                                        if (time != null) {
                                          MaterialLocalizations localizations =
                                              MaterialLocalizations.of(context);
                                          setState(() {
                                            selectedOpenTime = time;
                                            openingTimeController.text =
                                                localizations.formatTimeOfDay(
                                                    time!,
                                                    alwaysUse24HourFormat:
                                                        false);
                                          });
                                        }
                                      },
                                      child: SizedBox(
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
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () async {
                                        TimeOfDay? time;
                                        TimeOfDay _initialTime =
                                            operationalHours.closingTime ==
                                                        null ||
                                                    operationalHours
                                                            .closingTime ==
                                                        ""
                                                ? const TimeOfDay(
                                                    hour: 8, minute: 0)
                                                : stringToTimeOfDay(
                                                    operationalHours
                                                        .closingTime!);
                                        time = _initialTime;
                                        time = await showTimePicker(
                                          context: context,
                                          initialTime: _initialTime,
                                        );

                                        if (time != null) {
                                          print('time : $time');
                                          MaterialLocalizations localizations =
                                              MaterialLocalizations.of(context);
                                          setState(() {
                                            selectedCloseTime = time;
                                            closingTimeController.text =
                                                localizations.formatTimeOfDay(
                                                    time!,
                                                    alwaysUse24HourFormat:
                                                        false);
                                          });
                                        }
                                      },
                                      child: SizedBox(
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
                    appButton(
                      text: txtSUBMIT,
                      width: 100.w,
                      onTap: () async {
                        print(selectedOption);
                        final now = DateTime.now();

                        switch (selectedOption) {
                          case 0:
                            operationalHours.isOpen24 = true;
                            operationalHours.isClose = false;
                            operationalHours.openingTime = "";
                            operationalHours.closingTime = "";

                            await Provider.of<OperationalHoursProvider>(context,
                                    listen: false)
                                .changeOperationalHours(
                                    context: context,
                                    operationalHours: operationalHours);
                            Navigator.pop(context);

                            break;
                          case 1:
                            operationalHours.isOpen24 = false;
                            operationalHours.isClose = true;
                            operationalHours.openingTime = "";
                            operationalHours.closingTime = "";
                            await Provider.of<OperationalHoursProvider>(context,
                                    listen: false)
                                .changeOperationalHours(
                                    context: context,
                                    operationalHours: operationalHours);
                            Navigator.pop(context);
                            break;
                          case 2:
                            operationalHours.isOpen24 = false;
                            operationalHours.isClose = false;

                            if (selectedOpenTime == null &&
                                    selectedCloseTime == null ||
                                selectedOpenTime == null ||
                                selectedCloseTime == null) {
                              Fluttertoast.showToast(
                                  msg: txtPleaseSelectTimeDuration);
                            } else {
                              operationalHours.openingTime =
                                  selectedOpenTime!.format(context);
                              operationalHours.closingTime =
                                  selectedCloseTime!.format(context);
                              TimeOfDay ot = stringToTimeOfDay(
                                  operationalHours.openingTime!);
                              TimeOfDay ct = stringToTimeOfDay(
                                  operationalHours.closingTime!);

                              if (toDouble(ct) <= toDouble(ot)) {
                                Fluttertoast.showToast(
                                    msg: txtPleaseSelectValidTimeDuration);
                                break;
                              } else {
                                // operationalHours.openingTime =
                                //     getAMandPM(operationalHours.openingTime!);
                                // operationalHours.closingTime =
                                //     getAMandPM(operationalHours.closingTime!);

                                await Provider.of<OperationalHoursProvider>(
                                        context,
                                        listen: false)
                                    .changeOperationalHours(
                                        context: context,
                                        operationalHours: operationalHours);
                                Navigator.pop(context);
                                break;
                              }
                            }
                        } //switch
                      },
                    ),
                    const SizedBox(height: 30),
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
