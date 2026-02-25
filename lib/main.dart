import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import './screens/auth/registration_screen.dart';
import './screens/auth/email_login_screen.dart';
import './screens/auth/otp_screen.dart';
import './screens/main_flow/root_navigator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Important ito!

  // Initialize Firebase
  await Firebase.initializeApp();

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
        '/home': (context) => const RootNavigator(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
