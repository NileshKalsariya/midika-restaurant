import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/models/user_card_model.dart';
import 'package:midika/utils/colors.dart';

class CardServices {
  static final CollectionReference _userCardsCollection = FirebaseFirestore
      .instance
      .collection('users_restaurant')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('card');

  Future<void> saveCard(BuildContext context, {required UserCard card}) async {
    try {
      DocumentReference documentReference = _userCardsCollection.doc();
      card.cardId = documentReference.id;
      card.addedOn = DateTime.now().millisecondsSinceEpoch.toString();
      await documentReference.set(card.toJson()).then((value) {
        final snackBar = SnackBar(
          content: appText(
            'Card Added Successfully!',
            textAlign: TextAlign.center,
            color: white,
          ),
          backgroundColor: appPrimaryColor,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<List<UserCard>> fetchUserCards() async {
    List<UserCard> cardList = [];

    QuerySnapshot snapshot =
        await _userCardsCollection.orderBy("added_on", descending: true).get();

    List? docList = snapshot.docs;
    log(docList.length.toString());
    for (var i = 0; i < docList.length; i++) {
      cardList.add(UserCard.fromJson(docList[i].data()));
    }
    return cardList;
  }

  Future<void> updateCard({
    required String cardId,
    required bool isDefault,
  }) {
    return _userCardsCollection.doc(cardId).update({'isDefault': isDefault});
  }

  void deleteCard({
    required String cardId,
  }) {
    _userCardsCollection.doc(cardId).delete();
  }

  Stream<QuerySnapshot> fetchUserCardStream() {
    return _userCardsCollection
        .orderBy("added_on", descending: true)
        .snapshots();
  }



}
