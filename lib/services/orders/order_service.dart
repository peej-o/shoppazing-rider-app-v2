import 'dart:convert';
import '../api/api_client.dart';
import '../api/api_config.dart';
import '../database/user_session_db.dart';
import '../../models/entities/order.dart';

// Result class for order actions - MOVE OUTSIDE the class
class OrderActionResult {
  final bool success;
  final String? message;

  OrderActionResult({required this.success, this.message});
}

class OrderService {
  // Toggle this to switch between MOCK and REAL API
  static const bool _useMockData = true; // Set to false to use real API

  // DEBUG: Set this to true to see detailed logs
  static const bool _debugMode = false;

  // DEBUG: Separate toggle for fetch orders (to reduce flooding)
  static const bool _debugFetchOrders = false;

  // Rate limiting for fetch orders
  static DateTime? _lastRefreshTime;
  static const Duration _minRefreshInterval = Duration(seconds: 5);

  // Fetch orders from API
  static Future<List<OrderData>> fetchOrders({
    required int riderId,
    double? lat,
    double? lng,
    bool forceRefresh = false,
  }) async {
    // Rate limiting - don't refresh more than every 5 seconds
    if (!forceRefresh && _lastRefreshTime != null) {
      final elapsed = DateTime.now().difference(_lastRefreshTime!);
      if (elapsed < _minRefreshInterval) {
        if (_debugFetchOrders) {
          print(
            '[DEBUG] Skipping refresh - too soon (${elapsed.inMilliseconds}ms)',
          );
        }
        return [];
      }
    }
    _lastRefreshTime = DateTime.now();

    // MOCK DATA FOR TESTING
    if (_useMockData) {
      if (_debugFetchOrders) print('[MOCK] Using mock order data');
      return _getMockOrders();
    }

    // REAL API CALL
    try {
      final session = await UserSessionDB.getSession();

      if (_debugFetchOrders) {
        print('[DEBUG] Session exists: ${session != null}');
        print('[DEBUG] RiderId: $riderId');
        print('[DEBUG] Lat: ${lat ?? 0}, Lng: ${lng ?? 0}');
      }

      final url = ApiConfig.apiUri('/getriderorders');
      final body = {'Lat': lat ?? 0, 'Lng': lng ?? 0, 'RiderId': riderId};

      if (_debugFetchOrders) {
        print('[DEBUG] URL: $url');
        print('[DEBUG] Request body: $body');
      }

      final response = await ApiClient.post(
        url,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      if (_debugFetchOrders) {
        print('[DEBUG] Response status: ${response.statusCode}');
        if (response.body.length > 500) {
          print('[DEBUG] Response body: ${response.body.substring(0, 500)}...');
        } else {
          print('[DEBUG] Response body: ${response.body}');
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data is Map && data['OrderHeaders'] is List) {
          final orders = (data['OrderHeaders'] as List)
              .map<OrderData>((json) => OrderData.fromJson(json))
              .toList();

          if (_debugFetchOrders) {
            print('[DEBUG] Found ${orders.length} orders');
          }
          return orders;
        }
      }
      return [];
    } catch (e) {
      if (_debugFetchOrders) {
        print('[ERROR] fetchOrders exception: $e');
      }
      return [];
    }
  }

  // MOCK ORDERS DATA
  static List<OrderData> _getMockOrders() {
    return [
      // Pending order (can be accepted)
      OrderData(
        serverHeaderId: 123451,
        orderNumber: '123451',
        status: '1',
        dateTimeCreated: '14:30',
        storeName: 'Mang Inasal',
        storeImageUrl: '',
        storeAddress: 'SM Mall, Manila',
        customerName: 'Juan Dela Cruz',
        customerAddress: '123 Main St, Manila',
        customerMobileNo: '09123456789',
        storeLat: 14.5995,
        storeLng: 120.9842,
        customerLat: 14.5895,
        customerLng: 120.9942,
        deliveryFee: 50.0,
        onlineServiceCharge: 15.0,
        subTotal: 350.0,
        totalDue: '415.00',
        rawDetails: [
          {'ItemName': 'Chicken Inasal', 'Qty': 2, 'UnitPrice': 150.0},
          {'ItemName': 'Rice', 'Qty': 2, 'UnitPrice': 25.0},
        ],
        OtherChatUserFirebaseUID: 'customer_123_uid',
        OtherChatUserName: 'Juan Dela Cruz',
        OtherChatUserId: 'user_123',
        isPaid: true,
      ),

      // Ready for pickup order
      OrderData(
        serverHeaderId: 33333,
        orderNumber: '33333',
        status: '4',
        dateTimeCreated: '13:30',
        storeName: 'Starbucks',
        storeImageUrl: '',
        storeAddress: 'BGC, Taguig',
        customerName: 'Mike Reyes',
        customerAddress: '123 BGC, Taguig',
        customerMobileNo: '09678901234',
        storeLat: 14.5505,
        storeLng: 121.0552,
        customerLat: 14.5405,
        customerLng: 121.0452,
        deliveryFee: 45.0,
        onlineServiceCharge: 12.0,
        subTotal: 320.0,
        totalDue: '377.00',
        rawDetails: [
          {'ItemName': 'Caramel Macchiato', 'Qty': 1, 'UnitPrice': 180.0},
          {'ItemName': 'Blueberry Muffin', 'Qty': 2, 'UnitPrice': 70.0},
        ],
        OtherChatUserFirebaseUID: 'customer_333_uid',
        OtherChatUserName: 'Mike Reyes',
        OtherChatUserId: 'user_333',
        isPaid: true,
      ),

      // In Transit order (can be delivered)
      OrderData(
        serverHeaderId: 55555,
        orderNumber: '55555',
        status: '6',
        dateTimeCreated: '16:30',
        storeName: 'Chowking',
        storeImageUrl: '',
        storeAddress: 'Festival Mall, Alabang',
        customerName: 'Karen Lopez',
        customerAddress: '789 Rose St, Muntinlupa',
        customerMobileNo: '09567890123',
        storeLat: 14.4195,
        storeLng: 121.0442,
        customerLat: 14.4295,
        customerLng: 121.0542,
        deliveryFee: 70.0,
        onlineServiceCharge: 18.0,
        subTotal: 450.0,
        totalDue: '538.00',
        rawDetails: [
          {'ItemName': 'Chao Fan', 'Qty': 2, 'UnitPrice': 120.0},
          {'ItemName': 'Pork Siomai', 'Qty': 1, 'UnitPrice': 150.0},
          {'ItemName': 'Lauriat', 'Qty': 1, 'UnitPrice': 180.0},
        ],
        OtherChatUserFirebaseUID: 'customer_555_uid',
        OtherChatUserName: 'Karen Lopez',
        OtherChatUserId: 'user_555',
        isPaid: true,
      ),

      // Preparing order (can be cancelled)
      OrderData(
        serverHeaderId: 67890,
        orderNumber: '67890',
        status: '3',
        dateTimeCreated: '15:45',
        storeName: 'Jollibee',
        storeImageUrl: '',
        storeAddress: 'Gateway Mall, Quezon City',
        customerName: 'Maria Santos',
        customerAddress: '456 Elm St, Quezon City',
        customerMobileNo: '09876543210',
        storeLat: 14.6095,
        storeLng: 121.0242,
        customerLat: 14.6195,
        customerLng: 121.0342,
        deliveryFee: 65.0,
        onlineServiceCharge: 20.0,
        subTotal: 420.0,
        totalDue: '505.00',
        rawDetails: [
          {'ItemName': 'Chickenjoy Bucket', 'Qty': 1, 'UnitPrice': 300.0},
          {'ItemName': 'Jolly Spaghetti', 'Qty': 2, 'UnitPrice': 60.0},
        ],
        OtherChatUserFirebaseUID: 'customer_678_uid',
        OtherChatUserName: 'Maria Santos',
        OtherChatUserId: 'user_678',
        isPaid: false,
      ),
    ];
  }

  // Accept order
  static Future<OrderActionResult> acceptOrder(OrderData order) async {
    if (_useMockData) {
      print('[MOCK] Accepting order: ${order.orderNumber}');
      await Future.delayed(const Duration(seconds: 1));
      return OrderActionResult(
        success: true,
        message: 'Order accepted! Ready for pickup.',
      );
    }

    try {
      final session = await UserSessionDB.getSession();
      final userId = session?['user_id'] ?? '';

      final url = ApiConfig.apiUri('/postacceptriderorder');
      final body = {
        'OrderHeaderId': order.serverHeaderId,
        'OrderNo': order.orderNumber,
        'UserId': userId,
        'TotalAmount':
            order.subTotal + order.onlineServiceCharge + order.deliveryFee,
      };

      print('[DEBUG] Accepting order: $body');

      final response = await ApiClient.post(
        url,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      print('[DEBUG] Accept response: ${response.statusCode}');
      print('[DEBUG] Accept body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final statusCode = data['status_code'];
        final message = data['message']?.toString();

        if (statusCode == 200) {
          return OrderActionResult(
            success: true,
            message: 'Order accepted! Ready for pickup.',
          );
        } else if (statusCode == 405) {
          return OrderActionResult(
            success: false,
            message: message ?? 'This order requires COD. Cannot accept.',
          );
        } else {
          return OrderActionResult(
            success: false,
            message: message ?? 'Failed to accept order.',
          );
        }
      }
      return OrderActionResult(
        success: false,
        message: 'Server error. Please try again.',
      );
    } catch (e) {
      print('[ERROR] acceptOrder: $e');
      return OrderActionResult(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Cancel order
  static Future<OrderActionResult> cancelOrder(
    int orderHeaderId,
    String reason,
  ) async {
    if (_useMockData) {
      print('[MOCK] Cancelling order: $orderHeaderId, reason: $reason');
      await Future.delayed(const Duration(seconds: 1));
      return OrderActionResult(
        success: true,
        message: 'Order cancelled successfully.',
      );
    }

    try {
      final session = await UserSessionDB.getSession();
      final userId = session?['user_id'] ?? '';

      final url = ApiConfig.apiUri('/postcancelriderorder');
      final body = {
        'OrderHeaderId': orderHeaderId,
        'UserId': userId,
        'CancelReason': reason,
      };

      print('[DEBUG] Cancelling order: $body');

      final response = await ApiClient.post(
        url,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      print('[DEBUG] Cancel response: ${response.statusCode}');
      print('[DEBUG] Cancel body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final statusCode = data['status_code'];
        final message = data['message']?.toString();

        if (statusCode == 200) {
          return OrderActionResult(
            success: true,
            message: 'Order cancelled successfully.',
          );
        } else {
          return OrderActionResult(
            success: false,
            message: message ?? 'Failed to cancel order.',
          );
        }
      }
      return OrderActionResult(
        success: false,
        message: 'Server error. Please try again.',
      );
    } catch (e) {
      print('[ERROR] cancelOrder: $e');
      return OrderActionResult(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Pickup via PIN
  static Future<OrderActionResult> pickupOrder(
    String orderNo,
    String pin,
    bool isPaid,
  ) async {
    if (_useMockData) {
      print('[MOCK] Picking up order: $orderNo with PIN: $pin');
      await Future.delayed(const Duration(seconds: 1));
      if (pin.length == 4) {
        return OrderActionResult(
          success: true,
          message: 'Order picked up successfully!',
        );
      } else {
        return OrderActionResult(
          success: false,
          message: 'Invalid PIN. Please try again.',
        );
      }
    }

    try {
      final session = await UserSessionDB.getSession();
      final userId = session?['user_id'] ?? '';

      final url = ApiConfig.apiUri('/PostPickupOrderByPIN');
      final body = {
        'OrderNo': orderNo,
        'UserId': userId,
        'PaidByCash': false,
        'IsPaid': isPaid,
        'IsPickup': false,
        'OrderPIN': pin,
      };

      print('[DEBUG] Picking up order: $body');

      final response = await ApiClient.post(
        url,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      print('[DEBUG] Pickup response: ${response.statusCode}');
      print('[DEBUG] Pickup body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final statusCode = data['status_code'];
        final message = data['message']?.toString();

        if (statusCode == 200) {
          return OrderActionResult(
            success: true,
            message: 'Order picked up successfully!',
          );
        } else if (statusCode == 414) {
          return OrderActionResult(
            success: false,
            message: 'Order does not exist or already picked up.',
          );
        } else {
          return OrderActionResult(
            success: false,
            message: message ?? 'Invalid PIN. Please try again.',
          );
        }
      }
      return OrderActionResult(
        success: false,
        message: 'Server error. Please try again.',
      );
    } catch (e) {
      print('[ERROR] pickupOrder: $e');
      return OrderActionResult(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Deliver order
  static Future<OrderActionResult> deliverOrder(
    int orderHeaderId,
    String orderNo,
    String pin,
    double deliveryFee,
    double totalAmount,
  ) async {
    if (_useMockData) {
      print('[MOCK] Delivering order: $orderNo with PIN: $pin');
      await Future.delayed(const Duration(seconds: 1));
      if (pin.length == 4) {
        return OrderActionResult(
          success: true,
          message: 'Order delivered successfully!',
        );
      } else {
        return OrderActionResult(
          success: false,
          message: 'Invalid PIN. Please try again.',
        );
      }
    }

    try {
      final session = await UserSessionDB.getSession();
      final userId = session?['user_id'] ?? '';

      final url = ApiConfig.apiUri('/postdeliverorder');
      final body = {
        'OrderNo': orderNo,
        'OrderHeaderId': orderHeaderId,
        'UserId': userId,
        'PIN': pin,
        'DeliveryFee': deliveryFee,
        'TotalAmount': totalAmount,
      };

      print('[DEBUG] Delivering order: $body');

      final response = await ApiClient.post(
        url,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      print('[DEBUG] Deliver response: ${response.statusCode}');
      print('[DEBUG] Deliver body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final statusCode = data['status_code'];
        final message = data['message']?.toString();

        if (statusCode == 200) {
          return OrderActionResult(
            success: true,
            message: 'Order delivered successfully!',
          );
        } else if (statusCode == 414) {
          return OrderActionResult(
            success: false,
            message: 'Order does not exist or already delivered.',
          );
        } else {
          return OrderActionResult(
            success: false,
            message: message ?? 'Invalid PIN. Please try again.',
          );
        }
      }
      return OrderActionResult(
        success: false,
        message: 'Server error. Please try again.',
      );
    } catch (e) {
      print('[ERROR] deliverOrder: $e');
      return OrderActionResult(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}
