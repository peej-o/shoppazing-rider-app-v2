import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api/api_config.dart';
import '../database/user_session_db.dart';
import '../api/api_client.dart';

class AuthService {
  // Login with phone number (request OTP)
  static Future<bool> requestOTP(String phoneNumber) async {
    try {
      final formattedPhone = '63$phoneNumber';

      print('[DEBUG] Requesting OTP for: $formattedPhone');
      print('[DEBUG] URL: ${ApiConfig.apiUri('/sendotp')}');

      final response = await ApiClient.post(
        ApiConfig.apiUri('/sendotp'),
        body: jsonEncode({'MobileNo': formattedPhone}),
        skipAuth: true,
      );

      print('[DEBUG] Response status: ${response.statusCode}');
      print('[DEBUG] Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Add these prints
        print('[DEBUG] data["status_code"]: ${data['status_code']}');
        print(
          '[DEBUG] data["status_code"] == 200: ${data['status_code'] == 200}',
        );

        return data['status_code'] == 200;
      }

      print('[DEBUG] Response status not 200/201: ${response.statusCode}');
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
      print('[DEBUG] OTP entered: $otp');

      final response = await ApiClient.post(
        ApiConfig.apiUri('/verifyotplogin'),
        body: jsonEncode({
          'OTP': otp,
          'MobileNo': formattedPhone,
          'UserId': '',
          'issuer': 'com.byteswiz.shoppazing', // Add these from riderV1
          'audience': 'ShoppaZing',
          'encryptedSecretKey': 'rOUiWiiqxr6Ot/5K03uLleWNBQutrIAwjPnyHeTP/rc=',
        }),
        skipAuth: true,
      );

      print('[DEBUG] Verify response: ${response.statusCode}');
      print('[DEBUG] Verify body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status_code'] == 200) {
          // Extract token from BearerToken object
          if (data['BearerToken'] != null) {
            await _saveSessionFromResponse(data['BearerToken'], formattedPhone);
          } else {
            await _saveSessionFromResponse(data, formattedPhone);
          }
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

      print('[DEBUG] Checking if user exists: $formattedPhone');
      print('[DEBUG] URL: ${ApiConfig.apiUri('/verifyotplogin')}');

      final response = await ApiClient.post(
        ApiConfig.apiUri('/verifyotplogin'),
        body: jsonEncode({'OTP': '', 'MobileNo': formattedPhone, 'UserId': ''}),
        skipAuth: true,
      );

      print('[DEBUG] Check user response status: ${response.statusCode}');
      print('[DEBUG] Check user response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Include 201
        final data = jsonDecode(response.body);

        // Status code 403 means user exists (invalid OTP)
        if (data['status_code'] == 403) {
          print('[DEBUG] User exists (status_code 403)');
          return true;
        }

        // Status code 1 means user exists (from registration response)
        if (data['status_code'] == 1) {
          print('[DEBUG] User exists (status_code 1)');
          return true;
        }

        // Check if we got UserId (another indicator of existing user)
        if (data['UserId'] != null && data['UserId'].toString().isNotEmpty) {
          print('[DEBUG] User exists (has UserId)');
          return true;
        }

        print('[DEBUG] User does not exist');
        return false;
      }

      return false;
    } catch (e) {
      print('[ERROR] checkUserExists: $e');
      return false;
    }
  }

  // Register new user
  static Future<bool> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final formattedPhone = '63$phoneNumber';

      final registrationData = {
        'Email': email,
        'Firstname': firstName,
        'Lastname': lastName,
        'MobileNo': formattedPhone,
        'Password': password,
        'RoleName': 'RIDER',
      };

      print('[DEBUG] Registering user: $registrationData');
      print('[DEBUG] URL: ${ApiConfig.apiUri('/registeruser')}');

      final response = await ApiClient.post(
        ApiConfig.apiUri('/registeruser'),
        body: jsonEncode(registrationData),
        headers: {'Content-Type': 'application/json'},
        skipAuth: true,
      );

      print('[DEBUG] Registration response: ${response.statusCode}');
      print('[DEBUG] Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Check different success indicators
        if (data['status_code'] == 200 || data['StatusCode'] == 200) {
          print('[DEBUG] Registration successful');
          return true;
        } else if (data['status_code'] == 1) {
          print('[DEBUG] User already exists');
          return false;
        } else {
          print(
            '[DEBUG] Registration failed with status: ${data['status_code']}',
          );
          return false;
        }
      }
      return false;
    } catch (e) {
      print('[ERROR] registerUser: $e');
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

      print('[DEBUG] Email login response: ${response.statusCode}');
      print('[DEBUG] Email login body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if user has CUSTOMER role
        final roleName = data['RoleName']?.toString() ?? '';
        if (roleName.toUpperCase() == 'CUSTOMER') {
          print('[DEBUG] Customer accounts cannot login as riders');
          return false;
        }

        // Save session
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
