// ignore_for_file: unnecessary_const, prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_unnecessary_containers, sort_child_properties_last, unused_local_variable, duplicate_ignore, annotate_overrides, use_key_in_widget_constructors, camel_case_types, avoid_print, must_be_immutable, unnecessary_new, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'Screens/home.dart';
import 'Screens/login.dart';
import 'Screens/signup.dart';

void main() {
  runApp(MaterialApp(
    home: home(),
    theme: ThemeData(fontFamily: 'Cairo'),
    themeMode: ThemeMode.system,
    debugShowCheckedModeBanner: false,
    routes: {
      '/login': (context) => LoginPage(),
      '/signup': (context) => Signup()
    },
  ));
}
