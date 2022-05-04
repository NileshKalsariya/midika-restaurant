import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:midika/common/app_button.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/common/app_text_form_field.dart';
import 'package:midika/common/loader_layout.dart';
import 'package:midika/models/modifer_model.dart';
import 'package:midika/services/auth_services.dart';
import 'package:midika/services/item_services.dart';
import 'package:midika/utils/colors.dart';
import 'package:midika/utils/strings.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class AddModifierScreen extends StatefulWidget {
  String item_id;
  bool? edit_item;
  String? group_name;

  AddModifierScreen(
      {required this.item_id,
      bool this.edit_item = false,
      this.group_name = ''});

  @override
  _AddModifierScreenState createState() => _AddModifierScreenState();
}

class _AddModifierScreenState extends State<AddModifierScreen> {
  int _radioSelected = 1;
  String? _radioVal = 'single';
  bool isEnableModifier = false;
  // bool isRequired = true;

  TextEditingController groupNameController = new TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<Widget> WidgetList = [];
  List<CustomModifierFields> fieldWidget = [CustomModifierFields()];

  List modifier = [];
  Map<String, dynamic>? modifier_upd_data;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      getModifierData();
    });
  }

  getModifierData() async {
    if (widget.edit_item == true) {
      Provider.of<AuthServices>(context, listen: false).setLoaderState(true);
      List data = await ItemServices().getModifierList(
          modifier_name: widget.group_name!, item_id: widget.item_id);
      Map<String, dynamic>? upd_data = await ItemServices().getModifierDoc(
          modifier_name: widget.group_name!, item_id: widget.item_id);
      setState(() {
        modifier = data;
        groupNameController.text = widget.group_name!;
        modifier_upd_data = upd_data;
        print(upd_data);
        isEnableModifier = upd_data!['is_enable'];
        // isRequired = upd_data['is_required'] ?? false;
        // if (isRequired == true) {
        //   _radioSelected = 1;
        // }
        _radioVal = upd_data['selection_mode'];
        if (_radioVal == 'multiple') {
          _radioSelected = 2;
        } else {
          print('here 2');
          _radioSelected = 1;
        }
        fieldWidget.removeAt(0);
        data.forEach((element) {
          CustomModifierFields customField = CustomModifierFields();
          customField.modifierNameController.text = element['modifier_name'];
          customField.priceNameController.text = element['price'].toString();
          fieldWidget.add(customField);
        });
      });
      Provider.of<AuthServices>(context, listen: false).setLoaderState(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: white,
            title: widget.edit_item!
                ? appText(txtEditModifierGroup,
                    fontWeight: FontWeight.w500, fontSize: 14.sp)
                : appText(txtAddModifierGroup,
                    fontWeight: FontWeight.w500, fontSize: 14.sp),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back_ios,
                color: black,
              ),
            ),
            elevation: 1,
          ),
          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: appText(txtEnableModifier),
                        ),
                        Container(
                          child: Switch(
                            activeColor: appPrimaryColor,
                            value: isEnableModifier,
                            onChanged: (val) {
                              setState(
                                () {
                                  isEnableModifier = val;
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Container(
                    //       child: appText(txtRequiredModifier),
                    //     ),
                    //     Container(
                    //       child: Switch(
                    //         activeColor: appPrimaryColor,
                    //         value: isRequired,
                    //         onChanged: (val) {
                    //           setState(
                    //             () {
                    //               isRequired = val;
                    //               if (val == true) {
                    //                 setState(() {
                    //                   _radioSelected = 1;
                    //                   _radioVal = 'single';
                    //                 });
                    //               }
                    //             },
                    //           );
                    //         },
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    SizedBox(
                      height: 15,
                    ),
                    appTextFormField(
                        validator: (value) {
                          if (value == '' || value == null) {
                            return txtPleaseEnterGroupName;
                          }
                        },
                        title: txtGroupName,
                        hintText: txtEnterGroupName,
                        maxline: 1,
                        controller: groupNameController),
                    const SizedBox(height: 15),
                    Column(
                      children: [
                        for (int i = 0; i < fieldWidget.length; i++)
                          Row(
                            children: [
                              Expanded(child: fieldWidget[i]),
                              const SizedBox(width: 5),
                              i == 0
                                  ? SizedBox.shrink()
                                  : GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          fieldWidget.removeAt(i);
                                        });
                                      },
                                      child: Icon(
                                        Icons.clear,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                    ),
                            ],
                          )
                      ],
                    ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          fieldWidget.add(CustomModifierFields());
                        });
                      },
                      child: appText('+ $txtAddMore',
                          color: orangeClr, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 20),
                    appText(txtModifierSelection),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        appText(txtSingle),
                        Radio(
                          value: 1,
                          groupValue: _radioSelected,
                          activeColor: appPrimaryColor,
                          onChanged: (value) {
                            setState(() {
                              _radioSelected = value as int;
                              _radioVal = 'single';
                            });
                          },
                        ),
                        Row(
                          children: [
                            appText(txtMultiple),
                            Radio(
                              value: 2,
                              groupValue: _radioSelected,
                              activeColor: appPrimaryColor,
                              onChanged: (value) {
                                setState(() {
                                  _radioSelected = value as int;
                                  _radioVal = 'multiple';
                                });
                              },
                            )
                          ],
                        )
                      ],
                    ),
                    appButton(
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          if (formKey.currentState!.validate()) {
                            final provider = Provider.of<AuthServices>(context,
                                listen: false);
                            provider.setLoaderState(true);
                            List<Map<String, dynamic>> modifiersList = [];
                            fieldWidget.forEach((element) {
                              Map<String, dynamic> data = {
                                'modifier_name': element
                                    .modifierNameController.text
                                    .toString(),
                                'price': double.parse(
                                    element.priceNameController.text)
                              };
                              modifiersList.add(data);
                            });

                            if (widget.edit_item == true) {
                              await ItemServices().deleteItem(
                                item_id: widget.item_id,
                                modifier_name: widget.group_name!,
                              );
                            }
                            ModifierModel currentModifier = ModifierModel(
                                group_name: groupNameController.text.toString(),
                                is_enable: isEnableModifier,
                                item_id: widget.item_id,
                                modiferList: modifiersList,
                                modifier_selection: _radioVal);
                            int? checkbool =
                                await ItemServices.saveModifierGroup(
                              context: context,
                              currentModel: currentModifier,
                            );
                            provider.setLoaderState(false);
                            if (checkbool! >= 1) {
                              Fluttertoast.showToast(
                                  msg: txtMofifierAlreadyExists);
                            } else {
                              Navigator.pop(context);
                              Fluttertoast.showToast(
                                  msg: txtModifierGroupSaved);
                            }
                          }
                        },
                        color: appPrimaryColor,
                        text: txtDone,
                        width: double.infinity),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
        Provider.of<AuthServices>(context, listen: true).isLoading
            ? LoaderLayoutWidget()
            : SizedBox.shrink()
      ],
    );
  }
}

class CustomModifierFields extends StatefulWidget {
  TextEditingController modifierNameController = new TextEditingController();
  TextEditingController priceNameController = new TextEditingController();

  CustomModifierFields({Key? key}) : super(key: key);

  @override
  _CustomModifierFieldsState createState() => _CustomModifierFieldsState();
}

class _CustomModifierFieldsState extends State<CustomModifierFields> {
  // var data = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: appTextFormField(
                  title: txtModifierName,
                  hintText: txtEnterModifierName,
                  maxline: 1,
                  validator: (value) {
                    if (value == '' || value == null) {
                      return txtPleaseEnterModifierName;
                    }
                  },
                  controller: widget.modifierNameController),
            ),
            const SizedBox(width: 30),
            Expanded(
              child: appTextFormField(
                  title: txtSetPrice,
                  hintText: txtEnterPrice,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == '' || value == null) {
                      return txtPleaseEnterModifierPrice;
                    } else {
                      return null;
                    }
                  },
                  controller: widget.priceNameController),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
