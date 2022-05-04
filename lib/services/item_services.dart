import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:midika/models/item_model.dart';
import 'package:midika/models/modifer_model.dart';
import 'package:midika/provider/user_provider.dart';
import 'package:midika/services/storage_method.dart';
import 'package:midika/utils/firebase_references.dart';
import 'package:provider/provider.dart';

class ItemServices extends ChangeNotifier {
  bool is_loading = false;

  setLoaderState(bool value) {
    is_loading = value;
    notifyListeners();
  }

  static final CollectionReference _item_collection =
      FirebaseFirestore.instance.collection(FirebaseReferences.item_collection);

  Future<String> addItem(
      {required Item item, File? image, required BuildContext context}) async {
    StorageMethods storageMethods = StorageMethods();

    var imageData =
        await storageMethods.uplaodImageToServer(image, 'item_images');

    print('Uploaded image url :- ${imageData['url']}');
    item.itemImage = imageData['url'];

    DocumentReference doc = _item_collection.doc();
    item.itemId = doc.id;
    item.itemType = 0;
    item.restaurantId = Provider.of<RestaurantProvider>(context, listen: false)
        .restaurantModel
        .restaurantId;
    item.addedOn = DateTime.now().millisecondsSinceEpoch.toString();

    print(DateTime.fromMillisecondsSinceEpoch(int.parse(item.addedOn!),
                isUtc: true)
            .toString() +
        'this is added date of item');

    await doc.set(item.toJson());
    notifyListeners();
    return doc.id;
  }

  Stream<QuerySnapshot> FetchItem(
      {required BuildContext context, String? uid}) {
    // string currentId = Provider.of<RestaurantProvider>(context, listen: false)
    //     .GetRestaurant
    //     .restaurantId;

    print('uid on fetch item : $uid');
    return _item_collection
        .where('restaurant_id', isEqualTo: uid)
        .orderBy('added_on', descending: true)
        .snapshots();
  }

  Future edit_item({required BuildContext context, required Item item}) async {
    DocumentReference doc_ref = _item_collection.doc(item.itemId);
    print(doc_ref);
    item.itemType = 0;
    Map<String, dynamic> new_item = item.toJson();
    await doc_ref.set(new_item);
  }

  static Future<int?> saveModifierGroup(
      {required BuildContext context,
      required ModifierModel currentModel}) async {
    int checkBool = 0;

    await _item_collection
        .doc(currentModel.item_id)
        .collection('modifiers')
        .get()
        .then((value) {
      for (int m = 0; m < value.docs.length; m++) {
        if (value.docs[m].data()['selection_mode'] == 'single') {
          checkBool += 1;
        }
      }

      if (checkBool < 1 || currentModel.modifier_selection != 'single') {
        _item_collection
            .doc(currentModel.item_id)
            .collection('modifiers')
            .doc(currentModel.group_name)
            .set({
          'is_enable': currentModel.is_enable,
          'group_name': currentModel.group_name,
          'item_id': currentModel.item_id,
          'modifiers': currentModel.modiferList!.length,
          'selection_mode': currentModel.modifier_selection,
          // 'is_required': currentModel.is_required
        });

        if (currentModel.modifier_selection == 'single') {
          // for (int z = 0; z < currentModel.modiferList!.length; z++) {
          //   currentModel.modiferList![z]['price'];
          // }

          for (int i = 0; i < currentModel.modiferList!.length; i++) {
            if (i == 0) {
              currentModel.modiferList![0]['is_Selected'] = true;
            }
            print(currentModel.item_id);
            _item_collection
                .doc(currentModel.item_id)
                .collection('modifiers')
                .doc(currentModel.group_name)
                // .collection(currentModel.modiferList![i]['modifier_name'])
                .collection(currentModel.item_id!)
                .doc(currentModel.modiferList![i]['modifier_name'])
                .set(currentModel.modiferList![i]);
          }
        } else {
          for (int i = 0; i < currentModel.modiferList!.length; i++) {
            checkBool = 0;
            currentModel.modiferList![i];
            print(currentModel.item_id);
            _item_collection
                .doc(currentModel.item_id)
                .collection('modifiers')
                .doc(currentModel.group_name)
                // .collection(currentModel.modiferList![i]['modifier_name'])
                .collection(currentModel.item_id!)
                .doc(currentModel.modiferList![i]['modifier_name'])
                .set(currentModel.modiferList![i]);
          }
        }
      } else {
        print('alredy addded single');
      }
    });
    return checkBool;
  }

