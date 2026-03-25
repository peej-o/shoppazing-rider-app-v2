// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_database/firebase_database.dart';
// import '../models/entities/order.dart';
// import '../services/database/user_session_db.dart';

// // Provider for rider ID
// final riderIdProvider = FutureProvider<String?>((ref) async {
//   final session = await UserSessionDB.getSession();
//   return session?['rider_id']?.toString();
// });

// // Provider for real-time orders from Firebase
// final realtimeOrdersProvider = StreamProvider<List<OrderData>>((ref) {
//   final riderId = ref.watch(riderIdProvider).value;

//   if (riderId == null || riderId.isEmpty) {
//     print('[RIVERPOD] No rider ID');
//     return Stream.value([]);
//   }

//   print('[RIVERPOD] Listening to Firebase for rider: $riderId');

//   final database = FirebaseDatabase.instance.ref();

//   // Listen to orders for this specific rider
//   return database.child('riders').child(riderId).child('orders').onValue.map((
//     event,
//   ) {
//     final snapshot = event.snapshot;
//     print('[RIVERPOD] Firebase data received: ${snapshot.value}');

//     if (snapshot.value == null) {
//       print('[RIVERPOD] No orders found');
//       return [];
//     }

//     final orders = <OrderData>[];
//     final data = snapshot.value as Map<dynamic, dynamic>;

//     data.forEach((key, value) {
//       if (value is Map) {
//         try {
//           final orderJson = Map<String, dynamic>.from(value);
//           // Add the key as ServerHeaderId if not present
//           if (!orderJson.containsKey('ServerHeaderId')) {
//             orderJson['ServerHeaderId'] = int.tryParse(key.toString()) ?? 0;
//           }
//           final order = OrderData.fromJson(orderJson);
//           orders.add(order);
//           print('[RIVERPOD] Added order: ${order.orderNumber}');
//         } catch (e) {
//           print('[RIVERPOD] Error parsing order: $e');
//         }
//       }
//     });

//     // Sort by date (newest first)
//     orders.sort((a, b) => b.dateTimeCreated.compareTo(a.dateTimeCreated));
//     print('[RIVERPOD] Total orders: ${orders.length}');
//     return orders;
//   });
// });

// // Provider for order count badge
// final newOrdersCountProvider = Provider<int>((ref) {
//   final orders = ref.watch(realtimeOrdersProvider).value ?? [];
//   return orders.where((o) => o.status == '1').length;
// });
