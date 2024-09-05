import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:organise_me/components/utils.dart';

TextStyle kThemeTextStyle(BuildContext context) {
  SizeConfig.init(context);
  return TextStyle(
    color: const Color(0xFF285430),
    fontFamily: 'Coiny',
    fontWeight: FontWeight.w400,
    fontSize: 24.sp,
    letterSpacing: -1.5,
    shadows: const [
      Shadow(
        color: Color(0x40000000),
        blurRadius: 4.0,
        offset: Offset(0, 4),
      ),
    ],
  );
}



