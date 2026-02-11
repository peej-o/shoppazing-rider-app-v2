import 'package:flutter/material.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController controller = TextEditingController();
  bool isLoading = false;

  void _loginWithOTP() {
    // Add validation
    if (controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone number')),
      );
      return;
    }

    if (controller.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid 10-digit number')),
      );
      return;
    }

    // Navigate to OTP screen
    Navigator.pushNamed(context, '/otp');
  }

  void _loginWithGmail() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Google Sign-In coming soon')));
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
                      // Using Icon temporarily
                      const Icon(
                        Icons.local_shipping,
                        size: 80,
                        color: Color(0xFF5D8AA8),
                      ),
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
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      foregroundColor: const Color(0xFF2F4F4F),
                    ),
                    icon: const Icon(Icons.g_mobiledata, size: 20),
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
