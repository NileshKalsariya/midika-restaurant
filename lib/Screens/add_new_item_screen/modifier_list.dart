import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:midika/common/app_button.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/common/loader_layout.dart';
import 'package:midika/models/modifer_model.dart';
import 'package:midika/services/auth_services.dart';
import 'package:midika/services/item_services.dart';
import 'package:midika/utils/asset_paths.dart';
import 'package:midika/utils/colors.dart';
import 'package:midika/utils/strings.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'add_modifier_screen.dart';

class ModifierList extends StatefulWidget {
  String item_id;

  ModifierList({required this.item_id});

  @override
  _ModifierListState createState() => _ModifierListState();
}

class _ModifierListState extends State<ModifierList> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: white,
            title: appText(txtModifier,
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
                    return AddModifierScreen(item_id: widget.item_id);
                  }));
                },
                child: Image.asset(icon_add),
              ),
              const SizedBox(width: 10),
            ],
            elevation: 1,
          ),
          body: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 1.4,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: SingleChildScrollView(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: ItemServices().FetchItemModifiers(
                        context: context, item_id: widget.item_id),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        var docList = snapshot.data!.docs;

                        if (docList.isEmpty) {
                          return Center(
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height / 2,
                              child: const Center(child: Text(txtNoModifers)),
                            ),
                          );
                        } else {
                          return ListView.builder(
                              scrollDirection: Axis.vertical,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(0),
                              //reverse: true,
                              itemCount: docList.length,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, index) {
                                Map<String, dynamic> data = docList[index]
                                    .data() as Map<String, dynamic>;

                                ModifierModel modifierModel =
                                    ModifierModel.fromJson(data);

                                return ListWidget(
                                    item_id: modifierModel.item_id!,
                                    group_name: modifierModel.group_name!);
                              });
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: appButton(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return AddModifierScreen(item_id: widget.item_id);
                      }));
                    },
                    text: txtAddNewModifier,
                    width: double.infinity),
              ),
            ],
          ),
        ),
        Provider.of<AuthServices>(context, listen: true).isLoading
            ? LoaderLayoutWidget()
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget ListWidget({required String group_name, required String item_id}) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10)),
          height: MediaQuery.of(context).size.height / 12,
          width: double.infinity,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                appText(group_name.toString()),
                Row(
                  children: [
                    GestureDetector(
                      child: Image.asset(iconEditOrange),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return AddModifierScreen(
                              item_id: widget.item_id,
                              edit_item: true,
                              group_name: group_name);
                        }));
                      },
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      child: Image.asset(iconTrash),
                      onTap: () {
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
                                      txtAreYouSureYouWantToRemoveTheModifierFromItem),
                                  const SizedBox(height: 30),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: appButton(
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            text: txtCancel,
                                            isOnlyBorder: true,
                                            borderColor: appPrimaryColor,
                                            color: Colors.white),
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: appButton(
                                            onTap: () async {
                                              Navigator.pop(context);
                                              final provider =
                                                  Provider.of<AuthServices>(
                                                      context,
                                                      listen: false);
                                              provider.setLoaderState(true);
                                              await ItemServices().deleteItem(
                                                  item_id: item_id,
                                                  modifier_name: group_name);
                                              provider.setLoaderState(false);
                                              Fluttertoast.showToast(
                                                  msg:
                                                      txtModifierDeletedFromItem);
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
                    SizedBox(width: 5),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
