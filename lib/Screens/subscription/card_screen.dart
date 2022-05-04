import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:midika/Screens/subscription/add_card_screen.dart';
import 'package:midika/common/app_button.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/common/functions.dart';
import 'package:midika/common/loader.dart';
import 'package:midika/common/loader_layout.dart';
import 'package:midika/models/user_card_model.dart';
import 'package:midika/services/card_services.dart';
import 'package:midika/services/payment_service.dart';
import 'package:midika/utils/colors.dart';
import 'package:midika/utils/strings.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';

class CardScreen extends StatefulWidget {
  final double amount;
  final int month;

  const CardScreen({
    Key? key,
    required this.amount,
    required this.month,
  }) : super(key: key);

  @override
  _CardScreenState createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            foregroundColor: white,
            backgroundColor: white,
            elevation: 0,
            leading: GestureDetector(
              child: const Icon(
                Icons.arrow_back,
                color: black,
              ),
              onTap: () => Navigator.pop(context),
            ),
            title: appText('$txtAmount : \$${widget.amount}'),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: StreamBuilder(
                    stream: CardServices().fetchUserCardStream(),
                    builder: (
                      BuildContext context,
                      AsyncSnapshot<dynamic> snapshot,
                    ) {
                      if (snapshot.hasData) {
                        List? docList = snapshot.data.docs;
                        List<UserCard> _cardList = [];

                        for (int i = 0; i < docList!.length; i++) {
                          _cardList.add(
                              UserCard.fromJson(snapshot.data.docs[i].data()));
                        }

                        print(_cardList.length);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            appText(
                              txtCards,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            Expanded(
                              child: ListView.separated(
                                // physics: const NeverScrollableScrollPhysics(),
                                itemCount: _cardList.length,
                                shrinkWrap: true,

                                itemBuilder: (context, index) {
                                  String _cardTypePath = "";

                                  switch (detectCCType(
                                      _cardList[index].cardNumber ?? "")) {
                                    case CardType.otherBrand:
                                      _cardTypePath =
                                          'assets/icons/icon_payment_methods.png';
                                      break;
                                    case CardType.mastercard:
                                      _cardTypePath =
                                          'assets/icons/icon_master_card_bg.png';
                                      break;
                                    case CardType.visa:
                                      _cardTypePath =
                                          'assets/icons/icon_visa_bg.png';
                                      break;
                                    case CardType.americanExpress:
                                      _cardTypePath =
                                          'assets/icons/icon_payment_methods.png';
                                      break;
                                    case CardType.discover:
                                      _cardTypePath =
                                          'assets/icons/icon_payment_methods.png';
                                      break;
                                  }

                                  return ListTile(
                                    isThreeLine: true,
                                    leading: Image.asset(
                                      _cardTypePath,
                                      height: 40.sp,
                                      width: 40.sp,
                                    ),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            appText(
                                                _cardList[index]
                                                        .cardHolderName ??
                                                    "",
                                                fontWeight: FontWeight.w500),
                                            appText(
                                              "**** **** **** ${_cardList[index].cardNumber!.substring(_cardList[index].cardNumber!.length - 4)}",
                                              color: black400,
                                            )
                                          ],
                                        ),
                                        appButton(
                                          onTap: () {
                                            //todo pay here

                                            StripeCard _card = StripeCard(
                                              cvc: _cardList[index].cvvCode,
                                              number:
                                                  _cardList[index].cardNumber,
                                              last4: _cardList[index]
                                                  .cardNumber!
                                                  .substring(_cardList[index]
                                                          .cardNumber!
                                                          .length -
                                                      4),
                                              expMonth: int.parse(
                                                  _cardList[index]
                                                      .expiryDate!
                                                      .split("/")[0]),
                                              expYear: int.parse(
                                                  _cardList[index]
                                                      .expiryDate!
                                                      .split("/")[1]),
                                            );

                                            Provider.of<PaymentServiceProvider>(
                                                    context,
                                                    listen: false)
                                                .makePayment(
                                              context,
                                              card: _card,
                                              month: widget.month,
                                              amount: widget.amount,
                                            );
                                          },
                                          text: txtPay,
                                          width: 100,
                                        ),
                                      ],
                                    ),
                                    subtitle: Align(
                                      heightFactor: 1.3,
                                      alignment: Alignment.bottomRight,
                                      child: GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                Functions.showDialogBox(
                                              context: context,
                                              text:
                                                  txtAreYouSureToDeleteThisCard,
                                              onPressed: () {
                                                CardServices().deleteCard(
                                                    cardId: _cardList[index]
                                                        .cardId!);

                                                Navigator.of(context).pop();

                                                log('deleted ::: ${_cardList[index].cardId}');
                                              },
                                            ),
                                          );
                                        },
                                        child: Image.asset(
                                            'assets/icons/icon_delete1.png',
                                            height: 28,
                                            width: 28),
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const SizedBox(height: 8),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            appButton(
                              isOnlyBorder: true,
                              text: txtPayWithNewCard,
                              color: white,
                              borderColor: appPrimaryColor,
                              width: 100.w,
                              onTap: () => pushNewScreen(
                                context,
                                screen: AddCardScreen(
                                    amount: widget.amount, month: widget.month),
                                withNavBar: true,
                                pageTransitionAnimation:
                                    PageTransitionAnimation.cupertino,
                              ),
                            ),
                            const SizedBox(height: 40.0),
                          ],
                        );
                      } else {
                        return const Loader();
                      }
                    },
                  ),
                ),
                // if (Provider.of<PaymentServiceProvider>(context,listen: true).getIsLoading)
                //   const Opacity(
                //     opacity: 0.4,
                //     child: ModalBarrier(dismissible: false, color: Colors.black),
                //   ),
                // if (Provider.of<PaymentServiceProvider>(context,listen: true).getIsLoading)
                //   const Loader()
              ],
            ),
          ),
        ),
        Provider.of<PaymentServiceProvider>(context, listen: true).getIsLoading
            ? LoaderLayoutWidget()
            : SizedBox.shrink(),
      ],
    );
  }
}

