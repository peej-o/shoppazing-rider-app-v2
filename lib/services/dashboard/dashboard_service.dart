import 'dart:convert';
import '../api/api_client.dart';
import '../api/api_config.dart';
import '../database/user_session_db.dart';

class DashboardService {
  // Fetch dashboard data from API
  static Future<Map<String, dynamic>> fetchDashboardData() async {
    try {
      final session = await UserSessionDB.getSession();
      final userId = session?['user_id'] ?? '';

      if (userId.isEmpty) {
        throw Exception('User not logged in');
      }

      print('[DEBUG] Fetching dashboard for userId: $userId');

      final url = ApiConfig.apiUri('/getriderdashboard');
      final body = {'UserId': userId};

      final response = await ApiClient.post(
        url,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      print('[DEBUG] Dashboard response status: ${response.statusCode}');
      print('[DEBUG] Dashboard response body: ${response.body}');

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
        throw Exception('Failed to load dashboard: ${response.statusCode}');
      }
    } catch (e) {
      print('[ERROR] fetchDashboardData: $e');
      rethrow;
    }
  }

  // Get load transactions
  static Future<List<Map<String, dynamic>>> getLoadTransactions() async {
    try {
      final session = await UserSessionDB.getSession();
      final userId = session?['user_id'] ?? '';

      if (userId.isEmpty) {
        throw Exception('User not logged in');
      }

      print('[DEBUG] Fetching transactions for userId: $userId');

      final url = ApiConfig.apiUri('/getriderloadtrans');
      final body = {'UserId': userId};

      final response = await ApiClient.post(
        url,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      print('[DEBUG] Transactions response status: ${response.statusCode}');
      print('[DEBUG] Transactions response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Handle different response formats
        List<Map<String, dynamic>> transactions = [];

        if (data is Map && data.containsKey('LoadWallets')) {
          final loadWallets = data['LoadWallets'];
          if (loadWallets is List) {
            transactions = loadWallets.map((tx) {
              return {
                'referenceNo':
                    tx['ReferrenceNo'] ??
                    tx['ReferenceNo'] ??
                    tx['referenceNo'] ??
                    '',
                'amount': (tx['Amount'] ?? tx['amount'] ?? 0).toDouble(),
                'date':
                    tx['DateLoaded'] ??
                    tx['dateLoaded'] ??
                    DateTime.now().toString(),
                'remarks': tx['Remarks'] ?? tx['remarks'] ?? 'Load purchase',
                'isConfirmed': tx['IsConfirmed'] ?? tx['isConfirmed'] ?? false,
              };
            }).toList();
          }
        } else if (data is List) {
          transactions = data.map((tx) {
            return {
              'referenceNo':
                  tx['ReferrenceNo'] ??
                  tx['ReferenceNo'] ??
                  tx['referenceNo'] ??
                  '',
              'amount': (tx['Amount'] ?? tx['amount'] ?? 0).toDouble(),
              'date':
                  tx['DateLoaded'] ??
                  tx['dateLoaded'] ??
                  DateTime.now().toString(),
              'remarks': tx['Remarks'] ?? tx['remarks'] ?? 'Load purchase',
              'isConfirmed': tx['IsConfirmed'] ?? tx['isConfirmed'] ?? false,
            };
          }).toList();
        }

        // Sort by date descending
        transactions.sort((a, b) => b['date'].compareTo(a['date']));

        print('[DEBUG] Found ${transactions.length} transactions');
        return transactions;
      } else {
        throw Exception('Failed to load transactions: ${response.statusCode}');
      }
    } catch (e) {
      print('[ERROR] getLoadTransactions: $e');
      return [];
    }
  }
}
