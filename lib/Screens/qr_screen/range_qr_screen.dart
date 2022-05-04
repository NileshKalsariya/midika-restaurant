import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:midika/Screens/qr_screen/widget_to_img.dart';
import 'package:midika/common/app_button.dart';
import 'package:midika/common/app_text.dart';
import 'package:midika/common/app_text_form_field.dart';
import 'package:midika/common/loader_layout.dart';
import 'package:midika/models/qr_code_model.dart';
import 'package:midika/models/restaurant_model.dart';
import 'package:midika/provider/user_provider.dart';
import 'package:midika/services/qr_code_services.dart';
import 'package:midika/services/storage_method.dart';
import 'package:midika/utils/colors.dart';
import 'package:midika/utils/strings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sizer/sizer.dart';

class RangeQrScreen extends StatefulWidget {
  QrCodeModel? qr_model;
  bool? edit_mode;

  RangeQrScreen({this.qr_model, this.edit_mode = false});

  @override
  _RangeQrScreenState createState() => _RangeQrScreenState();
}

class _RangeQrScreenState extends State<RangeQrScreen> {
  TextEditingController _fromNumberController = TextEditingController();
  TextEditingController _toNumberController = TextEditingController();

  GlobalKey? _globalKey;
  final formKey = GlobalKey<FormState>();
  Uint8List? bytes;
  File? file;
  String? qr_id = '';
  RangeValues currentRangeValues = const RangeValues(20, 60);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getCurrentUser();
  }

  Restaurant? provider;

  getCurrentUser() {
    setState(() {
      provider =
          Provider.of<RestaurantProvider>(context, listen: false).GetRestaurant;
    });
  }

  @override
  void dispose() {
    // _restaurantNameController.dispose();
    // _tableNumberController.dispose();
    super.dispose();
  }

  checkvalue(String? val) {
    if (val!.contains(',') || val.contains('.')) {
      return false;
    } else {
      return true;
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
              leading: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back_ios,
                  color: black,
                ),
              ),
              title: appText(txtGenerateRangeOfQrCode,
                  fontWeight: FontWeight.w500, fontSize: 14.sp),
              elevation: 1,
            ),
            body: Padding(
              padding: const EdgeInsets.only(
                top: 16.0,
                right: 16.0,
                left: 16.0,
                bottom: 30.0,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: appTextFormField(
                                validator: (value) {
                                  if (value == '') {
                                    return txtPleaseEnterTableNumber;
                                  } else if (!checkvalue(value!)) {
                                    return txtPleaseEnterValidNumber;
                                  } else {
                                    return null;
                                  }
                                },
                                title: txtFrom,
                                hintText: txtEnterStartTable,
                                controller: _fromNumberController,
                                // onchanged: (val) {
                                //   setState(() {
                                //     _tableNumberController.text = val!;
                                //   });
                                // },
                                minLine: 1,
                                maxline: 1,
                                keyboardType: TextInputType.number),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: appTextFormField(
                                validator: (value) {
                                  if (value == '') {
                                    return txtPleaseEnterTableNumber;
                                  } else if (!checkvalue(value!)) {
                                    return txtPleaseEnterValidNumber;
                                  } else {
                                    return null;
                                  }
                                },
                                title: txtTo,
                                hintText: txtEnterEndTable,
                                controller: _toNumberController,
                                // onchanged: (val) {
                                //   setState(() {
                                //     _tableNumberController.text = val!;
                                //   });
                                // },
                                minLine: 1,
                                maxline: 1,
                                keyboardType: TextInputType.number),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      WidgetToImage(
                        builder: (key) {
                          _globalKey = key;
                          return QrImage(
                            data: _fromNumberController.text.toString() +
                                '?' +
                                provider!.restaurantId.toString(),
                            version: QrVersions.auto,
                            size: 70.w,
                            foregroundColor: black,
                            padding: const EdgeInsets.all(16.0),
                            backgroundColor: white,
                          );
                        },
                      ),

                      // bytes != null ? buildImg(bytes!) : Container(),
                      file != null ? Image.file(file!) : Container(),
                      // const Spacer(),
                      SizedBox(
                        height: 5.h,
                      ),
                      appButton(
                        width: 100.w,
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          final provider = Provider.of<QrCodeServices>(context,
                              listen: false);

                          StorageMethods storageMethos = new StorageMethods();
                          if (formKey.currentState!.validate()) {
                            provider.setLoaderState(true);

                            final bytes1 = await Utils.capture(_globalKey!);
                            print(bytes1.runtimeType);

                            final fileName = DateTime.now()
                                .millisecondsSinceEpoch
                                .toString();

                            UploadTask task = FirebaseStorage.instance
                                .ref()
                                .child(
                                    'qr_codes/${DateTime.now().millisecondsSinceEpoch}')
                                .putData(bytes1);

                            final taskSnapshot = await task.whenComplete(() {});

                            final data = {
                              'url': await taskSnapshot.ref.getDownloadURL(),
                              'fileName': fileName,
                            };

                            final url = data['url'];

                            QrCodeModel qrCodeModel = new QrCodeModel();
                            qrCodeModel.qrCodeUrl = url;
                            await provider.saveQrCodeToFirebase(
                              qrcode: qrCodeModel,
                              context: context,
                              table_no: int.parse(
                                _fromNumberController.text.toString(),
                              ),
                              edit_mode: widget.edit_mode!,
                              qr_code_id: qr_id!,
                            );
                            Utils.downloadImage(
                                fileName: "Qr_${_fromNumberController.text}",
                                bytes: await Utils.capture(_globalKey!));
                            // final file1 =
                            //     await Utils.savePng(filename: 'table8', bytes: bytes1);
                            setState(() {
                              bytes = bytes1;
                            });
                            provider.setLoaderState(false);
                            Navigator.pop(context);
                            Fluttertoast.showToast(
                                msg: txtQRCodeSuccessfullySaved);
                            print('saved');
                          }
                        },
                        text: widget.edit_mode! ? txtEdit : txtSave,
                      ),
                      SizedBox(
                        height: 5.h,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Provider.of<QrCodeServices>(context, listen: true).is_loading
            ? LoaderLayoutWidget()
            : SizedBox.shrink(),
      ],
    );
  }

  Widget buildImg(Uint8List bytes) =>
      bytes != null ? Image.memory(bytes) : Container();
}