///detect card type
CardType detectCCType(String cardNumber) {
  Map<CardType, Set<List<String>>> cardNumPatterns =
      <CardType, Set<List<String>>>{
    CardType.visa: <List<String>>{
      <String>['4'],
    },
    CardType.americanExpress: <List<String>>{
      <String>['34'],
      <String>['37'],
    },
    CardType.discover: <List<String>>{
      <String>['6011'],
      <String>['622126', '622925'],
      <String>['644', '649'],
      <String>['65']
    },
    CardType.mastercard: <List<String>>{
      <String>['51', '55'],
      <String>['2221', '2229'],
      <String>['223', '229'],
      <String>['23', '26'],
      <String>['270', '271'],
      <String>['2720'],
    },
  };

  //Default card type is other
  CardType cardType = CardType.otherBrand;

  if (cardNumber.isEmpty) {
    return cardType;
  }

  cardNumPatterns.forEach(
    (CardType type, Set<List<String>> patterns) {
      for (List<String> patternRange in patterns) {
        // Remove any spaces
        String ccPatternStr = cardNumber.replaceAll(RegExp(r'\s+\b|\b\s'), '');
        final int rangeLen = patternRange[0].length;
        // Trim the Credit Card number string to match the pattern prefix length
        if (rangeLen < cardNumber.length) {
          ccPatternStr = ccPatternStr.substring(0, rangeLen);
        }

        if (patternRange.length > 1) {
          // Convert the prefix range into numbers then make sure the
          // Credit Card num is in the pattern range.
          // Because Strings don't have '>=' type operators
          final int ccPrefixAsInt = int.parse(ccPatternStr);
          final int startPatternPrefixAsInt = int.parse(patternRange[0]);
          final int endPatternPrefixAsInt = int.parse(patternRange[1]);
          if (ccPrefixAsInt >= startPatternPrefixAsInt &&
              ccPrefixAsInt <= endPatternPrefixAsInt) {
            // Found a match
            cardType = type;
            break;
          }
        } else {
          // Just compare the single pattern prefix with the Credit Card prefix
          if (ccPatternStr == patternRange[0]) {
            // Found a match
            cardType = type;
            break;
          }
        }
      }
    },
  );

  return cardType;
}
