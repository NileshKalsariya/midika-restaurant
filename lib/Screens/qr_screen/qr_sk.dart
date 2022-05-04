import 'dart:developer';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:midika/Screens/qr_screen/create_qr_code_screen.dart';
import 'package:midika/Screens/qr_screen/widget_to_img.dart';
import 'package:midika/common/app_button.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/common/app_text_form_field.dart';
import 'package:midika/common/loader_layout.dart';
import 'package:midika/models/qr_code_model.dart';
import 'package:midika/models/restaurant_model.dart';
import 'package:midika/provider/user_provider.dart';
import 'package:midika/services/qr_code_services.dart';
import 'package:midika/utils/colors.dart';
import 'package:midika/utils/strings.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:random_color/random_color.dart';
import 'package:sizer/sizer.dart';

class QrNewScreen extends StatefulWidget {
  const QrNewScreen({Key? key}) : super(key: key);

  @override
  _QrNewScreenState createState() => _QrNewScreenState();
}

class _QrNewScreenState extends State<QrNewScreen> {
  TextEditingController _startController = TextEditingController();
  TextEditingController _endController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  List<GlobalKey> _globalKeyList = [];

  bool _showSave = false;

  final RandomColor _randomColor = RandomColor();

  bool _isColourQr = false;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  Restaurant? provider;

  QrCodeServices? qrProvider;

  getCurrentUser() {
    setState(() {
      provider =
          Provider.of<RestaurantProvider>(context, listen: false).GetRestaurant;
      qrProvider = Provider.of<QrCodeServices>(context, listen: false);
    });
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
              leading: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: black,
                ),
              ),
              title: appText(
                txtManageQRCode,
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
              ),
              elevation: 1,
            ),
            body: SingleChildScrollView(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 16.0,
                      right: 16.0,
                      left: 16.0,
                      bottom: 30.0,
                    ),
                    child: Column(
                      children: [
                        Form(
                          key: _formKey,
                          child: Row(
                            children: [
                              Expanded(
                                child: appTextFormField(
                                  validator: (value) {
                                    if (value == '') {
                                      return txtPleaseEnterTableNumber;
                                    } else if (!checkValue(value!)) {
                                      return txtPleaseEnterValidNumber;
                                    } else {
                                      return null;
                                    }
                                  },
                                  title: txtTableNoStart,
                                  hintText: txtEnterStartingNumber,
                                  controller: _startController,
                                  minLine: 1,
                                  maxline: 1,
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: appTextFormField(
                                  validator: (value) {
                                    if (value == '') {
                                      return txtPleaseEnterTableNumber;
                                    } else if (!checkValue(value!)) {
                                      return txtPleaseEnterValidNumber;
                                    } else {
                                      return null;
                                    }
                                  },
                                  title: txtTableNoEnd,
                                  hintText: txtEnterEndingNumber,
                                  controller: _endController,
                                  minLine: 1,
                                  maxline: 1,
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            appText(txtDoYouWantColorQR),
                            CupertinoSwitch(
                              value: _isColourQr,
                              onChanged: (value) {
                                setState(() => _isColourQr = value);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (_startController.text.isNotEmpty &&
                            _endController.text.isNotEmpty)
                          SizedBox(
                            height: 300,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  for (int i = 0;
                                      i <=
                                          (int.parse(_endController.text) -
                                              int.parse(_startController.text));
                                      i++)
                                    WidgetToImage(
                                      builder: (key) {
                                        _globalKeyList.insert(i, key);
                                        // var rng = Random();
                                        return QrImage(
                                          data: (int.parse(_startController.text
                                                          .toString()) +
                                                      i)
                                                  .toString() +
                                              '?' +
                                              provider!.restaurantId.toString(),
                                          version: QrVersions.auto,
                                          size: 70.w,
                                          foregroundColor: _isColourQr
                                              ? _randomColor.randomColor()
                                              : black,
                                          padding: const EdgeInsets.all(16.0),
                                          backgroundColor: white,
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        if (_showSave == false) const SizedBox(height: 20),
                        if (_showSave == false)
                          appButton(
                            width: 100.w,
                            onTap: () {
                              setState(() {
                                _showSave = true;
                              });
                            },
                            text: txtCreate,
                          ),
                        if (_showSave) const SizedBox(height: 20),
                        if (_showSave)
                          appButton(
                            width: 100.w,
                            onTap: () async {
                              FocusScope.of(context).unfocus();
                              log('---------- ${int.parse(_endController.text) - int.parse(_startController.text)}');
                              int _start = int.parse(_startController.text);
                              final _provider = Provider.of<QrCodeServices>(
                                  context,
                                  listen: false);
                              if (_formKey.currentState!.validate()) {
                                _provider.setLoaderState(true);
                                log('--------length::: ${_globalKeyList.length}');
                                for (int i = 0;
                                    i <=
                                        (int.parse(_endController.text) -
                                            int.parse(_startController.text));
                                    i++) {
                                  //start loop
                                  final bytes1 =
                                      await Utils.capture(_globalKeyList[i]);
                                  print(bytes1);
                                  final fileName = DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString();

                                  UploadTask task = FirebaseStorage.instance
                                      .ref()
                                      .child(
                                          'qr_codes/${DateTime.now().millisecondsSinceEpoch}')
                                      .putData(bytes1);

                                  final taskSnapshot =
                                      await task.whenComplete(() {});

                                  final data = {
                                    'url':
                                        await taskSnapshot.ref.getDownloadURL(),
                                    'fileName': fileName,
                                  };

                                  final url = data['url'];

                                  QrCodeModel qrCodeModel = QrCodeModel();
                                  qrCodeModel.qrCodeUrl = url;
                                  await _provider.saveQrCodeToFirebase(
                                    qrcode: qrCodeModel,
                                    context: context,
                                    table_no: _start + i,
                                  );
                                  Utils.downloadImage(
                                      fileName: "Qr_${_start + i}",
                                      bytes: await Utils.capture(
                                          _globalKeyList[i]));

                                  log('loop status ::: $i');
                                  //end loop
                                }
                                _provider.setLoaderState(false);
                              }
                              log('process -done---------------- ');
                              Navigator.pop(context);
                            },
                            text: "Save",
                          ),
                      ],
                    ),
                  ),
                  Provider.of<QrCodeServices>(context, listen: true).is_loading
                      ? LoaderLayoutWidget()
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ),
        Provider.of<QrCodeServices>(context, listen: true).is_loading
            ? LoaderLayoutWidget()
            : const SizedBox.shrink(),
      ],
    );
  }

  //check value
  checkValue(String? val) {
    if (val!.contains(',') || val.contains('.')) {
      return false;
    } else {
      return true;
    }
  }
}
