// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

/// مزود الثيم - يدير حالة الثيم (الوضع الليلي/النهاري) في التطبيق
class ThemeProvider with ChangeNotifier {
  // متغير لتخزين حالة الثيم الحالية
  bool _isDarkMode = false;

  // getter للحصول على حالة الثيم
  bool get isDarkMode => _isDarkMode;

  /// دالة لتبديل الثيم بين الوضع الليلي والنهاري
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  /// دالة للحصول على الثيم الحالي بناءً على الحالة
  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  /// تعريف الثيم النهاري
  static final lightTheme = ThemeData(
    fontFamily: 'Cairo', // نوع الخط المستخدم
    brightness: Brightness.light, // سطوع الثيم
    primaryColor: Color(0xFF7c7be6), // اللون الرئيسي للتطبيق
    scaffoldBackgroundColor: Colors.white, // لون خلفية الشاشة
    colorScheme: ColorScheme.light(
      primary: Color(0xFF7c7be6), // اللون الرئيسي
      secondary: Color(0xFF7c7be6), // اللون الثانوي
      surface: Colors.white, // لون السطح
      background: Colors.white, // لون الخلفية
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white, // لون خلفية شريط التطبيق
      elevation: 0, // إزالة الظل
      iconTheme: IconThemeData(color: Colors.black), // لون الأيقونات
      titleTextStyle: TextStyle(
        color: Colors.black, // لون النص
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white, // لون البطاقات
      elevation: 2, // مستوى الظل
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.black87), // لون النص الرئيسي
      bodyMedium: TextStyle(color: Colors.black87), // لون النص المتوسط
      titleLarge: TextStyle(color: Colors.black), // لون العناوين الكبيرة
      titleMedium: TextStyle(color: Colors.black87), // لون العناوين المتوسطة
    ),
  );

  /// تعريف الثيم الليلي المحسن
  static final darkTheme = ThemeData(
    fontFamily: 'Cairo',
    brightness: Brightness.dark,
    primaryColor: Color(0xFF7c7be6),
    scaffoldBackgroundColor: Color(0xFF0A0A0F), // خلفية داكنة مع لمسة زرقاء
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF7c7be6),
      secondary: Color(0xFF9290FF), // لون ثانوي أفتح قليلاً
      surface: Color(0xFF15151F), // سطح داكن مع لمسة زرقاء
      background: Color(0xFF0A0A0F),
      onSurface: Colors.white,
      onBackground: Colors.white,
      tertiary: Color(0xFF6E6DE0), // لون إضافي للتأكيد
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF15151F),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: Color(0xFF15151F),
      elevation: 4,
      shadowColor: Color(0xFF7c7be6).withOpacity(0.2), // ظل بلون التطبيق
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white.withOpacity(0.95)),
      bodyMedium: TextStyle(color: Colors.white.withOpacity(0.85)),
      titleLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: Colors.white.withOpacity(0.9),
        fontWeight: FontWeight.w500,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.white.withOpacity(0.15),
    ),
    iconTheme: IconThemeData(
      color: Colors.white.withOpacity(0.85),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF15151F),
      selectedItemColor: Color(0xFF7c7be6),
      unselectedItemColor: Colors.white.withOpacity(0.6),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Color(0xFF15151F),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Color(0xFF15151F),
      contentTextStyle: TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
