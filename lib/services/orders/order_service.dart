import 'dart:convert';
import '../api/api_client.dart';
import '../api/api_config.dart';
import '../database/user_session_db.dart';
import '../../models/entities/order.dart';

class OrderService {
  // 🔥 Toggle this to switch between MOCK and REAL API
  static const bool _useMockData = true; // Set to false to use real API

  // Fetch orders from API
  static Future<List<OrderData>> fetchOrders({
    required int riderId,
    double? lat,
    double? lng,
  }) async {
    // 🔥 MOCK DATA FOR TESTING
    if (_useMockData) {
      print('[MOCK] Using mock order data');
      return _getMockOrders();
    }

    // 🔥 REAL API CALL
    try {
      final session = await UserSessionDB.getSession();

      final url = ApiConfig.apiUri('/getriderorders');
      final body = {'Lat': lat ?? 0, 'Lng': lng ?? 0, 'RiderId': riderId};

      print('[DEBUG] Fetching orders: $body');

      final response = await ApiClient.post(
        url,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data is Map && data['OrderHeaders'] is List) {
          var orders = (data['OrderHeaders'] as List)
              .map<OrderData>((json) => OrderData.fromJson(json))
              .toList();

          // 🔥 TEMP: Add chat data for testing (optional)
          if (orders.isNotEmpty) {
            orders = orders.map((order) {
              // Add chat fields to first 3 orders for testing
              if (order.serverHeaderId == 123451 ||
                  order.serverHeaderId == 55555 ||
                  order.serverHeaderId == 67890) {
                return OrderData(
                  serverHeaderId: order.serverHeaderId,
                  orderNumber: order.orderNumber,
                  status: order.status,
                  dateTimeCreated: order.dateTimeCreated,
                  storeName: order.storeName,
                  storeImageUrl: order.storeImageUrl,
                  storeAddress: order.storeAddress,
                  customerName: order.customerName,
                  customerAddress: order.customerAddress,
                  customerMobileNo: order.customerMobileNo,
                  storeLat: order.storeLat,
                  storeLng: order.storeLng,
                  customerLat: order.customerLat,
                  customerLng: order.customerLng,
                  deliveryFee: order.deliveryFee,
                  onlineServiceCharge: order.onlineServiceCharge,
                  subTotal: order.subTotal,
                  totalDue: order.totalDue,
                  rawDetails: order.rawDetails,
                  assignedTo: order.assignedTo,
                  // 🔥 Add test chat data
                  OtherChatUserFirebaseUID:
                      'test_customer_${order.serverHeaderId}',
                  OtherChatUserName: order.customerName,
                  OtherChatUserId: 'test_user_${order.serverHeaderId}',
                  customerPin: order.customerPin,
                  isPaid: order.isPaid,
                  isManualDelivered: order.isManualDelivered,
                  isOrderRated: order.isOrderRated,
                  paymentTypeId: order.paymentTypeId,
                  onlinePaymentTypeId: order.onlinePaymentTypeId,
                  useLoyaltyPoints: order.useLoyaltyPoints,
                  saleHeaderId: order.saleHeaderId,
                  redeemedCash: order.redeemedCash,
                  dfDiscount: order.dfDiscount,
                  riderProfilePic: order.riderProfilePic,
                  riderFullName: order.riderFullName,
                  riderPlateNo: order.riderPlateNo,
                  riderDriversLicenseNo: order.riderDriversLicenseNo,
                  riderUserId: order.riderUserId,
                  riderLat: order.riderLat,
                  riderLng: order.riderLng,
                );
              }
              return order;
            }).toList();
          }

          return orders;
        }
      }
      return [];
    } catch (e) {
      print('[ERROR] fetchOrders: $e');
      return [];
    }
  }

  // 🔥 MOCK ORDERS DATA
  static List<OrderData> _getMockOrders() {
    return [
      // Pending order (can be accepted)
      OrderData(
        serverHeaderId: 123451,
        orderNumber: '123451',
        status: '1', // Pending
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
        isPaid: false,
      ),

      // Ready for pickup order
      OrderData(
        serverHeaderId: 33333,
        orderNumber: '33333',
        status: '4', // Ready for pickup
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
        status: '6', // In Transit
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
        status: '3', // Preparing
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

      // Completed order
      OrderData(
        serverHeaderId: 54321,
        orderNumber: '54321',
        status: '7', // Delivered
        dateTimeCreated: '12:00',
        storeName: 'McDonald\'s',
        storeImageUrl: '',
        storeAddress: 'Robinsons Place, Manila',
        customerName: 'Ana Reyes',
        customerAddress: '789 Pine St, Manila',
        customerMobileNo: '09345678901',
        storeLat: 14.5905,
        storeLng: 120.9752,
        customerLat: 14.5805,
        customerLng: 120.9852,
        deliveryFee: 45.0,
        onlineServiceCharge: 12.0,
        subTotal: 280.0,
        totalDue: '337.00',
        rawDetails: [
          {'ItemName': 'Big Mac', 'Qty': 1, 'UnitPrice': 150.0},
          {'ItemName': 'Fries', 'Qty': 1, 'UnitPrice': 80.0},
          {'ItemName': 'Coke', 'Qty': 1, 'UnitPrice': 50.0},
        ],
        OtherChatUserFirebaseUID: 'customer_543_uid',
        OtherChatUserName: 'Ana Reyes',
        OtherChatUserId: 'user_543',
        isPaid: true,
      ),

      // Cancelled order
      OrderData(
        serverHeaderId: 98765,
        orderNumber: '98765',
        status: '8', // Cancelled
        dateTimeCreated: '10:30',
        storeName: 'KFC',
        storeImageUrl: '',
        storeAddress: 'Market Market, Taguig',
        customerName: 'Jose Garcia',
        customerAddress: '321 Acacia St, Taguig',
        customerMobileNo: '09456789012',
        storeLat: 14.5805,
        storeLng: 121.0552,
        customerLat: 14.5705,
        customerLng: 121.0452,
        deliveryFee: 60.0,
        onlineServiceCharge: 15.0,
        subTotal: 390.0,
        totalDue: '465.00',
        rawDetails: [
          {'ItemName': 'Bucket Meal', 'Qty': 1, 'UnitPrice': 390.0},
        ],
        OtherChatUserFirebaseUID: 'customer_987_uid',
        OtherChatUserName: 'Jose Garcia',
        OtherChatUserId: 'user_987',
        isPaid: false,
      ),
    ];
  }

  // Accept order
  static Future<bool> acceptOrder(OrderData order) async {
    // 🔥 MOCK: Simulate success
    if (_useMockData) {
      print('[MOCK] Accepting order: ${order.orderNumber}');
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }

    // 🔥 REAL API CALL
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

      final response = await ApiClient.post(
        url,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['status_code'] == 200;
      }
      return false;
    } catch (e) {
      print('[ERROR] acceptOrder: $e');
      return false;
    }
  }

  // Cancel order
  static Future<bool> cancelOrder(int orderHeaderId, String reason) async {
    // 🔥 MOCK: Simulate success
    if (_useMockData) {
      print('[MOCK] Cancelling order: $orderHeaderId, reason: $reason');
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }

    // 🔥 REAL API CALL
    try {
      final session = await UserSessionDB.getSession();
      final userId = session?['user_id'] ?? '';

      final url = ApiConfig.apiUri('/postcancelriderorder');
      final body = {
        'OrderHeaderId': orderHeaderId,
        'UserId': userId,
        'CancelReason': reason,
      };

      final response = await ApiClient.post(
        url,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['status_code'] == 200;
      }
      return false;
    } catch (e) {
      print('[ERROR] cancelOrder: $e');
      return false;
    }
  }

  // Pickup via PIN
  static Future<bool> pickupOrder(
    String orderNo,
    String pin,
    bool isPaid,
  ) async {
    // 🔥 MOCK: Simulate success (accept any 4-digit PIN)
    if (_useMockData) {
      print('[MOCK] Picking up order: $orderNo with PIN: $pin');
      await Future.delayed(const Duration(seconds: 1));
      return pin.length == 4; // Accept any 4-digit PIN for testing
    }

    // 🔥 REAL API CALL
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

      final response = await ApiClient.post(
        url,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['status_code'] == 200;
      }
      return false;
    } catch (e) {
      print('[ERROR] pickupOrder: $e');
      return false;
    }
  }

  // Deliver order
  static Future<bool> deliverOrder(
    int orderHeaderId,
    String orderNo,
    String pin,
    double deliveryFee,
    double totalAmount,
  ) async {
    // 🔥 MOCK: Simulate success (accept any 4-digit PIN)
    if (_useMockData) {
      print('[MOCK] Delivering order: $orderNo with PIN: $pin');
      await Future.delayed(const Duration(seconds: 1));
      return pin.length == 4; // Accept any 4-digit PIN for testing
    }

    // 🔥 REAL API CALL
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

      final response = await ApiClient.post(
        url,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['status_code'] == 200;
      }
      return false;
    } catch (e) {
      print('[ERROR] deliverOrder: $e');
      return false;
    }
  }
}
