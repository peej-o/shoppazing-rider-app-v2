import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api/api_config.dart';
import '../database/user_session_db.dart';
import '../api/api_client.dart';

class AuthService {
  // Login with phone number (request OTP)
  static Future<bool> requestOTP(String phoneNumber) async {
    try {
      // Format phone number (add 63 prefix)
      final formattedPhone = '63$phoneNumber';

      print('[DEBUG] Requesting OTP for: $formattedPhone');

      // Try both endpoints
      final endpoints = [
        '/sendotp', // shop/sendotp
        '/loginbyotp', // alternative
      ];

      for (final endpoint in endpoints) {
        try {
          print('[DEBUG] Trying endpoint: $endpoint');
          final response = await ApiClient.post(
            ApiConfig.apiUri(endpoint),
            body: jsonEncode({'MobileNo': formattedPhone}),
            skipAuth: true,
          );

          print('[DEBUG] Response status: ${response.statusCode}');

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            print('[DEBUG] Response data: $data');

            // Check different response formats
            if (data['status_code'] == 200 || data['StatusCode'] == 200) {
              return true;
            }
          }
        } catch (e) {
          print('[DEBUG] Endpoint $endpoint failed: $e');
          continue;
        }
      }

      return false;
    } catch (e) {
      print('[ERROR] requestOTP: $e');
      return false;
    }
  }

  // Verify OTP and login
  static Future<bool> verifyOTP(String otp, String phoneNumber) async {
    try {
      final formattedPhone = '63$phoneNumber';

      print('[DEBUG] Verifying OTP for: $formattedPhone');

      final response = await ApiClient.post(
        ApiConfig.apiUri('/verifyotplogin'),
        body: jsonEncode({
          'OTP': otp,
          'MobileNo': formattedPhone,
          'UserId': '',
        }),
        skipAuth: true,
      );

      print('[DEBUG] Verify response: ${response.statusCode}');
      print('[DEBUG] Verify body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if OTP is valid
        if (data['status_code'] == 200) {
          // Check if user needs to register
          if (data['message']?.toString().contains('register') == true) {
            // Navigate to registration
            return false; // Will handle in UI
          }

          // Save session
          await _saveSessionFromResponse(data, formattedPhone);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('[ERROR] verifyOTP: $e');
      return false;
    }
  }

  // Check if user exists
  static Future<bool> checkUserExists(String phoneNumber) async {
    try {
      final formattedPhone = '63$phoneNumber';

      final response = await ApiClient.post(
        ApiConfig.apiUri('/verifyotplogin'),
        body: jsonEncode({'OTP': '', 'MobileNo': formattedPhone, 'UserId': ''}),
        skipAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // If status_code is 403, user exists (invalid OTP but user found)
        return data['status_code'] == 403;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Login with email/password
  static Future<bool> loginWithEmail(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.tokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'password',
          'username': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if user has CUSTOMER role
        if (data['RoleName']?.toString().toUpperCase() == 'CUSTOMER') {
          return false;
        }

        await _saveSessionFromToken(data);
        return true;
      }
      return false;
    } catch (e) {
      print('[ERROR] loginWithEmail: $e');
      return false;
    }
  }

  // Save session from OTP response
  static Future<void> _saveSessionFromResponse(
    Map<String, dynamic> data,
    String mobileNo,
  ) async {
    await UserSessionDB.saveSession(
      accessToken:
          data['access_token'] ?? data['BearerToken']?['access_token'] ?? '',
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
      riderId: data['RiderId'] ?? '',
      roleName: data['RoleName'] ?? 'RIDER',
    );
  }

  // Save session from token response
  static Future<void> _saveSessionFromToken(Map<String, dynamic> data) async {
    await UserSessionDB.saveSession(
      accessToken: data['access_token'],
      tokenType: data['token_type'],
      expiresIn: data['expires_in'],
      email: data['userName'],
      businessName: data['BusinessName'] ?? '',
      merchantId: data['MerchantId'] ?? '',
      userId: data['UserId'],
      firstname: data['Firstname'] ?? '',
      lastname: data['Lastname'] ?? '',
      mobileNo: data['PhoneNumber'] ?? '',
      mobileConfirmed: data['PhoneNumberConfirmed'] ?? 'false',
      riderId: data['RiderId'] ?? '',
      roleName: data['RoleName'] ?? 'RIDER',
    );
  }

  // Logout
  static Future<void> logout() async {
    await UserSessionDB.clearSession();
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final session = await UserSessionDB.getSession();
    return session != null;
  }
}
