import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/entities/order.dart';
import '../../widgets/cards/order_card.dart';
import '../../widgets/common/balance_warning_banner.dart';
import '../order_management/order_details_screen.dart';
import '../../services/orders/order_service.dart';
import '../../services/database/user_session_db.dart';
import '../../services/device/device_service.dart';
import '../../services/dashboard/dashboard_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<OrderData> _orders = [];
  bool _isLoading = true;
  String? _error;

  double _balance = 0.0;
  bool _balanceLoading = false;

  static double? testLat;
  static double? testLng;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOrders();
    _fetchBalance();
  }

  Future<void> _fetchBalance() async {
    if (_balanceLoading) return;
    _balanceLoading = true;

    try {
      final data = await DashboardService.fetchDashboardData();
      if (mounted) {
        setState(() {
          _balance = data['balance'];
          _balanceLoading = false;
        });
      }
    } catch (e) {
      print('[ERROR] Error fetching balance: $e');
      _balanceLoading = false;
    }
  }

  bool _isBalanceLow() {
    return _balance < 100;
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final session = await UserSessionDB.getSession();
      final riderId =
          int.tryParse(session?['rider_id']?.toString() ?? '0') ?? 0;

      if (riderId == 0) {
        setState(() {
          _error = 'Rider ID not found';
          _isLoading = false;
        });
        return;
      }

      double? lat = testLat;
      double? lng = testLng;

      if (lat == null || lng == null) {
        final position = await DeviceService.getCurrentLocation(context);
        if (position != null) {
          lat = position.latitude;
          lng = position.longitude;
        }
      }

      final orders = await OrderService.fetchOrders(
        riderId: riderId,
        lat: lat,
        lng: lng,
      );

      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleOrderAction(
    OrderData order,
    String action, {
    String? pin,
    String? reason,
  }) async {
    bool success = false;

    switch (action) {
      case 'accept':
        success = await OrderService.acceptOrder(order);
        break;
      case 'cancel':
        success = await OrderService.cancelOrder(
          order.serverHeaderId,
          reason ?? '',
        );
        break;
      case 'pickup':
        success = await OrderService.pickupOrder(
          order.orderNumber,
          pin ?? '',
          order.isPaid,
        );
        break;
      case 'deliver':
        final totalAmount =
            order.subTotal + order.onlineServiceCharge + order.deliveryFee;
        success = await OrderService.deliverOrder(
          order.serverHeaderId,
          order.orderNumber,
          pin ?? '',
          order.deliveryFee,
          totalAmount,
        );
        break;
    }

    if (success && mounted) {
      await _loadOrders();
      await _fetchBalance();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order ${action}ed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to $action order'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToDashboard() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Go to Dashboard tab to top up'),
        backgroundColor: Color(0xFF5D8AA8),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (_isBalanceLow())
            BalanceWarningBanner(
              balance: _balance,
              onTap: _navigateToDashboard,
            ),

          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF5D8AA8),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF5D8AA8),
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Cancelled'),
              Tab(text: 'Completed'),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadOrders,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOrdersList(
                        _orders
                            .where((o) => o.status != '7' && o.status != '8')
                            .toList(),
                      ),
                      _buildOrdersList(
                        _orders.where((o) => o.status == '8').toList(),
                        showAccept: false,
                      ),
                      _buildOrdersList(
                        _orders.where((o) => o.status == '7').toList(),
                        showAccept: false,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<OrderData> orders, {bool showAccept = true}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              showAccept ? 'No active orders' : 'No orders found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          final bool canShowAccept = showAccept && order.status == '1';

          return OrderCard(
            orderNumber: order.orderNumber,
            pickup: order.storeName,
            dropoff: order.customerAddress,
            orderTime: order.dateTimeCreated,
            storeImageUrl: order.storeImageUrl,
            deliveryFee: order.deliveryFee,
            subTotal: order.subTotal,
            showAccept: canShowAccept,
            isAccepting: false,
            orderStatusId: order.status,
            storeAddress: order.storeAddress,
            customerName: order.customerName,
            customerAddress: order.customerAddress,
            customerMobileNo: order.customerMobileNo,
            storeLat: order.storeLat,
            storeLng: order.storeLng,
            customerLat: order.customerLat,
            customerLng: order.customerLng,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailsScreen(
                    order: order,
                    showAccept: canShowAccept,
                    onAccept: (newStatus) async {
                      await _loadOrders();
                      await _fetchBalance();
                    },
                  ),
                ),
              );
            },
            onAccept: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Accept Order'),
                  content: const Text(
                    'Are you sure you want to accept this order?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Accept'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await _handleOrderAction(order, 'accept');
              }
            },
          );
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../models/entities/order.dart';
// import '../../widgets/cards/order_card.dart';
// import '../../widgets/common/balance_warning_banner.dart';
// import '../order_management/order_details_screen.dart';
// import '../../services/orders/order_service.dart';
// import '../../services/database/user_session_db.dart';
// import '../../services/device/device_service.dart';
// import '../../services/dashboard/dashboard_service.dart';
// import '../../providers/order_providers.dart';

// class HomeScreen extends ConsumerStatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   ConsumerState<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends ConsumerState<HomeScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   double _balance = 0.0;
//   bool _balanceLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _fetchBalance();
//   }

