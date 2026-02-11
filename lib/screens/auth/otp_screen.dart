import 'package:flutter/material.dart';

class OTPScreen extends StatelessWidget {
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter Verification Code',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D8AA8),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'We sent a code to your phone',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            TextField(
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'OTP Code',
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Will add later
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D8AA8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 16,
                ),
              ),
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
