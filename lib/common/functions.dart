import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:midika/utils/colors.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app_text.dart';

class Functions {
  static void toast(String info) {
    Fluttertoast.showToast(
      timeInSecForIosWeb: 1,
      msg: info,
      backgroundColor: black400,
      textColor: white,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  static void showSnackBar({
    required BuildContext context,
    required String text,
  }) {
    final snackBar = SnackBar(
      content: appText(
        text,
        textAlign: TextAlign.center,
        color: white,
      ),
      backgroundColor: appPrimaryColor,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static showDialogBox({
    required BuildContext context,
    required String text,
    required VoidCallback? onPressed,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: SizedBox(
        height: 150.0,
        width: 300.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: appText(text),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: appText('cancel', color: Colors.red),
                ),
                TextButton(
                  onPressed: onPressed,
                  child: appText('ok', color: appPrimaryColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<bool> requestPermission(Permission permission) async {
    if (await permission.isGranted) {
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

  static Future<bool> checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        print("Please check your internet connectivity!");
        Functions.toast("Please check your internet connectivity!");
        return false;
      }
    } on SocketException catch (_) {
      print("No Internet !");
      Functions.toast("Please check your internet connectivity!");
      return false;
    }
  }

  static String getFormattedDate(String dateTime) {
    final template = DateFormat('dd, MMMM yyyy - hh:mm a');
    return template
        .format(DateTime.fromMillisecondsSinceEpoch(int.tryParse(dateTime)!));
  }

  static String getFormattedInMMDDYY(String dateTime) {
    final template = DateFormat('hh:mm a MM/dd/yy');
    return template
        .format(DateTime.fromMillisecondsSinceEpoch(int.tryParse(dateTime)!));
  }
}
