import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:organise_me/components/auth_service.dart';
import 'package:organise_me/screen/home_screen.dart';
import 'package:organise_me/screen/register_screen.dart';
import 'package:organise_me/components/utils.dart';
import 'package:organise_me/screen/welcome_screen.dart';
import 'package:organise_me/components/loading.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'login_screen';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscured = true;
  void _togglePasswordVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PopScope(
        canPop: false,
        onPopInvoked: ((didpop) {
          if (!didpop) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WelcomeScreen()),
            );
          }
        }),
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F2ED),
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const WelcomeScreen()),
                        );
                      },
                      icon: const Icon(Icons.arrow_back_outlined),
                      tooltip: 'back',
                    ),
                  ),
                  Image.asset(
                    "images/image1.png",
                    width: SizeConfig.widthSize(222) * 0.8,
                    height: SizeConfig.heightSize(267) * 0.8,
                  ),
                  SizedBox(
                    height: SizeConfig.heightSize(31) * 0.8,
                  ),
                  AutoSizeText(
                    'Welcome Back',
                    textScaleFactor: 1.3.sp,
                    style: TextStyle(
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
                  SizedBox(
                    height: SizeConfig.heightSize(30) * 0.8,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                          ),
                          child: MediaQuery(
                            data: MediaQuery.of(context)
                                .copyWith(textScaler: TextScaler.linear(1.3.sp)),
                            child: TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.email),
                                labelText: 'Email',
                                hintText: 'Enter your email',
                                border: const OutlineInputBorder(),
                                labelStyle: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email should not be empty';
                                }
                                return null;

                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: SizeConfig.heightSize(23) * 0.8,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                          ),
                          child: MediaQuery(
                            data: MediaQuery.of(context)
                                .copyWith(textScaler: TextScaler.linear(1.3.sp)),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: _isObscured,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.password),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isObscured ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: _togglePasswordVisibility,
                                ),
                                labelText: 'Password',
                                hintText: 'Enter your password',
                                border: const OutlineInputBorder(),
                                labelStyle: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password should not be empty';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.heightSize(56) * 0.8,
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
                      onPressed: () async {

                        if (_formKey.currentState!.validate()) {
                          try {
                            showLoadingDialog(context);

                            UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: _emailController.text,
                              password: _passwordController.text,
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const HomeScreen()),
                            );
                          } catch (e) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Invalid email or password')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF282828),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              SizeConfig.widthSize(11) * 0.8),
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
                    height: SizeConfig.heightSize(38) * 0.8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AutoSizeText(
                        'Don\'t have an account?',
                        textScaleFactor: 1.0.sp,
                        style: TextStyle(
                          fontSize: 8.sp,
                          fontFamily: 'Comfortaa',
                          color: const Color(0xFF501C1F),
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: AutoSizeText(
                          'Sign Up',
                          textScaleFactor: 1.0.sp,
                          style: TextStyle(
                            fontSize: 8.sp,
                            fontFamily: 'Comfortaa',
                            color: const Color(0xFF501C1F),
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

