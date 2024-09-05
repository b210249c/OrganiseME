import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:organise_me/screen/login_screen.dart';
import 'package:organise_me/screen/register_screen.dart';
import 'package:organise_me/components/utils.dart';

class WelcomeScreen extends StatelessWidget {
  static String id = 'welcome_screen';

  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F2ED),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(
                        "images/image1.png",
                        width: SizeConfig.scaleSize(222),
                        height: SizeConfig.scaleSize(267),
                      ),
                      AutoSizeText(
                        'OrganiseME',
                        textScaleFactor: 1.3.sp,
                        style:TextStyle(
                          color: const Color(0xFF285430),
                          fontFamily: 'Coiny',
                          fontWeight: FontWeight.w400,
                          fontSize: 26.sp,
                          letterSpacing: -1.5,
                          shadows: const [
                            Shadow(
                              color: Color(0x40000000),
                              blurRadius: 4.0,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      AutoSizeText(
                        'Organise with Ease: Your All-in-One \n Personal Management System',
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
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF282828),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(SizeConfig.scaleSize(11) * 0.8),
                            ),
                          ),
                          child: AutoSizeText(
                            'Login',
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
                        width: SizeConfig.scaleSize(167),
                        height: SizeConfig.scaleSize(52),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterScreen()),
                            );
                          },
                          child: AutoSizeText(
                            'Register',
                            textScaleFactor: 1.3.sp,
                            style: TextStyle(
                              fontFamily: 'Comfortaa',
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              fontSize: 8.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
