import 'package:flutter/material.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'screens/auth/phone_number_screen.dart';
import './screens/auth/email_login_screen.dart';
import './screens/auth/otp_screen.dart';
import './screens/auth/register_screen.dart';
import './screens/main_flow/root_navigator.dart';
import './services/database/user_session_db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
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
        '/': (context) => const StartupPage(),
        '/login': (context) =>
            const PhoneNumberScreen(), // Changed from '/phone' to '/login'
        '/email_login': (context) => const EmailLoginScreen(),
        '/otp': (context) => const OTPScreen(),
        '/home': (context) => const RootNavigator(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class StartupPage extends StatefulWidget {
  const StartupPage({Key? key}) : super(key: key);

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    print('[DEBUG] Checking session...');

    // Check if there's a valid session
    final session = await UserSessionDB.getSession();
    print('[DEBUG] Session exists: ${session != null}');

    if (!mounted) return;

    if (session != null) {
      // May session, diretso sa home
      print('[DEBUG] Has session, going to home');
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // NO MOCK SESSION - go to login screen
      print('[DEBUG] No session, going to login');
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: Color(0xFF5D8AA8))),
    );
  }
}
