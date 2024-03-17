// ignore_for_file: prefer_const_constructors, sort_child_properties_last, avoid_unnecessary_containers, unused_local_variable, prefer_const_literals_to_create_immutables, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Signup extends StatelessWidget {
  const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    const one = Color.fromARGB(213, 32, 32, 32);
    const two = Color(0xFFF5F5F5);
    const three = Color(0xFF7c7be6);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(children: [
        Positioned(top: 50, left: 10, child: BackButton()),
        Container(
          margin: EdgeInsets.only(top: 100),
          child: SingleChildScrollView(
            reverse: false,
            child: Column(
              children: [
                Text(
                  'تسجيل حساب',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                SizedBox(height: 39),
                Column(
                  children: [
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
                        showCursor: true,
                        style: TextStyle(),
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        cursorColor: three,
                        textAlign: TextAlign.end,
                        decoration: InputDecoration(
                            fillColor: three,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            focusColor: Colors.transparent,
                            border:
                                OutlineInputBorder(borderSide: BorderSide.none),
                            hintText: 'اسمك', // a3a3a3
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
                            border:
                                OutlineInputBorder(borderSide: BorderSide.none),
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
                        style: TextStyle(),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        cursorColor: three,
                        textAlign: TextAlign.end,
                        decoration: InputDecoration(
                            fillColor: three,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            focusColor: Colors.transparent,
                            border:
                                OutlineInputBorder(borderSide: BorderSide.none),
                            hintText: ' رقم جوالك', // a3a3a3
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
                        style: TextStyle(),
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        cursorColor: three,
                        textAlign: TextAlign.end,
                        decoration: InputDecoration(
                            fillColor: three,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            focusColor: Colors.transparent,
                            border:
                                OutlineInputBorder(borderSide: BorderSide.none),
                            hintText: 'الرقم السري', // a3a3a3
                            hintStyle: TextStyle(
                                color: Color(0xFFa3a3a3), fontSize: 17)),
                      ),
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    TextButton(
                        style: ButtonStyle(
                            shape: MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9))),
                            backgroundColor: MaterialStatePropertyAll(three),
                            padding: MaterialStatePropertyAll(
                                EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 95))),
                        onPressed: () {
                          // Navigator.pushNamed(context, '');
                          print('Clicked');
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'تسجيل حساب ',
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
                    Text('او تسجيل حساب عن طريق '),
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                      height: 35,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'هنا ',
                          style: TextStyle(
                              color: three, fontWeight: FontWeight.bold),
                        ),
                        Text('عندك حساب ؟ سجل دخولك من ',
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
      ]),
    );
  }
}
