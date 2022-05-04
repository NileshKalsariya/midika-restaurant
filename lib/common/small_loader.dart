import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:midika/utils/asset_paths.dart';

class SmallLoader extends StatelessWidget {
  const SmallLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        alignment: Alignment.center,
        height: 300,
        width: 300,
        child: Lottie.asset(smallLoader, height: 200, width: 300),
      ),
    );
  }
}
