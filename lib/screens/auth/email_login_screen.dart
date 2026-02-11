import 'package:flutter/material.dart';

class EmailLoginScreen extends StatelessWidget {
  const EmailLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Email Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Login with Email',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D8AA8),
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
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
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
