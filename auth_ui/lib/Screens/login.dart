// ignore_for_file: prefer_const_constructors, sort_child_properties_last, avoid_unnecessary_containers, unused_local_variable, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../appWrite/appwrite_client.dart';
import 'forgot_password_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // التحقق من صحة البيانات
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'الرجاء إدخال البريد الإلكتروني وكلمة المرور';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/meals');
      } else if (mounted) {
        setState(() {
          _errorMessage = authProvider.error ?? 'فشل تسجيل الدخول';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // إغلاق لوحة المفاتيح عند النقر خارج حقول الإدخال
  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    const one = Color.fromARGB(213, 32, 32, 32);
    const two = Color(0xFFF5F5F5);
    const three = Color(0xFF7c7be6);
    return GestureDetector(
      onTap: _dismissKeyboard, // إغلاق لوحة المفاتيح عند النقر في أي مكان
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(children: [
          // Removed back button to prevent navigation back to welcome screen after login
          Container(
            margin: EdgeInsets.only(top: 100),
            child: SingleChildScrollView(
              reverse: false,
              child: Column(
                children: [
                  Text(
                    'تسجيل الدخول',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  SizedBox(height: 39),
                  Column(
                    children: [
                      // عرض رسالة الخطأ إذا وجدت
                      if (_errorMessage != null)
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 8),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      
                      Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: two,
                        ),
                        margin: EdgeInsets.symmetric(
                          horizontal: 40,
                        ),
                        child: TextField(
                          controller: _emailController,
                          style: TextStyle(),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          cursorColor: three,
                          textAlign: TextAlign.end,
                          decoration: InputDecoration(
                              fillColor: three,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              focusColor: Colors.transparent,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              hintText: 'ايميلك', // a3a3a3
                              hintStyle: TextStyle(
                                  color: Color(0xFFa3a3a3), fontSize: 17)),
                        ),
                      ),
                      SizedBox(height: 11),
                      Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: two,
                        ),
                        margin: EdgeInsets.symmetric(
                          horizontal: 40,
                        ),
                        child: TextField(
                          controller: _passwordController,
                          style: TextStyle(),
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          cursorColor: three,
                          textAlign: TextAlign.end,
                          decoration: InputDecoration(
                              fillColor: three,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              focusColor: Colors.transparent,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              hintText: 'الرقم السري', // a3a3a3
                              hintStyle: TextStyle(
                                  color: Color(0xFFa3a3a3), fontSize: 17)),
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 50),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'نسيت الرقم السري ؟',
                                style: TextStyle(
                                  fontSize: 12, 
                                  color: three,
                                  fontWeight: FontWeight.bold,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 35,
                      ),
                      TextButton(
                          style: ButtonStyle(
                              shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(9))),
                              backgroundColor: WidgetStatePropertyAll(three),
                              padding: WidgetStatePropertyAll(
                                  EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 95))),
                          onPressed: _isLoading ? null : _login,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'تسجيل الدخول ',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2),
                                  ),
                          )),
                      SizedBox(
                        height: 18,
                      ),
                      TextButton(
                          style: ButtonStyle(
                              shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                      side: BorderSide(
                                            width: 1.7,
                                            color: Color(0xFFa3a3a3)),
                                        borderRadius:
                                            BorderRadius.circular(9))),
                              backgroundColor:
                                  WidgetStatePropertyAll(Colors.transparent),
                              padding: WidgetStatePropertyAll(
                                  EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 98))),
                          onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, '/signup');
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'تسجيل حساب  ',
                              style: TextStyle(
                                  color: Color(0xFF5A5959),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2),
                            ),
                          )),
                      SizedBox(
                        height: 48,
                      ),
                      Text('او تسجيل الدخول عن طريق '),
                      SizedBox(
                        height: 40,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            padding: EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(9),
                              color: Color.fromRGBO(255, 255, 255, 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 7,
                                  offset: Offset(
                                      0, 0.2), // changes position of shadow
                                ),
                              ],
                              // changes position of shadow
                            ),
                            width: 150,
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                              children: [
                                SvgPicture.asset('assets/icons/google-2.svg'),
                                Text(
                                  'Google',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1),
                                )
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(9),
                              color: Color.fromRGBO(0, 0, 0, 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 7,
                                  offset: Offset(
                                      0, 0.2), // changes position of shadow
                                ),
                              ],
                              // changes position of shadow
                            ),
                            width: 150,
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/apple.svg',
                                  height: 30,
                                  color: Colors.white,
                                ),
                                Text(
                                  'Apple',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                      color: Colors.white),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 70,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'هنا ',
                            style: TextStyle(
                                color: three, fontWeight: FontWeight.bold),
                          ),
                          Text('ماعندك حساب للان ؟ سجل من ',
                              style: TextStyle(
                                  color: Color(0xFFa3a3a3),
                                  fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ])),
    );
  }
}
