import 'package:flutter/material.dart';

final appTheme = ThemeData(
  primaryColor: const Color(0xFF5D8AA8),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: Color(0xFF5D8AA8),
      fontSize: 20,
      fontWeight: FontWeight.w500,
    ),
    iconTheme: IconThemeData(color: Color(0xFF5D8AA8)),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    selectedItemColor: Color(0xFF5D8AA8),
    unselectedItemColor: Colors.grey,
    type: BottomNavigationBarType.fixed,
  ),
  colorScheme: const ColorScheme.light(primary: Color(0xFF5D8AA8)),
);
