import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../services/auth/auth_service.dart';
import '../../services/network/network_service.dart';
import '../../services/database/user_session_db.dart';
import '../../services/api/api_client.dart';
import '../../services/api/api_config.dart';
import 'dart:convert';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  bool _isLoading = false;
  String? _phoneNumber;
  bool _isInitialized = false;
  String _otp = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _phoneNumber = args['phoneNumber'] as String?;
      }
      _isInitialized = true;
    }
  }

  Future<void> _verifyOTP() async {
    if (_otp.length != 6) {
      _showError('Please enter complete OTP');
      return;
    }

    if (_phoneNumber == null) {
      _showError('Phone number not found');
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
      // Format phone number exactly like riderV1
      String formattedPhone = _phoneNumber!;
      final m = formattedPhone.replaceAll(RegExp(r'[^0-9]'), '');
      if (m.startsWith('0') && m.length == 11) {
        formattedPhone = '63${m.substring(1)}';
      } else if (m.length == 10 && m.startsWith('9')) {
        formattedPhone = '63$m';
      } else if (m.startsWith('63')) {
        formattedPhone = m;
      }

      print('[DEBUG] Verifying OTP for: $formattedPhone');
      print('[DEBUG] OTP entered: $_otp');

      final response = await ApiClient.post(
        ApiConfig.apiUri('/verifyotplogin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'OTP': _otp,
          'MobileNo': formattedPhone,
          'UserId': '',
          'issuer': 'com.byteswiz.shoppazing',
          'audience': 'ShoppaZing',
          'encryptedSecretKey': 'rOUiWiiqxr6Ot/5K03uLleWNBQutrIAwjPnyHeTP/rc=',
        }),
        skipAuth: true,
      );

      print('[DEBUG] Verify response status: ${response.statusCode}');
      print('[DEBUG] Verify response body: ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Check if user not found (status_code 3)
        if (data['status_code'] == 3 &&
            data['message']?.toString().toLowerCase().contains(
                  'no user found',
                ) ==
                true) {
          Navigator.pushReplacementNamed(
            context,
            '/register',
            arguments: {'phoneNumber': _phoneNumber},
          );
          return;
        }

        // Check if OTP verification successful (status_code 200)
        if (data['status_code'] == 200) {
          // Get role name - check both root and UserGoogleAuthModel
          String roleName = data['RoleName']?.toString() ?? '';
          if (roleName.isEmpty) {
            final userModel = data['UserGoogleAuthModel'] as Map?;
            roleName = userModel?['RoleName']?.toString() ?? '';
          }

          print('[DEBUG] User role: $roleName');

          // Check if user has CUSTOMER role - restrict login
          if (roleName.toUpperCase() == 'CUSTOMER') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Customer accounts cannot login as riders. Please contact support.',
                ),
                backgroundColor: Colors.red,
              ),
            );
            setState(() => _isLoading = false);
            return;
          }

          // Save session from response
          await _saveSessionFromResponse(data, formattedPhone);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful!'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacementNamed(context, '/home');
        } else {
          _showError(data['message'] ?? 'Invalid OTP. Please try again.');
        }
      } else {
        _showError('Server error. Please try again.');
      }
    } catch (e) {
      print('[ERROR] Verify OTP error: $e');
      _showError('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveSessionFromResponse(
    Map<String, dynamic> data,
    String mobileNo,
  ) async {
    try {
      // Get role from UserGoogleAuthModel if needed
      String roleName = data['RoleName']?.toString() ?? '';
      if (roleName.isEmpty) {
        final userModel = data['UserGoogleAuthModel'] as Map?;
        roleName = userModel?['RoleName']?.toString() ?? '';
      }

      String riderId = data['RiderId']?.toString() ?? '';
      if (riderId.isEmpty) {
        final userModel = data['UserGoogleAuthModel'] as Map?;
        riderId = userModel?['RiderId']?.toString() ?? '';
      }

      // Get bearer token - could be in different formats
      String accessToken = '';
      if (data['BearerToken'] is Map) {
        accessToken = data['BearerToken']['access_token']?.toString() ?? '';
      } else if (data['BearerToken'] is String) {
        accessToken = data['BearerToken'];
      } else {
        accessToken = data['access_token']?.toString() ?? '';
      }

      await UserSessionDB.saveSession(
        accessToken: accessToken,
        tokenType: 'bearer',
        expiresIn: data['expires_in'] ?? 3600,
        email: data['Email'] ?? '',
        businessName: '',
        merchantId: '',
        userId: data['UserId'] ?? '',
        firstname: data['FirstName'] ?? '',
        lastname: data['LastName'] ?? '',
        mobileNo: mobileNo,
        mobileConfirmed: 'true',
        riderId: riderId,
        roleName: roleName,
      );

      print('[DEBUG] Session saved successfully');
    } catch (e) {
      print('[ERROR] Error saving session: $e');
    }
  }

  Future<void> _resendOTP() async {
    if (_phoneNumber == null) {
      _showError('Phone number not found');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await AuthService.requestOTP(_phoneNumber!);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP resent successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showError('Failed to resend OTP');
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

  String _formatPhoneNumber(String? number) {
    if (number == null || number.isEmpty) return '••• ••• ••••';
    if (number.length == 10) {
      return '${number.substring(0, 3)} ${number.substring(3, 6)} ${number.substring(6)}';
    }
    return number;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF5D8AA8),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Title
              const Text(
                'Enter Verification Code',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D8AA8),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Subtitle with phone number
              Text(
                'We sent a code to +63 ${_formatPhoneNumber(_phoneNumber)}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // OTP Input
              PinCodeTextField(
                appContext: context,
                length: 6,
                obscureText: false,
                animationType: AnimationType.fade,
                enabled: !_isLoading,
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

              // Resend Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive code? ",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : _resendOTP,
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

              // Verify Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
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
                      : const Text('Verify', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
