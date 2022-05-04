import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:midika/models/item_category_model.dart';
import 'package:midika/utils/firebase_references.dart';

class CategoryService {
  Future<List<ItemCategory>> getCategories() async {
    final categoryCollection = FirebaseFirestore.instance
        .collection(FirebaseReferences.category_collection);

    List<ItemCategory> categoryList = [];
    QuerySnapshot snapshot = await categoryCollection.get();

    List? docList = snapshot.docs;
    for (var i = 0; i < docList.length; i++) {
      categoryList.add(ItemCategory.fromJson(docList[i].data));
    }
    return categoryList;
  }
}
