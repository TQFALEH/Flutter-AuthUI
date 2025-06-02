// ignore_for_file: unnecessary_const, prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_unnecessary_containers, sort_child_properties_last, unused_local_variable, duplicate_ignore, annotate_overrides, use_key_in_widget_constructors, camel_case_types, avoid_print, must_be_immutable, unnecessary_new, depend_on_referenced_packages, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'appWrite/appwrite_client.dart' show AuthProvider;
import 'providers/meal_provider.dart';
import 'providers/theme_provider.dart';
import 'Screens/login.dart';
import 'Screens/signup.dart';
import 'Screens/main_layout.dart';

/// نقطة بداية التطبيق
void main() {
  runApp(const MyApp());
}

/// الويدجت الرئيسي للتطبيق
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<MealProvider>(
          create: (_) => MealProvider(),
          lazy: false,
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return GestureDetector(
            onTap: () {
              // Dismiss keyboard when tapping anywhere on the screen
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'سكره',
              theme: themeProvider.currentTheme,
              initialRoute: '/',
              routes: {
                '/': (context) => AuthenticationWrapper(),
                '/login': (context) => LoginPage(),
                '/signup': (context) => Signup(),
                '/meals': (context) => MainLayout(),
              },
            ),
          );
        },
      ),
    );
  }
}

/// شاشة التهيئة الأولية للتطبيق
class AuthenticationWrapper extends StatefulWidget {
  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = context.read<AuthProvider>().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7c7be6),
              ),
            ),
          );
        }

        return Consumer<AuthProvider>(
          builder: (_, auth, __) {
            return auth.isAuthenticated ? MainLayout() : LoginPage();
          },
        );
      },
    );
  }
}
