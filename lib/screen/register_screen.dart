import 'package:organise_me/components/auth_service.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:organise_me/components/loading.dart';
import 'package:organise_me/screen/login_screen.dart';
import 'package:organise_me/screen/success_screen.dart';
import 'package:organise_me/components/utils.dart';
import 'package:organise_me/screen/welcome_screen.dart';


class RegisterScreen extends StatefulWidget {
  static String id = 'register_screen';

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _register() async {

      if (_formKey.currentState!.validate()) {
        showLoadingDialog(context);

        String username = _usernameController.text.trim();
        String email = _emailController.text.trim();
        String password = _passwordController.text.trim();

        User? user = await _authService.registerWithEmailAndPassword(email, password, username);

        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SuccessScreen(text: 'Registration Successful', onPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
              );
            },)),
          );
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration failed: Email have been registered')),
          );
        }
      }
    }

  bool _isObscured = true;
  bool _isobscured = true;
  void _togglePasswordVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isobscured = !_isobscured;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                    width: SizeConfig.widthSize(202) * 0.8,
                    height: SizeConfig.heightSize(247) * 0.8,
                  ),
                  AutoSizeText(
                    'Sign Up',
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
                    height: SizeConfig.heightSize(20) * 0.8,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          MediaQuery(
                            data: MediaQuery.of(context)
                                .copyWith(textScaler: TextScaler.linear(1.3.sp)),
                            child: TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person),
                                labelText: 'Username',
                                hintText: 'Enter your username',
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
                                  return 'Username should not be empty';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(
                            height: SizeConfig.heightSize(20) * 0.8,
                          ),
                          MediaQuery(
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
                                final regex = RegExp(r'^[^@]+@[^@]+\.[a-zA-Z]{2,}$');
                                if (!regex.hasMatch(value)) {
                                  return 'Enter a valid email address';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(
                            height: SizeConfig.heightSize(20) * 0.8,
                          ),
                          MediaQuery(
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
                                if (value.length < 6) {
                                  return 'At least 6 characters long';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(
                            height: SizeConfig.heightSize(20) * 0.8,
                          ),
                          MediaQuery(
                            data: MediaQuery.of(context)
                                .copyWith(textScaler: TextScaler.linear(1.3.sp)),
                            child: TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _isobscured,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.password),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isobscured ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: _toggleConfirmPasswordVisibility,
                                ),
                                labelText: 'Confirm Password',
                                hintText: 'Retype your password',
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
                                  return 'Confirm Password should not be empty';
                                }
                                if (value != _passwordController.text) {
                                  return 'Password is not the same';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.heightSize(40) * 0.8,
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
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF282828),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              SizeConfig.heightSize(11) * 0.8),
                        ),
                      ),
                      child: AutoSizeText(
                        'Register',
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
                    height: SizeConfig.heightSize(24) * 0.8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AutoSizeText(
                        'Already have an account?',
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
                                builder: (context) => const LoginScreen()),
                          );
                        },
                        child: AutoSizeText(
                          'Login',
                          textScaleFactor: 1.0.sp,
                          style: TextStyle(
                            fontSize: 8.sp,
                            fontFamily: 'Comfortaa',
                            color: const Color(0xFF501C1F),
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
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
