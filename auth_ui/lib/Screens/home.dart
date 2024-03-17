// ignore_for_file: use_key_in_widget_constructors, camel_case_types, prefer_const_constructors, unused_local_variable, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class home extends StatelessWidget {
  // ignore: non_constant_identifier_names

  @override
  Widget build(BuildContext context) {
    const one = Color.fromARGB(213, 32, 32, 32);
    const two = Color.fromARGB(255, 169, 169, 169);
    const three = Color(0xFF7c7be6);
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 100),
        width: double.infinity,
        child: Column(children: [
          Text(
            'منصة سكرة',
            style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                color: three),
          ),
          SizedBox(
            height: 48,
          ),
          Container(
            width: 340,
            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
            child: Lottie.asset('assets/Lottie/r73MY4B038.json'),
          ),
          SizedBox(
            height: 53,
          ),
          Text(
            'نمط حياة اسهل مع ',
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 97, 96, 96),
                letterSpacing: 2),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'سكرة ',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: three,
                    height: 1.5,
                    letterSpacing: 2),
              ),
              Text(
                '',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 97, 96, 96),
                    height: 1.5,
                    letterSpacing: 2),
              ),
            ],
          ),
          SizedBox(
            height: 13,
          ),
          SizedBox(
            height: 48,
          ),
          TextButton(
              style: ButtonStyle(
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9))),
                  backgroundColor: MaterialStatePropertyAll(three),
                  padding: MaterialStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 8, horizontal: 85))),
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'حياك مع سكرة',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2),
                ),
              )),
          SizedBox(
            height: 48,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite,
                color: three,
              ),
              Text(
                'من سكري الى سكريين ',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: two,
                    letterSpacing: 2),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
