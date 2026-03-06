import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../api/api_client.dart';
import '../api/api_config.dart';
import '../database/user_session_db.dart';

class DashboardService {
  // Fetch dashboard data (balance, ongoing, earnings, completed)
  static Future<Map<String, dynamic>> fetchDashboardData() async {
    try {
      final session = await UserSessionDB.getSession();
      final userId = session?['user_id'] ?? '';

      if (userId.isEmpty) {
        throw Exception('User not logged in');
      }

      final url = ApiConfig.apiUri('/getriderdashboard');
      final response = await ApiClient.post(
        url,
        body: jsonEncode({'UserId': userId}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        return {
          'balance': (data['LoadBalance'] is num)
              ? (data['LoadBalance'] as num).toDouble()
              : double.tryParse(data['LoadBalance']?.toString() ?? '0') ?? 0.0,
          'ongoing': (data['OnGoing'] is int)
              ? data['OnGoing'] as int
              : int.tryParse(data['OnGoing']?.toString() ?? '0') ?? 0,
          'earnings': (data['Earnings'] is num)
              ? (data['Earnings'] as num).toDouble()
              : double.tryParse(data['Earnings']?.toString() ?? '0') ?? 0.0,
          'completed': (data['Completed'] is int)
              ? data['Completed'] as int
              : int.tryParse(data['Completed']?.toString() ?? '0') ?? 0,
        };
      } else {
        throw Exception(
          'Failed to load dashboard data: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('[ERROR] DashboardService.fetchDashboardData: $e');
      rethrow;
    }
  }

  // Post load to rider wallet (top up)
  static Future<Map<String, dynamic>> postLoadRiderWallet({
    required String riderId,
    required int amount,
  }) async {
    try {
      final url = ApiConfig.apiUri('/PostLoadRiderWallet');
      final response = await ApiClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'RiderId': riderId,
          'IsCredit': true,
          'Amount': amount,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to post load: ${response.body}');
      }
    } catch (e) {
      debugPrint('[ERROR] DashboardService.postLoadRiderWallet: $e');
      rethrow;
    }
  }

  // Get load transactions
  static Future<List<dynamic>> getLoadTransactions() async {
    try {
      final session = await UserSessionDB.getSession();
      final userId = session?['user_id'] ?? '';

      if (userId.isEmpty) {
        throw Exception('User not logged in');
      }

      final url = ApiConfig.apiUri('/getriderloadtrans');
      final response = await ApiClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'UserId': userId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedResponse = jsonDecode(response.body);

        // Handle different response formats
        if (decodedResponse is Map &&
            decodedResponse.containsKey('LoadWallets')) {
          return decodedResponse['LoadWallets'] as List;
        } else if (decodedResponse is List) {
          return decodedResponse;
        } else if (decodedResponse is Map) {
          return [decodedResponse];
        } else {
          return [];
        }
      } else {
        throw Exception(
          'Failed to get load transactions: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('[ERROR] DashboardService.getLoadTransactions: $e');
      rethrow;
    }
  }

  // Check load status
  static Future<Map<String, dynamic>> checkLoadStatus({
    required String loadRefNo,
    required String riderId,
  }) async {
    try {
      final url = ApiConfig.apiUri('/postCheckRiderLoadStatus');
      final response = await ApiClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'LoadRefNo': loadRefNo, 'RiderId': riderId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to check load status: ${response.body}');
      }
    } catch (e) {
      debugPrint('[ERROR] DashboardService.checkLoadStatus: $e');
      rethrow;
    }
  }

  // Build payment URL for GCash
  static String buildPaymentUrl({
    required int amount,
    required String mobileNo,
    required String email,
    required String loadRefNo,
  }) {
    return '${ApiConfig.paymentStartLoadPurchase}?Id=16&PROC_ID=GCSH&amount=$amount&PhoneNumber=$mobileNo&email=$email&LoadRefNo=$loadRefNo';
  }
}
