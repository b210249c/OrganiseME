import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:organise_me/components/utils.dart';

class SuccessScreen extends StatelessWidget {
  static String id = 'login_screen';
  final String text;
  final void Function() onPress;

  const SuccessScreen({super.key, required this.text, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F2ED),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: SizeConfig.heightSize(100),
              ),
              Image.asset(
                "images/check.png",
                width: SizeConfig.scaleSize(179),
                height: SizeConfig.scaleSize(179),
              ),
              AutoSizeText(
                text,
                textScaleFactor: 1.3.sp,
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontWeight: FontWeight.w700,
                  fontSize: 10.sp,
                ),
                textAlign: TextAlign.center,
              ),
              Container(
                width: SizeConfig.scaleSize(167),
                height: SizeConfig.scaleSize(52),
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.45),
                    blurRadius: 10.0,
                    offset: const Offset(0, 4),
                  ),
                ]),
                child: ElevatedButton(
                  onPressed: onPress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF282828),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(SizeConfig.scaleSize(11) * 0.8),
                    ),
                  ),
                  child: AutoSizeText(
                    'Back',
                    textScaleFactor: 1.3.sp,
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 8.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: SizeConfig.heightSize(100),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
