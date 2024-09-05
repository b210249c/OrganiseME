import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SpinKitFadingCircle(
              color: Theme.of(context).primaryColor,
              size: 50.0,
            ),
            const SizedBox(height: 20.0),
            const Text('Loading...'),
          ],
        ),
      );
    },
  );
}