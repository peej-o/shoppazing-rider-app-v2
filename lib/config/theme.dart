import 'package:flutter/material.dart';

final appTheme = ThemeData(
  primaryColor: const Color(0xFF00509D),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: Color(0xFF00509D),
      fontSize: 20,
      fontWeight: FontWeight.w500,
    ),
    iconTheme: IconThemeData(color: Color(0xFF00509D)),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    selectedItemColor: Color(0xFF00509D),
    unselectedItemColor: Colors.grey,
    type: BottomNavigationBarType.fixed,
  ),
  colorScheme: const ColorScheme.light(primary: Color(0xFF00509D)),
);
