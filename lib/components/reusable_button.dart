import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:organise_me/components/utils.dart';

class ReusableButton extends StatelessWidget {
  final String text;
  final void Function() onPress;
  final Color backgroundColor;
  final Color textColor;

  const ReusableButton({super.key, required this.text, required this.backgroundColor, required this.textColor, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPress,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              SizeConfig.widthSize(11) * 0.8),
        ),
        side: const BorderSide(color: Colors.black26),
      ),
      child: AutoSizeText(
        text,
        textScaleFactor: 1.0.sp,
        style: TextStyle(
          fontFamily: 'Comfortaa',
          fontWeight: FontWeight.w700,
          fontSize: 14.sp,
          color: textColor,
        ),
      ),
    );
  }
}