import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:midika/common/app_button.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/common/loader_layout.dart';
import 'package:midika/models/user_card_model.dart';
import 'package:midika/services/card_services.dart';
import 'package:midika/services/payment_service.dart';
import 'package:midika/utils/colors.dart';
import 'package:midika/utils/strings.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';

class AddCardScreen extends StatefulWidget {
  final double amount;
  final int month;

  const AddCardScreen({
    Key? key,
    required this.amount,
    required this.month,
  }) : super(key: key);

  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  String cardNickName = "";
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isSaved = false;

  OutlineInputBorder? border;
  OutlineInputBorder? errorBorder;
  OutlineInputBorder? activeBorder;

  bool _isLoading = false;

  @override
  void initState() {
    border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.withOpacity(0.7),
        width: 1.0,
      ),
      borderRadius: BorderRadius.circular(12.0),
    );

    errorBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.red.withOpacity(0.7),
        width: 1.0,
      ),
      borderRadius: BorderRadius.circular(12.0),
    );

    activeBorder = OutlineInputBorder(
      borderSide: const BorderSide(
        color: appPrimaryColor,
        width: 1.0,
      ),
      borderRadius: BorderRadius.circular(12.0),
    );
    // setLoaderFalse();
    super.initState();
  }

  setLoaderFalse() async {
    print('here');
    Provider.of<PaymentServiceProvider>(context, listen: true).setIsLoading =
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Stack(
          children: [
            Scaffold(
              // appBar: appBar(context, txtAddCreditCard),
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
              ),

              body: SafeArea(
                child: Column(
                  children: <Widget>[
                    CreditCardWidget(
                      cardNumber: cardNumber,
                      expiryDate: expiryDate,
                      cardHolderName: cardHolderName,
                      cvvCode: cvvCode,
                      showBackView: isCvvFocused,
                      obscureCardNumber: true,
                      obscureCardCvv: true,
                      isHolderNameVisible: true,
                      cardBgColor: appPrimaryColor,
                      isSwipeGestureEnabled: true,
                      onCreditCardWidgetChange:
                          (CreditCardBrand creditCardBrand) {},
                      customCardTypeIcons: <CustomCardTypeIcon>[
                        CustomCardTypeIcon(
                          cardType: CardType.mastercard,
                          cardImage: Image.asset(
                            'assets/icons/icon_master_card_bg.png',
                            height: 48,
                            width: 48,
                          ),
                        ),
                        CustomCardTypeIcon(
                          cardImage: Image.asset(
                            'assets/icons/icon_visa_bg.png',
                            height: 48,
                            width: 48,
                          ),
                          cardType: CardType.visa,
                        ),
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            CreditCardForm(
                              formKey: formKey,
                              obscureCvv: true,
                              obscureNumber: false,
                              cardNumber: cardNumber,
                              cvvCode: cvvCode,
                              isHolderNameVisible: true,
                              isCardNumberVisible: true,
                              isExpiryDateVisible: true,
                              // isNickNameVisible: false,
                              cardHolderName: cardHolderName,
                              expiryDate: expiryDate,
                              themeColor: Colors.blue,
                              textColor: black,
                              cursorColor: appPrimaryColor,
                              cardNumberDecoration: InputDecoration(
                                labelText: txtCardNumber,
                                hintText: '1234 1234 1234 1234',
                                hintStyle: defaultTextStyle(),
                                labelStyle: defaultTextStyle(fontSize: 13.sp),
                                border: border,
                                focusedBorder: activeBorder,
                                enabledBorder: border,
                                errorBorder: errorBorder,
                              ),
                              expiryDateDecoration: InputDecoration(
                                hintStyle: defaultTextStyle(),
                                labelStyle: defaultTextStyle(fontSize: 13.sp),
                                focusedBorder: activeBorder,
                                enabledBorder: border,
                                errorBorder: errorBorder,
                                border: border,
                                labelText: txtValidThru,
                                hintText: 'MM/YY',
                              ),
                              cvvCodeDecoration: InputDecoration(
                                hintStyle: defaultTextStyle(),
                                labelStyle: defaultTextStyle(fontSize: 13.sp),
                                focusedBorder: activeBorder,
                                enabledBorder: border,
                                errorBorder: errorBorder,
                                border: border,
                                labelText: 'CVV',
                                hintText: '***',
                              ),
                              cardHolderDecoration: InputDecoration(
                                hintStyle: defaultTextStyle(),
                                labelStyle: defaultTextStyle(fontSize: 13.sp),
                                focusedBorder: activeBorder,
                                enabledBorder: border,
                                errorBorder: errorBorder,
                                border: border,
                                labelText: txtCardholderName,
                              ),
                              onCreditCardModelChange: onCreditCardModelChange,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: appText(
                                          txtDoYouWantToSaveThisCard,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                      CupertinoSwitch(
                                        activeColor: appPrimaryColor,
                                        value: _isSaved,
                                        onChanged: (value) =>
                                            setState(() => _isSaved = value),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  appButton(
                                    text: 'Pay \$ ${widget.amount}',
                                    width: 100.w,
                                    onTap: () async {
                                      if (formKey.currentState!.validate()) {
                                        log('valid!');

                                        if (_isSaved) {
                                          UserCard _card = UserCard(
                                            userId: FirebaseAuth
                                                .instance.currentUser!.uid,
                                            cardHolderName: cardHolderName,
                                            cardNumber: cardNumber,
                                            expiryDate: expiryDate,
                                            cvvCode: cvvCode,
                                          );

                                          await CardServices()
                                              .saveCard(context, card: _card)
                                              .then((value) {
                                            setState(() => _isLoading = false);
                                            // Navigator.pop(context);
                                          });
                                        }

                                        StripeCard _card = StripeCard(
                                          cvc: cvvCode,
                                          number: cardNumber,
                                          last4: cardNumber
                                              .substring(cardNumber.length - 4),
                                          expMonth: int.parse(
                                              expiryDate.split("/")[0]),
                                          expYear: int.parse(
                                              expiryDate.split("/")[1]),
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
                                      } else {
                                        print('invalid!');
                                      }
                                    },
                                  ),
                                  SizedBox(height: 2.h),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Provider.of<PaymentServiceProvider>(context, listen: true)
                    .getIsLoading
                ? LoaderLayoutWidget()
                : SizedBox()
          ],
        ),
      ],
    );
  }

  void onCreditCardModelChange(CreditCardModel? creditCardModel) {
    setState(() {
      cardNumber = creditCardModel!.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}
