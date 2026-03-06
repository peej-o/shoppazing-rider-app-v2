import 'package:flutter/material.dart';
import '../../services/auth/auth_service.dart';
import '../../services/network/network_service.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreen();
}

class _PhoneNumberScreen extends State<PhoneNumberScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loginWithOTP() async {
    final phoneNumber = _phoneController.text.trim();

    // Validate
    if (phoneNumber.isEmpty) {
      _showError('Please enter your phone number');
      return;
    }

    if (!phoneNumber.startsWith('9') || phoneNumber.length != 10) {
      _showError('Phone number must start with 9 and be 10 digits long');
      return;
    }

    // Check internet
    final hasConnection = await NetworkService.hasInternetConnection();
    if (!hasConnection) {
      NetworkService.showNetworkErrorSnackBar(context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // STEP 1: Check if user exists first
      print('[DEBUG] Checking if user exists: $phoneNumber');
      final userExists = await AuthService.checkUserExists(phoneNumber);

      if (!mounted) return;

      if (!userExists) {
        // User not found, go to registration
        print('[DEBUG] User not found, go to registration');
        setState(() => _isLoading = false);
        Navigator.pushNamed(
          context,
          '/register',
          arguments: {'phoneNumber': phoneNumber},
        );
        return;
      }

      // STEP 2: User exists, send OTP
      print('[DEBUG] User exists, sending OTP');
      final success = await AuthService.requestOTP(phoneNumber);

      print('[DEBUG] requestOTP success: $success'); // Add this

      if (!mounted) return;

      if (success) {
        print('[DEBUG] Success, navigating to OTP screen'); // Add this
        Navigator.pushNamed(
          context,
          '/otp',
          arguments: {'phoneNumber': phoneNumber},
        );
        print('[DEBUG] Navigation called'); // Add this
      } else {
        print('[DEBUG] Failed to send OTP'); // Add this
        _showError('Failed to send OTP. Please try again.');
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _loginWithGmail() {
    // TODO: Implement Google Sign-In
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Sign-In coming soon'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
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

                // Logo
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/shoppazing_logo.jpg',
                        height: 80,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.local_shipping,
                            size: 80,
                            color: Color(0xFF5D8AA8),
                          );
                        },
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

                // Title
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

                // Phone Input
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  enabled: !_isLoading,
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

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _loginWithOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5D8AA8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Continue',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Email Login Link
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

                // Google Sign-In Button
                Center(
                  child: OutlinedButton.icon(
                    onPressed: _loginWithGmail,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      foregroundColor: const Color(0xFF2F4F4F),
                    ),
                    icon: Image.asset(
                      'assets/images/google.png',
                      width: 20,
                      height: 20,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.g_mobiledata, size: 20);
                      },
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
