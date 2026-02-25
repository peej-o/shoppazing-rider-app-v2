import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart'; // Don't forget to import!

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  // Controller for the OTP input
  final TextEditingController otpController = TextEditingController();

  // Track loading state
  bool isLoading = false;

  // Store the phone number passed from registration screen
  String? mobileNo;

  // Track if screen is initialized
  bool _isInitialized = false;

  // Store the OTP value
  String _otp = '';

  @override
  void initState() {
    super.initState();
    // We'll get arguments in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only run once
    if (!_isInitialized) {
      // Get the phone number passed from registration screen
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final passedMobile = args != null ? args['mobileNo'] as String? : null;

      setState(() {
        mobileNo = passedMobile;
      });

      _isInitialized = true;

      print('Received mobile number: $mobileNo'); // For debugging
    }
  }

  void _verifyOTP() {
    final otp = _otp; // Get OTP from pin code field

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter complete OTP')),
      );
      return;
    }

    setState(() => isLoading = true);

    // Simulate verification
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => isLoading = false);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP Verified Successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to home
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  void _resendOTP() {
    setState(() => isLoading = true);

    // Simulate resending OTP
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP resent successfully'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              const Text(
                'Enter OTP',
                style: TextStyle(
                  color: Color(0xFF5D8AA8),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Phone number display
              Text(
                'We sent a code to ${mobileNo ?? '••• ••• ••••'}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 32),

              // Pin code field - this is the 6-digit input
              PinCodeTextField(
                appContext: context,
                length: 6,
                obscureText: false,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(8),
                  fieldHeight: 60,
                  fieldWidth: 50,
                  activeFillColor: Colors.white,
                  selectedFillColor: Colors.white,
                  inactiveFillColor: Colors.white,
                  activeColor: const Color(0xFF5D8AA8),
                  selectedColor: const Color(0xFF5D8AA8),
                  inactiveColor: Colors.grey,
                ),
                animationDuration: const Duration(milliseconds: 300),
                backgroundColor: Colors.white,
                enableActiveFill: true,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _otp = value;
                  });
                },
                onCompleted: (value) {
                  _otp = value;
                },
              ),
              const SizedBox(height: 24),

              // Resend row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive code? ",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: isLoading ? null : _resendOTP,
                    child: const Text(
                      'Resend OTP',
                      style: TextStyle(
                        color: Color(0xFF5D8AA8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Verify button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D8AA8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isLoading ? null : _verifyOTP,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Validate'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