class Utils {
  static capture(GlobalKey key) async {
    if (key == null) return null;
    RenderRepaintBoundary? boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary?;
    final image = await boundary!.toImage(pixelRatio: 3);
    final byteDate = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteDate!.buffer.asUint8List();
    return pngBytes;
  }

  static Future<bool> requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      print(permission);
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  static downloadImage({
    required String fileName,
    required bytes,
  }) async {
    Directory? directory;
    try {
      if (Platform.isAndroid) {
        if (await requestPermission(Permission.storage) &&
                await requestPermission(Permission.accessMediaLocation) ||
            await requestPermission(Permission.manageExternalStorage)) {
          directory = (await getExternalStorageDirectory())!;
          print('path : $directory');

          String newPath = "";
          List<String> folders = directory.path.split("/");

          for (int x = 1; x < folders.length; x++) {
            String folder = folders[x];
            if (folder != "Android") {
              newPath += "/" + folder;
            } else {
              break;
            }
          }

          ///create a folder here
          newPath = newPath + "/MidikaApp";
          directory = Directory(newPath);
          print('dir : ${directory.path}');
        } else {
          print('hello');
          return false;
        }
      } else if (Platform.isIOS) {
        ///ios
        if (await requestPermission(Permission.photos)) {
          directory = await getTemporaryDirectory();
        } else {
          return false;
        }
      }
      print('outer loop ');
      if (!await directory!.exists()) {
        await directory.create(recursive: true);
        print('dir created');
      }
      if (await directory.exists()) {
        print('dir in exits : $directory');

        File file = await File('${directory.path}/$fileName.jpg').create();
        file.writeAsBytes(bytes);
        print('file write done');
        print(file);
      }
    } catch (e) {
      print('error : $e');
    }
    return false;
  }
}