//   Future<void> _fetchBalance() async {
//     if (_balanceLoading) return;
//     _balanceLoading = true;

//     try {
//       final data = await DashboardService.fetchDashboardData();
//       if (mounted) {
//         setState(() {
//           _balance = data['balance'];
//           _balanceLoading = false;
//         });
//       }
//     } catch (e) {
//       print('[ERROR] Error fetching balance: $e');
//       _balanceLoading = false;
//     }
//   }

//   bool _isBalanceLow() => _balance < 100;

//   void _navigateToDashboard() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Go to Dashboard tab to top up'),
//         backgroundColor: Color(0xFF5D8AA8),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Watch real-time orders from Firebase
//     final ordersAsync = ref.watch(realtimeOrdersProvider);
//     final newOrdersCount = ref.watch(newOrdersCountProvider);

//     return Scaffold(
//       body: Column(
//         children: [
//           if (_isBalanceLow())
//             BalanceWarningBanner(
//               balance: _balance,
//               onTap: _navigateToDashboard,
//             ),

//           Container(
//             color: Colors.white,
//             child: TabBar(
//               controller: _tabController,
//               labelColor: const Color(0xFF5D8AA8),
//               unselectedLabelColor: Colors.grey,
//               indicatorColor: const Color(0xFF5D8AA8),
//               tabs: [
//                 Tab(
//                   text: 'Active',
//                   icon: newOrdersCount > 0
//                       ? Badge(
//                           label: Text('$newOrdersCount'),
//                           child: const Icon(Icons.notifications_active),
//                         )
//                       : null,
//                 ),
//                 const Tab(text: 'Cancelled'),
//                 const Tab(text: 'Completed'),
//               ],
//             ),
//           ),

//           Expanded(
//             child: ordersAsync.when(
//               data: (orders) {
//                 final activeOrders = orders
//                     .where((o) => o.status != '7' && o.status != '8')
//                     .toList();
//                 final cancelledOrders = orders
//                     .where((o) => o.status == '8')
//                     .toList();
//                 final completedOrders = orders
//                     .where((o) => o.status == '7')
//                     .toList();

//                 return TabBarView(
//                   controller: _tabController,
//                   children: [
//                     _buildOrdersList(activeOrders),
//                     _buildOrdersList(cancelledOrders, showAccept: false),
//                     _buildOrdersList(completedOrders, showAccept: false),
//                   ],
//                 );
//               },
//               loading: () => const Center(
//                 child: CircularProgressIndicator(color: Color(0xFF5D8AA8)),
//               ),
//               error: (err, stack) => Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
//                     const SizedBox(height: 16),
//                     Text('Error: $err'),
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: () {
//                         ref.invalidate(realtimeOrdersProvider);
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF5D8AA8),
//                         foregroundColor: Colors.white,
//                       ),
//                       child: const Text('Retry'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOrdersList(List<OrderData> orders, {bool showAccept = true}) {
//     if (orders.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
//             const SizedBox(height: 16),
//             Text(
//               showAccept ? 'No active orders' : 'No orders found',
//               style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//             ),
//           ],
//         ),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: () async {
//         ref.invalidate(realtimeOrdersProvider);
//         await _fetchBalance();
//       },
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: orders.length,
//         itemBuilder: (context, index) {
//           final order = orders[index];
//           final bool canShowAccept = showAccept && order.status == '1';

//           return OrderCard(
//             orderNumber: order.orderNumber,
//             pickup: order.storeName,
//             dropoff: order.customerAddress,
//             orderTime: order.dateTimeCreated,
//             storeImageUrl: order.storeImageUrl,
//             deliveryFee: order.deliveryFee,
//             subTotal: order.subTotal,
//             showAccept: canShowAccept,
//             isAccepting: false,
//             orderStatusId: order.status,
//             storeAddress: order.storeAddress,
//             customerName: order.customerName,
//             customerAddress: order.customerAddress,
//             customerMobileNo: order.customerMobileNo,
//             storeLat: order.storeLat,
//             storeLng: order.storeLng,
//             customerLat: order.customerLat,
//             customerLng: order.customerLng,
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => OrderDetailsScreen(
//                     order: order,
//                     showAccept: canShowAccept,
//                     onAccept: (newStatus) async {
//                       ref.invalidate(realtimeOrdersProvider);
//                       await _fetchBalance();
//                     },
//                   ),
//                 ),
//               );
//             },
//             onAccept: () async {
//               final confirm = await showDialog<bool>(
//                 context: context,
//                 builder: (context) => AlertDialog(
//                   title: const Text('Accept Order'),
//                   content: const Text(
//                     'Are you sure you want to accept this order?',
//                   ),
//                   actions: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(context, false),
//                       child: const Text('Cancel'),
//                     ),
//                     ElevatedButton(
//                       onPressed: () => Navigator.pop(context, true),
//                       child: const Text('Accept'),
//                     ),
//                   ],
//                 ),
//               );

//               if (confirm == true) {
//                 // Call API to accept
//                 final success = await OrderService.acceptOrder(order);
//                 if (success) {
//                   ref.invalidate(realtimeOrdersProvider);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Order accepted!'),
//                       backgroundColor: Colors.green,
//                     ),
//                   );
//                 }
//               }
//             },
//           );
//         },
//       ),
//     );
//   }
// }
