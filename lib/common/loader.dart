import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:midika/utils/asset_paths.dart';

class Loader extends StatelessWidget {
  const Loader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        alignment: Alignment.center,
        height: 200,
        width: 200,
        child: Lottie.asset(loader),
      ),
    );
  }
}
