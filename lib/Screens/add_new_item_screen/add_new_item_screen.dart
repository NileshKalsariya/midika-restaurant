import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:midika/Screens/add_new_item_screen/select_group_screen.dart';
import 'package:midika/common/app_button.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/common/app_text_form_field.dart';
import 'package:midika/common/loader_layout.dart';
import 'package:midika/models/item_category_model.dart';
import 'package:midika/models/item_model.dart';
import 'package:midika/provider/user_provider.dart';
import 'package:midika/services/auth_services.dart';
import 'package:midika/services/item_services.dart';
import 'package:midika/services/storage_method.dart';
import 'package:midika/utils/asset_paths.dart';
import 'package:midika/utils/colors.dart';
import 'package:midika/utils/strings.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class AddItemScreen extends StatefulWidget {
  Item? item;

  AddItemScreen({Key? key, Item? this.item}) : super(key: key);

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  bool showImage = false;
  ImagePicker picker = ImagePicker();
  File? myImage;

  bool editMode = false; // edit mode == true , add mode false

  String? allergies;
  String? categoryId;
  TextEditingController _itemNameController = new TextEditingController();
  TextEditingController _itemPriceController = new TextEditingController();
  TextEditingController _itemDescription = new TextEditingController();
  bool vegeterian = false;
  bool showInPopular = true;
  bool itemAvailableInStock = true;
  bool vegen = true;
  String? editImage;
  String? item_id;
  String? added_on;
  final _formKey = GlobalKey<FormState>();

  bool isLobsterSelected = false;
  bool isFishSelected = false;
  bool isEggSelected = false;
  bool isFirstTimeClicked = true;
  bool allergiebool = false;

  List<dynamic> allergiesList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkEditMode();
  }

  checkEditMode() async {
    // FirebaseFirestore.instance
    //     .collection('items')
    //     .where('item_name', isEqualTo: 'we')
    //     .get()
    //     .then((value) {
    //   FirebaseFirestore.instance
    //       .collection('items')
    //       .doc(value.docs[0].id)
    //       .delete();
    // });

    String? data = await FirebaseMessaging.instance.getToken();
    print(data);
    if (widget.item != null) {
      setState(() {
        editMode = true;
      });
    }
    if (editMode == true) {
      setState(
        () {
          _itemNameController.text = widget.item!.itemName.toString();
          _itemPriceController.text = widget.item!.itemPrice.toString();
          _itemDescription.text = widget.item!.itemDescription.toString();
          categoryId = widget.item!.categoryId.toString();
          allergies = widget.item!.allergies.toString();
          vegeterian = widget.item!.vegeterian!;
          showInPopular = widget.item!.itemShowInPopular;
          itemAvailableInStock = widget.item!.itemAvailableInStock;
          editImage = widget.item!.itemImage;
          vegen = widget.item!.wegan!;
          showImage = true;
          item_id = widget.item!.itemId;
          added_on = widget.item!.addedOn;
          allergiesList = widget.item!.allergies!;
          if (allergiesList.contains('Lobster')) {
            isLobsterSelected = true;
          }
          if (allergiesList.contains('Fish')) {
            isFishSelected = true;
          }
          if (allergiesList.contains('Egg')) {
            isEggSelected = true;
          }
          print(widget.item!.wegan);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: white,
              title: appText(editMode ? txtEditItem : txtAddItem,
                  fontWeight: FontWeight.w500, fontSize: 14.sp),
              leading: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: black,
                ),
              ),
              elevation: 1,
            ),
            body: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: Column(
                    children: [
                      itemImage(),
                      SizedBox(
                        height: 3.h,
                      ),
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
                        controller: _itemNameController,
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          appText(
                            txtProductType,
                            color: black,
                            fontSize: 11.sp,
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                          Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Container(
                                  height: 50, child: categoryField())),
                        ],
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      appTextFormField(
                          validator: (value) {
                            if (value == '' || value == null) {
                              return txtPleaseEnterPrice;
                            } else {
                              return null;
                            }
                          },
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          title: txtPrice,
                          hintText: txtEnterPrice,
                          controller: _itemPriceController),
                      SizedBox(
                        height: 3.h,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          appText(
                            txtAllergies,
                            color: black,
                            fontSize: 11.sp,
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (ctxt) => new AlertDialog(
                                  insetPadding: EdgeInsets.zero,
                                  contentPadding: EdgeInsets.zero,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  content: StatefulBuilder(
                                    builder: (context, setState) {
                                      return Container(
                                        padding: EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            appText(
                                              'Allergens',
                                              fontSize: 10.sp,
                                              color: Color(0xffB1B1B1),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Image.asset(
                                                      icon_egg,
                                                      scale: 2,
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    appText('Eggs'),
                                                  ],
                                                ),
                                                GestureDetector(
                                                  child: isEggSelected
                                                      ? Icon(
                                                          Icons.check_box,
                                                          color:
                                                              appPrimaryColor,
                                                        )
                                                      : Icon(
                                                          Icons
                                                              .check_box_outline_blank,
                                                        ),
                                                  onTap: () {
                                                    if (editMode == true &&
                                                        isFirstTimeClicked ==
                                                            true) {
                                                      setState(() {
                                                        allergiesList =
                                                            allergiesList;
                                                        isFirstTimeClicked =
                                                            false;
                                                      });
                                                    }
                                                    setState(() {
                                                      isEggSelected =
                                                          !isEggSelected;
                                                      if (isEggSelected ==
                                                          true) {
                                                        allergiesList
                                                            .add('Egg');
                                                      } else {
                                                        allergiesList
                                                            .remove('Egg');
                                                      }
                                                      print(allergiesList);
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Image.asset(
                                                      icon_fish,
                                                      scale: 2,
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    appText('Fish'),
                                                  ],
                                                ),
                                                GestureDetector(
                                                  child: isFishSelected
                                                      ? Icon(
                                                          Icons.check_box,
                                                          color:
                                                              appPrimaryColor,
                                                        )
                                                      : Icon(
                                                          Icons
                                                              .check_box_outline_blank,
                                                        ),
                                                  onTap: () {
                                                    if (editMode == true &&
                                                        isFirstTimeClicked ==
                                                            true) {
                                                      setState(() {
                                                        allergiesList =
                                                            allergiesList;
                                                        isFirstTimeClicked =
                                                            false;
                                                      });
                                                    }
                                                    setState(
                                                      () {
                                                        isFishSelected =
                                                            !isFishSelected;
                                                        if (isFishSelected ==
                                                            true) {
                                                          allergiesList
                                                              .add('Fish');
                                                        } else {
                                                          allergiesList
                                                              .remove('Fish');
                                                        }
                                                        print(allergiesList);
                                                      },
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Image.asset(
                                                      icon_lobster,
                                                      scale: 2,
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    appText('lobster'),
                                                  ],
                                                ),
                                                GestureDetector(
                                                  child: isLobsterSelected
                                                      ? Icon(
                                                          Icons.check_box,
                                                          color:
                                                              appPrimaryColor,
                                                        )
                                                      : Icon(
                                                          Icons
                                                              .check_box_outline_blank,
                                                        ),
                                                  onTap: () {
                                                    if (editMode == true &&
                                                        isFirstTimeClicked ==
                                                            true) {
                                                      setState(() {
                                                        allergiesList =
                                                            allergiesList;
                                                        isFirstTimeClicked =
                                                            false;
                                                      });
                                                    }
                                                    setState(
                                                      () {
                                                        isLobsterSelected =
                                                            !isLobsterSelected;
                                                        if (isLobsterSelected ==
                                                            true) {
                                                          allergiesList
                                                              .add('Lobster');
                                                        } else {
                                                          allergiesList.remove(
                                                              'Lobster');
                                                        }
                                                        print(allergiesList);
                                                      },
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              height: 50,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(.2),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  appText(allergiesList.isEmpty
                                      ? txtSelectAllergies
                                      : allergiesList.join(', ')),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    size: 30,
                                    color: appPrimaryColor,
                                  )
                                ],
                              ),

                              // child:
                              // DropdownButton<String>(
                              //   isExpanded: true,
                              //   value: allergies == '' ? null : allergies,
                              //   icon: const Icon(
                              //     Icons.expand_more_outlined,
                              //     color: appPrimaryColor,
                              //   ),
                              //   elevation: 16,
                              //   hint: appText(txtSelectAllergies),
                              //   style: defaultTextStyle(
                              //     color: Colors.black26,
                              //   ),
                              //   underline: Container(
                              //     decoration: const BoxDecoration(
                              //       borderRadius: BorderRadius.all(
                              //         Radius.circular(12),
                              //       ),
                              //     ),
                              //     height: 2,
                              //     // color: Colors.deepPurpleAccent,
                              //   ),
                              //   onChanged: (String? newValue) {
                              //     setState(
                              //       () {
                              //         allergies = newValue!;
                              //       },
                              //     );
                              //   },
                              //   items: <String>[
                              //     txtEggs,
                              //     txtLobster,
                              //     txtFish,
                              //   ].map<DropdownMenuItem<String>>((String value) {
                              //     return DropdownMenuItem<String>(
                              //       value: value,
                              //       child: Text(
                              //         value,
                              //         style: const TextStyle(color: Colors.black),
                              //       ),
                              //     );
                              //   }).toList(),
                              // ),
                            ),
                          ),
                          Visibility(
                              visible: allergiebool,
                              child: Text('please select Allergens')),
                          SizedBox(
                            height: 3.h,
                          ),
                          appTextFormField(
                              // validator: (value) {
                              //   if (value == '' || value == null) {
                              //     return txtPleaseEnterItemDescription;
                              //   } else {
                              //     return null;
                              //   }
                              // },
                              minLine: 4,
                              title: txtItemDescription,
                              hintText: txtAddDescriptionAboutFood,
                              controller: _itemDescription),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: appText(txtVegeterian),
                              ),
                              Container(
                                child: Switch(
                                  activeColor: appPrimaryColor,
                                  value: vegeterian,
                                  onChanged: (val) {
                                    setState(() {
                                      vegeterian = val;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: appText(txtVegan),
                              ),
                              Container(
                                child: Switch(
                                  activeColor: appPrimaryColor,
                                  value: vegen,
                                  onChanged: (val) {
                                    setState(() {
                                      vegen = val;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: appText(txtShowInPopular),
                              ),
                              Container(
                                child: Switch(
                                  activeColor: appPrimaryColor,
                                  value: showInPopular,
                                  onChanged: (val) {
                                    setState(() {
                                      showInPopular = val;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: appText(txtItemAvailableInStock),
                              ),
                              Container(
                                child: Switch(
                                  activeColor: appPrimaryColor,
                                  value: itemAvailableInStock,
                                  onChanged: (val) {
                                    setState(() {
                                      itemAvailableInStock = val;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 3.h,
                          ),
                          appButton(
                              onTap: () async {
                                FocusScope.of(context).unfocus();
                                if (_formKey.currentState!.validate() &&
                                        (myImage != null) ||
                                    (editImage != null)) {
                                  if (categoryId != null) {
                                    final _provoder = Provider.of<ItemServices>(
                                        context,
                                        listen: false);

                                    if (editMode == true && myImage != null) {
                                      // if (allergiesList.isNotEmpty) {
                                      print('edit mode with myimage not null');

                                      _provoder.setLoaderState(true);
                                      StorageMethods storageMethods =
                                          new StorageMethods();
                                      final imageData = await storageMethods
                                          .uplaodImageToServer(
                                              myImage, 'item_images');
                                      Item edit_item_with_image = Item(
                                        allergies: allergiesList,
                                        itemDescription: _itemDescription.text,
                                        itemName: _itemNameController.text,
                                        itemPrice: double.parse(
                                            _itemPriceController.text),
                                        vegeterian: vegeterian,
                                        categoryId: categoryId,
                                        itemAvailableInStock:
                                            itemAvailableInStock,
                                        itemShowInPopular: showInPopular,
                                        itemImage: imageData['url'],
                                        itemId: item_id,
                                        addedOn: added_on,
                                        wegan: vegen,
                                        restaurantId:
                                            Provider.of<RestaurantProvider>(
                                                    context,
                                                    listen: false)
                                                .restaurantModel
                                                .restaurantId,
                                      );

                                      await ItemServices().edit_item(
                                          context: context,
                                          item: edit_item_with_image);
                                      _provoder.setLoaderState(false);
                                      Navigator.pushReplacement(context,
                                          MaterialPageRoute(builder: (context) {
                                        return SelectGroupScreen(
                                            item_name: _itemNameController.text,
                                            item_id: item_id!);
                                      }));
                                      // } else {
                                      //   Fluttertoast.showToast(
                                      //       msg: 'please select allergens');
                                      // }

                                      // Navigator.pop(context);
                                    } else if (editMode == true &&
                                        myImage == null) {
                                      // if (allergiesList.isNotEmpty) {
                                      print('edit mode with myimage null');
                                      _provoder.setLoaderState(true);
                                      Item edit_item_without_image = Item(
                                        allergies: allergiesList,
                                        itemDescription: _itemDescription.text,
                                        itemName: _itemNameController.text,
                                        itemPrice: double.parse(
                                            _itemPriceController.text),
                                        vegeterian: vegeterian,
                                        categoryId: categoryId,
                                        itemAvailableInStock:
                                            itemAvailableInStock,
                                        itemShowInPopular: showInPopular,
                                        itemImage: editImage,
                                        itemId: item_id,
                                        addedOn: added_on,
                                        wegan: vegen,
                                        restaurantId:
                                            Provider.of<RestaurantProvider>(
                                                    context,
                                                    listen: false)
                                                .restaurantModel
                                                .restaurantId,
                                      );
                                      await ItemServices().edit_item(
                                          context: context,
                                          item: edit_item_without_image);
                                      _provoder.setLoaderState(false);
                                      Navigator.pushReplacement(context,
                                          MaterialPageRoute(builder: (context) {
                                        return SelectGroupScreen(
                                            item_name: _itemNameController.text,
                                            item_id: item_id!);
                                      }));
                                      // } else {
                                      //   Fluttertoast.showToast(
                                      //       msg: 'please select allergens');
                                      // }

                                      // Navigator.pop(context);
                                    } else {
                                      // if (allergiesList.isNotEmpty) {
                                      //   print('add item');
                                      _provoder.setLoaderState(true);
                                      Item item = Item(
                                        allergies: allergiesList,
                                        itemDescription: _itemDescription.text,
                                        itemName: _itemNameController.text,
                                        itemPrice: double.parse(
                                            _itemPriceController.text),
                                        vegeterian: vegeterian,
                                        categoryId: categoryId,
                                        wegan: vegen,
                                        itemAvailableInStock:
                                            itemAvailableInStock,
                                        itemShowInPopular: showInPopular,
                                        restaurantId:
                                            Provider.of<RestaurantProvider>(
                                                    context,
                                                    listen: false)
                                                .restaurantModel
                                                .restaurantId,
                                      );
                                      String ItemId = await ItemServices()
                                          .addItem(
                                              item: item,
                                              context: context,
                                              image: myImage);
                                      // setState(() {
                                      //   _itemPriceController.text = '';
                                      //   _itemNameController.text = '';
                                      //   _itemDescription.text = '';
                                      //   showImage = false;
                                      //   myImage = null;
                                      // });
                                      _provoder.setLoaderState(false);

                                      Fluttertoast.showToast(
                                          msg: txtItemAddedSuccessfully);
                                      // Navigator.push(context,
                                      //     MaterialPageRoute(builder: (context) {
                                      //   return ItemAdded();
                                      // })).then((value) => setState(() {
                                      //       editMode = false;
                                      // }));

                                      Navigator.pushReplacement(context,
                                          MaterialPageRoute(builder: (context) {
                                        return SelectGroupScreen(
                                            item_name: _itemNameController.text,
                                            item_id: ItemId);
                                      }));
                                      // } else {
                                      //   Fluttertoast.showToast(
                                      //       msg: 'please select allergnes');
                                      // }
                                    }
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: 'please enter category');
                                  }
                                } else if ((myImage == null) ||
                                    (editImage == null)) {
                                  Fluttertoast.showToast(
                                      msg: txtPleaseEnterImage);
                                }
                              },
                              text: txtSaveAndNext,
                              width: double.infinity),
                          SizedBox(
                            height: 1.h,
                          ),
                          editMode
                              ? appButton(
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
                                                  '$txtAreYouSureYouWantToDelete ${widget.item!.itemName.toString()} ?'),
                                              const SizedBox(height: 30),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: appButton(
                                                        onTap: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        text: txtCancel,
                                                        isOnlyBorder: true,
                                                        borderColor:
                                                            appPrimaryColor,
                                                        color: Colors.white),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Expanded(
                                                    child: appButton(
                                                        color:
                                                            Colors.red.shade400,
                                                        onTap: () async {
                                                          Navigator.pop(
                                                              context);
                                                          final provider = Provider
                                                              .of<ItemServices>(
                                                                  context,
                                                                  listen:
                                                                      false);
                                                          provider
                                                              .setLoaderState(
                                                                  true);
                                                          await ItemServices
                                                              .deleteItemPermenent(
                                                            item_id: item_id!,
                                                          );
                                                          provider
                                                              .setLoaderState(
                                                                  false);
                                                          Navigator.pop(
                                                              context);
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
                                  color: Colors.red,
                                  text: txtDeleteItem,
                                  width: double.infinity)
                              : const SizedBox(),
                          SizedBox(height: 6.h),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Provider.of<ItemServices>(context).is_loading
            ? LoaderLayoutWidget()
            : SizedBox.shrink(),
      ],
    );
  }

  Future<File> cropImage(File image) async {
    File? croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        cropStyle: CropStyle.rectangle,
        aspectRatioPresets: [CropAspectRatioPreset.ratio16x9],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: appPrimaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.ratio16x9,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(title: "Cropper"));

    return croppedFile!;
  }

  Future getImage() async {
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 50);
    final File croppedFile = await cropImage(File(pickedFile!.path));

    setState(
      () {
        if (croppedFile != null) {
          myImage = File(croppedFile.path);
          showImage = true;
        } else {
          print('No image selected.');
        }
      },
    );
  }

  Widget itemImage() {
    return showImage
        ? Container(
            child: Stack(
              children: [
                DottedBorder(
                  dashPattern: [10, 7],
                  color: Colors.grey,
                  borderType: BorderType.RRect,
                  strokeCap: StrokeCap.round,
                  strokeWidth: 1,
                  padding: EdgeInsets.all(6),
                  radius: Radius.circular(12),
                  child: Container(
                      height: MediaQuery.of(context).size.height / 4,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: myImage == null
                              ? editMode
                                  ?
                                  // ? Image.network(editImage!,
                                  //     width: double.infinity, fit: BoxFit.fill)
                                  CachedNetworkImage(
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      progressIndicatorBuilder:
                                          (context, url, progress) => Center(
                                        child: CircularProgressIndicator(
                                          value: progress.progress,
                                        ),
                                      ),
                                      imageUrl: editImage!,
                                    )
                                  : Image.file(
                                      myImage!,
                                      width: double.infinity,
                                      fit: BoxFit.fill,
                                    )
                              : Image.file(
                                  myImage!,
                                  width: double.infinity,
                                  fit: BoxFit.fill,
                                ))),
                ),
                Positioned(
                  left: 80,
                  right: 80,
                  bottom: 20,
                  child: GestureDetector(
                    onTap: () async {
                      await getImage();
                    },
                    child: Container(
                      height: 30,
                      width: 100,
                      decoration: BoxDecoration(
                          color: appPrimaryColor,
                          borderRadius: BorderRadius.circular(30)),
                      child: Center(
                        child: appText(
                          txtChange,
                          color: white,
                          fontWeight: FontWeight.w500,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : DottedBorder(
            dashPattern: [10, 7],
            color: Colors.grey,
            borderType: BorderType.RRect,
            strokeCap: StrokeCap.round,
            strokeWidth: 1,
            padding: EdgeInsets.all(6),
            radius: Radius.circular(12),
            child: ClipRRect(
              child: Container(
                height: 170,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Center(
                      child: Image.asset(
                        imgUpload,
                        width: 70,
                        height: 70,
                      ),
                    ),
                    appText(
                      txtUpload,
                      color: black,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                    ),
                    GestureDetector(
                      onTap: () async {
                        await getImage();
                      },
                      child: Container(
                        height: 30,
                        width: MediaQuery.of(context).size.width / 3,
                        decoration: BoxDecoration(
                            color: appPrimaryColor,
                            borderRadius: BorderRadius.circular(30)),
                        child: Center(
                          child: appText(
                            txtUpload,
                            color: white,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 0,
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget categoryField() {
    List<DropdownMenuItem<String>>? dropdownList = [];
    List<ItemCategory> categoryList = [];
    categoryList =
        Provider.of<AuthServices>(context, listen: false).getCategoryList;

    for (int i = 0; i < categoryList.length; i++) {
      DropdownMenuItem<String> item = DropdownMenuItem<String>(
        child: Row(
          children: <Widget>[
            // SizedBox(
            //   width: 8,
            // ),
            // CustomImage(
            //   width: 20,
            //   height: 20,
            //   imgURL: categoryList[i].categoryImage!,
            // ),
            // SizedBox(
            //   width: 20,
            // ),
            Text(categoryList[i].categoryName!),
          ],
        ),
        value: categoryList[i].categoryId,
      );

      dropdownList.add(item);
    }

    return DropdownButton<String>(
      underline: const SizedBox.shrink(),
      items: dropdownList,
      isExpanded: true,
      onChanged: (String? value) {
        setState(() {
          categoryId = value;
        });
      },
      hint: appText(txtSelectCategory),
      value: categoryId,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
      iconEnabledColor: appPrimaryColor,
      iconSize: 30,
    );
  }
}
