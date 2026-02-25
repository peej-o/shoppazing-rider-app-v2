import 'package:flutter/material.dart';
import '/services/google_signin_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController controller = TextEditingController();
  bool isLoading = false;

  void _loginWithOTP() {
    final phoneNumber = controller.text.trim();

    // Check if empty
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    // Check if starts with 9 AND is exactly 10 digits
    if (!phoneNumber.startsWith('9') || phoneNumber.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number must start with 9 and be 10 digits long'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Format the number for API (add 63 prefix)
    final formattedPhoneNumber = '+63$phoneNumber';

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });

      // Navigate to OTP screen WITH the phone number
      Navigator.pushNamed(
        context,
        '/otp',
        arguments: {'mobileNo': formattedPhoneNumber}, // <- Important ito!
      );
    });
  }

  void _loginWithGmail() async {
    setState(() {
      isLoading = true;
    });

    try {
      final googleService = GoogleSignInService();
      final result = await googleService.signInWithGoogle();

      setState(() {
        isLoading = false;
      });

      if (result.success) {
        // Success! May user data na tayo
        print('Google Sign-In Success!');
        print('Email: ${result.userData?.email}');
        print('Name: ${result.userData?.displayName}');

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Sign-In successful!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to home or registration kung incomplete profile
        // For now, diretso muna sa home
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // May error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Google Sign-In failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/shoppazing_logo.jpg', // Using the root assets file
                        height: 80,
                        errorBuilder: (context, error, stackTrace) {
                          // If image fails, show the icon as fallback
                          return const Icon(
                            Icons.local_shipping,
                            size: 80,
                            color: Color(0xFF5D8AA8),
                          );
                        },
                      ),

                      // Replace with:
                      const SizedBox(height: 16),
                      const Text(
                        'Shoppazing Rider App',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF5D8AA8),
                        ),
                      ),
                      const Text(
                        'Your trusted delivery partner',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Enter your phone number',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D8AA8),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'We will send you a verification code',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixText: '+63 ',
                    counterText: '',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF5D8AA8)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _loginWithOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5D8AA8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Continue'),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/email_login');
                    },
                    child: const Text(
                      'Login with Email',
                      style: TextStyle(
                        color: Color(0xFF5D8AA8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: _loginWithGmail,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide.none, // CHANGED: No border
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      foregroundColor: const Color(0xFF2F4F4F),
                    ),
                    icon: Image.asset(
                      'assets/images/google.png',
                      width: 20,
                      height: 20,
                    ),
                    label: const Text('Sign in with Google'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
