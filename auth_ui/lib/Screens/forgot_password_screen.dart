// ignore_for_file: prefer_const_constructors, sort_child_properties_last, avoid_unnecessary_containers, unused_local_variable, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../appWrite/appwrite_client.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _resetSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    // التحقق من صحة البريد الإلكتروني
    if (_emailController.text.isEmpty) {
      setState(() {
        _errorMessage = 'الرجاء إدخال البريد الإلكتروني';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AppwriteClient.resetPassword(_emailController.text.trim());
      
      if (mounted) {
        setState(() {
          _resetSent = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
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
        body: Stack(
          children: [
            // زر الرجوع
            Positioned(
              top: 40,
              left: 20,
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            
            Container(
              margin: EdgeInsets.only(top: 100),
              child: SingleChildScrollView(
                reverse: false,
                child: Column(
                  children: [
                    Text(
                      'استعادة كلمة المرور',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    SizedBox(height: 20),
                    
                    if (!_resetSent)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        child: Text(
                          'أدخل بريدك الإلكتروني وسنرسل لك رابطًا لإعادة تعيين كلمة المرور',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    
                      if (_resetSent)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 60,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'يرجى التحقق من بريدك الإلكتروني واتباع التعليمات لإعادة تعيين كلمة المرور',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.amber),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'ملاحظة للمطور:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber[800],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'هذه نسخة تجريبية. لإرسال رسائل البريد الإلكتروني الفعلية، يجب تكوين خدمة Appwrite بشكل صحيح وتحديث الكود باستخدام طريقة API المناسبة.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.amber[900],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    if (!_resetSent) ...[
                      // عرض رسالة الخطأ إذا وجدت
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      
                      // حقل البريد الإلكتروني
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
                            hintText: 'البريد الإلكتروني',
                            hintStyle: TextStyle(
                              color: Color(0xFFa3a3a3), fontSize: 17),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 35),
                      
                      // زر إرسال رابط إعادة التعيين
                      TextButton(
                        style: ButtonStyle(
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9)
                            )
                          ),
                          backgroundColor: WidgetStatePropertyAll(three),
                          padding: WidgetStatePropertyAll(
                            EdgeInsets.symmetric(
                              vertical: 6, horizontal: 95
                            )
                          )
                        ),
                        onPressed: _isLoading ? null : _resetPassword,
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
                                'إرسال رابط التعيين',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2
                                ),
                              ),
                        )
                      ),
                    ],
                    
                    if (_resetSent)
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: TextButton(
                          style: ButtonStyle(
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9)
                              )
                            ),
                            backgroundColor: WidgetStatePropertyAll(three),
                            padding: WidgetStatePropertyAll(
                              EdgeInsets.symmetric(
                                vertical: 6, horizontal: 95
                              )
                            )
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'العودة لتسجيل الدخول',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2
                              ),
                            ),
                          )
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
