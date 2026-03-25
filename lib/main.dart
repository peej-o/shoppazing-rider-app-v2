import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth/phone_number_screen.dart';
import 'screens/auth/email_login_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main_flow/root_navigator.dart'; // Use regular, not riverpod version
import 'services/database/user_session_db.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const StartupPage(),
        '/login': (context) => const PhoneNumberScreen(),
        '/email_login': (context) => const EmailLoginScreen(),
        '/otp': (context) => const OTPScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const RootNavigator(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

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
    final session = await UserSessionDB.getSession();

    if (!mounted) return;

    if (session != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
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

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'screens/auth/phone_number_screen.dart';
// import 'screens/auth/email_login_screen.dart';
// import 'screens/auth/otp_screen.dart';
// import 'screens/auth/register_screen.dart';
// import 'screens/main_flow/root_navigator.dart'; // Use this instead
// import 'services/database/user_session_db.dart';
// import 'firebase_options.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const ProviderScope(child: MyApp()));
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Shoppazing Rider App',
//       theme: ThemeData(
//         primaryColor: const Color(0xFF5D8AA8),
//         scaffoldBackgroundColor: Colors.white,
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           titleTextStyle: TextStyle(
//             color: Color(0xFF5D8AA8),
//             fontSize: 20,
//             fontWeight: FontWeight.w500,
//           ),
//           iconTheme: IconThemeData(color: Color(0xFF5D8AA8)),
//         ),
//         bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//           selectedItemColor: Color(0xFF5D8AA8),
//           unselectedItemColor: Colors.grey,
//           type: BottomNavigationBarType.fixed,
//         ),
//         colorScheme: const ColorScheme.light(primary: Color(0xFF5D8AA8)),
//       ),
//       initialRoute: '/',
//       routes: {
//         '/': (context) => const StartupPage(),
//         '/login': (context) => const PhoneNumberScreen(),
//         '/email_login': (context) => const EmailLoginScreen(),
//         '/otp': (context) => const OTPScreen(),
//         '/register': (context) => const RegisterScreen(),
//         '/home': (context) =>
//             const RootNavigatorRiverpod(), // Use RootNavigatorRiverpod
//       },
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class StartupPage extends StatefulWidget {
//   const StartupPage({super.key});

//   @override
//   State<StartupPage> createState() => _StartupPageState();
// }

// class _StartupPageState extends State<StartupPage> {
//   @override
//   void initState() {
//     super.initState();
//     _checkSession();
//   }

//   Future<void> _checkSession() async {
//     print('[DEBUG] Checking session...');

//     final session = await UserSessionDB.getSession();
//     print('[DEBUG] Session exists: ${session != null}');

//     if (!mounted) return;

//     if (session != null) {
//       print('[DEBUG] Has session, going to home');
//       Navigator.pushReplacementNamed(context, '/home');
//     } else {
//       print('[DEBUG] No session, going to login');
//       Navigator.pushReplacementNamed(context, '/login');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(child: CircularProgressIndicator(color: Color(0xFF5D8AA8))),
//     );
//   }
// }
