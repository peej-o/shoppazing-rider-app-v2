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

      if (!mounted) return;

      if (success) {
        print('[DEBUG] Success, navigating to OTP screen');
        Navigator.pushNamed(
          context,
          '/otp',
          arguments: {'phoneNumber': phoneNumber},
        );
      } else {
        print('[DEBUG] Failed to send OTP');
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    const brandBlue = Color(0xFF00509D);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF223044),
        elevation: 0,
        title: const Text(
          'Enter Phone Number',
          style: TextStyle(
            color: Color(0xFF223044),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your mobile number to receive an OTP code.',
                style: TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 35, 40, 48),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixText: '+63 ',
                  counterText: '',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: brandBlue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _loginWithOTP,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: brandBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
