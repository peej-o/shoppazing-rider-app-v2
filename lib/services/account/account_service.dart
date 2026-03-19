import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../api/api_client.dart';
import '../api/api_config.dart';
import '../database/user_session_db.dart';

class AccountService {
  // Get rider information
  static Future<Map<String, dynamic>> getRiderInfo() async {
    try {
      final session = await UserSessionDB.getSession();
      final userId = session?['user_id'] ?? '';

      if (userId.isEmpty) {
        throw Exception('User not logged in');
      }

      final url = ApiConfig.apiUri('/GetRiderInfo');
      final response = await ApiClient.post(
        url,
        body: jsonEncode({'UserId': userId}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic> && data['status_code'] == 200) {
          return data;
        } else {
          throw Exception('Failed to get rider info: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load rider info: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[ERROR] AccountService.getRiderInfo: $e');
      rethrow;
    }
  }

  // Update rider profile
  static Future<bool> updateRiderProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      final session = await UserSessionDB.getSession();
      final token = session?['access_token']?.toString();

      if (token == null || token.isEmpty) {
        throw Exception('No auth token');
      }

      // This will be used with MultipartRequest for images
      // For now, we'll just return true for mock
      return true;
    } catch (e) {
      debugPrint('[ERROR] AccountService.updateRiderProfile: $e');
      rethrow;
    }
  }

  // Get profile image URL
  static String getProfileImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';

    final normalized = imagePath.replaceAll(r'\', '/');
    final base = ApiConfig.baseOrigin.endsWith('/')
        ? ApiConfig.baseOrigin
        : '${ApiConfig.baseOrigin}/';

    return "${base}api/${normalized.startsWith('/') ? normalized.substring(1) : normalized}";
  }

  // Check if account is activated
  static bool isAccountActivated(Map<String, dynamic>? riderInfo) {
    return riderInfo?['IsAccountActivated'] == true;
  }

  // Format address
  static String formatAddress(Map<String, dynamic>? riderInfo) {
    if (riderInfo == null) return '';

    final addressLine1 = riderInfo['AddressLine1']?.toString() ?? '';
    final addressLine2 = riderInfo['AddressLine2']?.toString() ?? '';
    return '$addressLine1 $addressLine2'.trim();
  }
}
