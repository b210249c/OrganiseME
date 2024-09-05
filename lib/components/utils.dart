import 'package:flutter/widgets.dart';

class SizeConfig {
  static double scaleWidth = 1.0;
  static double scaleHeight = 1.0;
  static double scale = 1.0;

  static void init(BuildContext context, {double baseWidth = 360.0, double baseHeight = 800.0}) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom);
    scaleWidth = deviceWidth / baseWidth;
    scaleHeight = deviceHeight / baseHeight;
    scale = (scaleWidth + scaleHeight) / 2;
  }

  static double widthSize(double size) {
    return size * scaleWidth;
  }

  static double heightSize(double size) {
    return size * scaleHeight;
  }

  static double scaleSize(double size) {
    return size * scale;
  }
}

