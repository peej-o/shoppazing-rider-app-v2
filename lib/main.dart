import 'package:flutter/material.dart';
import './screens/auth/registration_screen.dart';
import './screens/auth/email_login_screen.dart';
import './screens/auth/otp_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shoppazing Rider App',
      theme: ThemeData(
        primaryColor: const Color(0xFF5D8AA8),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const RegistrationScreen(),
        '/email_login': (context) => const EmailLoginScreen(),
        '/otp': (context) => const OTPScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
