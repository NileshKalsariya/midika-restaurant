import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:midika/Screens/add_new_item_screen/modifier_list.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/common/app_text_form_field.dart';
import 'package:midika/models/modifer_model.dart';
import 'package:midika/services/item_services.dart';
import 'package:midika/utils/asset_paths.dart';
import 'package:midika/utils/colors.dart';
import 'package:midika/utils/strings.dart';
import 'package:sizer/sizer.dart';

class SelectGroupScreen extends StatefulWidget {
  String item_name;
  String item_id;

  SelectGroupScreen({Key? key, required this.item_name, required this.item_id})
      : super(key: key);

  @override
  _SelectGroupScreenState createState() => _SelectGroupScreenState();
}

class _SelectGroupScreenState extends State<SelectGroupScreen> {
  TextEditingController _itemNameController = TextEditingController();

  String? allergies;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _itemNameController.text = widget.item_name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        title: appText(txtSelectModifier,
            fontWeight: FontWeight.w500, fontSize: 14.sp),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: black,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ModifierList(item_id: widget.item_id);
              }));
            },
            child: Image.asset(icon_add),
          ),
          SizedBox(
            width: 10,
          ),
        ],
        elevation: 1,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            appTextFormField(
                validator: (value) {
                  if (value == '' || value == null) {
                    return txtPleaseEnterItemName;
                  } else {
                    return null;
                  }
                },
                title: txtItemName,
                hintText: txtEnterItemName,
                isReadOnly: true,
                controller: _itemNameController),
            SizedBox(
              height: 3.h,
            ),
            // Column(
            //   children: [
            //     Align(
            //       alignment: Alignment.topLeft,
            //       child: appText('Select Group'),
            //     ),
            //     SizedBox(
            //       height: 5,
            //     ),
            //     Row(
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       children: [
            //         Expanded(
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             children: [
            //               Container(
            //                 height: 50,
            //                 padding: EdgeInsets.symmetric(horizontal: 10),
            //                 decoration: BoxDecoration(
            //                     color: Colors.grey.withOpacity(.2),
            //                     borderRadius: BorderRadius.circular(10)),
            //                 child: DropdownButton<String>(
            //                   isExpanded: true,
            //                   value: allergies,
            //                   icon: const Icon(
            //                     Icons.expand_more_outlined,
            //                     color: appPrimaryColor,
            //                   ),
            //                   elevation: 16,
            //                   hint: appText('Select Allergies'),
            //                   style: defaultTextStyle(
            //                     color: Colors.black26,
            //                   ),
            //                   underline: Container(
            //                     decoration: BoxDecoration(
            //                       borderRadius: BorderRadius.all(
            //                         Radius.circular(12),
            //                       ),
            //                     ),
            //                     height: 2,
            //                     // color: Colors.deepPurpleAccent,
            //                   ),
            //                   onChanged: (String? newValue) {
            //                     setState(
            //                       () {
            //                         allergies = newValue!;
            //                       },
            //                     );
            //                   },
            //                   items: <String>[
            //                     'Eggs',
            //                     'Lobster',
            //                     'Fish',
            //                   ].map<DropdownMenuItem<String>>((String value) {
            //                     return DropdownMenuItem<String>(
            //                       value: value,
            //                       child: Text(
            //                         value,
            //                         style: TextStyle(color: Colors.black),
            //                       ),
            //                     );
            //                   }).toList(),
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //         Container(
            //           child: Row(
            //             children: [
            //               SizedBox(
            //                 width: 15,
            //               ),
            //               appIcon(path: iconEditOrange, width: 24, height: 24),
            //               SizedBox(
            //                 width: 30,
            //               ),
            //               appIcon(path: iconTrash, width: 24, height: 24),
            //             ],
            //           ),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
            // SizedBox(
            //   height: 3.h,
            // ),
            // Column(
            //   children: [
            //     Align(
            //       alignment: Alignment.topLeft,
            //       child: appText('Select Group'),
            //     ),
            //     SizedBox(
            //       height: 5,
            //     ),
            //     Row(
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       children: [
            //         Expanded(
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             children: [
            //               Container(
            //                 height: 50,
            //                 padding: EdgeInsets.symmetric(horizontal: 10),
            //                 decoration: BoxDecoration(
            //                     color: Colors.grey.withOpacity(.2),
            //                     borderRadius: BorderRadius.circular(10)),
            //                 child: DropdownButton<String>(
            //                   isExpanded: true,
            //                   value: allergies,
            //                   icon: const Icon(
            //                     Icons.expand_more_outlined,
            //                     color: appPrimaryColor,
            //                   ),
            //                   elevation: 16,
            //                   hint: appText('Select Allergies'),
            //                   style: defaultTextStyle(
            //                     color: Colors.black26,
            //                   ),
            //                   underline: Container(
            //                     decoration: BoxDecoration(
            //                       borderRadius: BorderRadius.all(
            //                         Radius.circular(12),
            //                       ),
            //                     ),
            //                     height: 2,
            //                     // color: Colors.deepPurpleAccent,
            //                   ),
            //                   onChanged: (String? newValue) {
            //                     setState(
            //                       () {
            //                         allergies = newValue!;
            //                       },
            //                     );
            //                   },
            //                   items: <String>[
            //                     'Eggs',
            //                     'Lobster',
            //                     'Fish',
            //                   ].map<DropdownMenuItem<String>>((String value) {
            //                     return DropdownMenuItem<String>(
            //                       value: value,
            //                       child: Text(
            //                         value,
            //                         style: TextStyle(color: Colors.black),
            //                       ),
            //                     );
            //                   }).toList(),
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //         Container(
            //           child: Row(
            //             children: [
            //               SizedBox(
            //                 width: 15,
            //               ),
            //               appIcon(path: iconEditOrange, width: 24, height: 24),
            //               SizedBox(
            //                 width: 30,
            //               ),
            //               appIcon(path: iconTrash, width: 24, height: 24),
            //             ],
            //           ),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
            // SizedBox(
            //   height: 20,
            // ),
            // appText('+ Add Modifier Group',
            //     fontWeight: FontWeight.w600, color: orangeClr),

            Container(
              child: appText(txtSelectGroupOfModifier),
            ),
            SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: ItemServices().FetchItemModifiers(
                  context: context, item_id: widget.item_id),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  var docList = snapshot.data!.docs;

                  if (docList.length == 0) {
                    return Center(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height / 2,
                        child: const Center(child: Text(txtNoModifers)),
                      ),
                    );
                  } else {
                    return Expanded(
                      child: ListView.separated(
                        separatorBuilder: (context, int) {
                          print(int);
                          return const SizedBox(
                            height: 6,
                          );
                        },
                        scrollDirection: Axis.vertical,
                        padding: EdgeInsets.all(0),
                        //reverse: true,
                        itemCount: docList.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, index) {
                          Map<String, dynamic> data =
                              docList[index].data() as Map<String, dynamic>;
                          print(data);
                          ModifierModel modifierModel =
                              ModifierModel.fromJson(data);

                          return ListWidget(
                            is_selected: modifierModel.is_enable!,
                            item_id: modifierModel.item_id!,
                            group_name: modifierModel.group_name!,
                            currentModel: modifierModel,
                          );
                        },
                      ),
                    );
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(color: appPrimaryColor),
                  );
                }
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class ListWidget extends StatefulWidget {
  String group_name;
  String item_id;
  bool is_selected;
  ModifierModel currentModel;

  ListWidget(
      {required String this.group_name,
      required String this.item_id,
      required bool this.is_selected,
      required ModifierModel this.currentModel});

  @override
  _ListWidgetState createState() => _ListWidgetState();
}

class _ListWidgetState extends State<ListWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: appText(
          widget.group_name.toString(),
        ),
        onTap: () {},
        trailing: Switch(
          activeColor: appPrimaryColor,
          value: widget.is_selected,
          onChanged: (val) async {
            await ItemServices.ChangeModifierStatus(
                currentModel: widget.currentModel, is_selected: val);
            if (val == false) {
              Fluttertoast.showToast(msg: txtModifierStatusChangedToInactive);
            } else {
              Fluttertoast.showToast(msg: txtModifierStatusChangedToActive);
            }
          },
        ),
      ),
    );
  }
}