  Stream<QuerySnapshot> FetchItemModifiers(
      {required BuildContext context, required String item_id}) {
    return _item_collection.doc(item_id).collection('modifiers').snapshots();
  }

  Future deleteItem(
      {required String item_id, required String modifier_name}) async {
    var snapshots = await _item_collection
        .doc(item_id)
        .collection('modifiers')
        .doc(modifier_name)
        .collection(item_id)
        .get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
    await _item_collection
        .doc(item_id)
        .collection('modifiers')
        .doc(modifier_name)
        .delete();
  }

  Future<List> getModifierList(
      {required String item_id, required String modifier_name}) async {
    return await _item_collection
        .doc(item_id)
        .collection('modifiers')
        .doc(modifier_name)
        .collection(item_id)
        .orderBy('price', descending: false)
        .get()
        .then((value) {
      List _data = [];
      for (int i = 0; i < value.docs.length; i++) {
        _data.add(value.docs[i].data());
      }
      // Map<String, dynamic> mydata =
      //     value.docs[0].data() as Map<String, dynamic>;
      // print(':::::::');
      // print(mydata);
      return _data;
    });
  }

  Future<List> getModifierStatus({
    required String item_id,
  }) async {
    return await _item_collection
        .doc(item_id)
        .collection('modifiers')
        .get()
        .then((value) {
      List _data = [];
      for (int i = 0; i < value.docs.length; i++) {
        _data.add(value.docs[i].data());
      }
      return _data;
    });
  }

  getModifierDoc(
      {required String item_id, required String modifier_name}) async {
    return await _item_collection
        .doc(item_id)
        .collection('modifiers')
        .doc(modifier_name)
        .get()
        .then((value) {
      Map<String, dynamic>? data = value.data();
      return data;
    });
  }

  static editModifierGroup(
      {required String item_id, required String group_name}) async {
    await _item_collection
        .doc(item_id)
        .collection('modifiers')
        .doc(group_name)
        .delete();
  }

  static Future ChangeModifierStatus(
      {required ModifierModel currentModel, required bool is_selected}) async {
    int? modifier_data;
    String? selection_mode;

    await _item_collection
        .doc(currentModel.item_id)
        .collection('modifiers')
        .doc(currentModel.group_name)
        .get()
        .then((value) {
      modifier_data = value.data()!['modifiers'];
      selection_mode = value.data()!['selection_mode'];
    });

    await _item_collection
        .doc(currentModel.item_id)
        .collection('modifiers')
        .doc(currentModel.group_name)
        .set(
      {
        'is_enable': is_selected,
        'group_name': currentModel.group_name,
        'item_id': currentModel.item_id,
        'modifiers': modifier_data,
        'selection_mode': selection_mode
      },
    );
  }

  static Future deleteItemPermenent({required String item_id}) async {
    print(item_id);
    var snapshots =
        await _item_collection.doc(item_id).collection('modifiers').get().then(
      (value) {
        value.docs.forEach(
          (element) async {
            if (value.docs.length > 0) {
              var docdata = await _item_collection
                  .doc(item_id)
                  .collection('modifiers')
                  .doc(element.id)
                  .collection(item_id)
                  .get();
              for (var doc in docdata.docs) {
                await doc.reference.delete();
              }
              await _item_collection
                  .doc(item_id)
                  .collection('modifiers')
                  .doc(element.id)
                  .delete();
            }
          },
        );
      },
    );
    await _item_collection.doc(item_id).delete();
  }
}
