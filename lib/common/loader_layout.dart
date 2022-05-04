import 'package:flutter/material.dart';

import 'loader.dart';

class LoaderLayoutWidget extends StatefulWidget {
  Color? loaderColor;
  Color? bgColor;
  double? opacity;
  LoaderLayoutWidget({this.loaderColor, this.bgColor, this.opacity});
  @override
  _LoaderLayoutWidgetState createState() => _LoaderLayoutWidgetState();
}

class _LoaderLayoutWidgetState extends State<LoaderLayoutWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Opacity(
        opacity: widget.opacity ?? 0.6,
        child: ModalBarrier(
            dismissible: false, color: widget.bgColor ?? Colors.black),
      ),
      Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Loader()],
        ),
      ),
    ]);
  }
}
