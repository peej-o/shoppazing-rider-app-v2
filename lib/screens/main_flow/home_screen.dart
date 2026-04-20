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
import '../../utils/order_helpers.dart';

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

  // Track currently accepted order
  int? _acceptedOrderId;
  bool _isAcceptingOrder = false;

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

  bool _isBalanceLow() => _balance < 100;

  Future<void> _loadOrders() async {
    if (_isAcceptingOrder) return;

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

  Future<void> _updateOrderStatus(int orderId, String newStatus) async {
    setState(() {
      final index = _orders.indexWhere((o) => o.serverHeaderId == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: newStatus);
      }
    });
  }

  Future<void> _handleOrderAction(
    OrderData order,
    String action, {
    String? pin,
    String? reason,
  }) async {
    OrderActionResult? result;

    switch (action) {
      case 'accept':
        result = await OrderService.acceptOrder(order);
        if (result.success) {
          await _updateOrderStatus(order.serverHeaderId, '4');
          setState(() {
            _acceptedOrderId = order.serverHeaderId;
          });
        }
        break;
      case 'cancel':
        result = await OrderService.cancelOrder(
          order.serverHeaderId,
          reason ?? '',
        );
        if (result.success) {
          await _updateOrderStatus(order.serverHeaderId, '8');
          setState(() {
            _acceptedOrderId = null;
          });
        }
        break;
      case 'pickup':
        result = await OrderService.pickupOrder(
          order.orderNumber,
          pin ?? '',
          order.isPaid,
        );
        if (result.success) {
          await _updateOrderStatus(order.serverHeaderId, '6');
        }
        break;
      case 'deliver':
        final totalAmount =
            order.subTotal + order.onlineServiceCharge + order.deliveryFee;
        result = await OrderService.deliverOrder(
          order.serverHeaderId,
          order.orderNumber,
          pin ?? '',
          order.deliveryFee,
          totalAmount,
        );
        if (result.success) {
          await _updateOrderStatus(order.serverHeaderId, '7');
          setState(() {
            _acceptedOrderId = null;
          });
        }
        break;
    }

    if (result != null && mounted) {
      await _loadOrders();
      await _fetchBalance();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Order ${action}ed successfully!'),
          backgroundColor: result.success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String _getSuccessMessage(String action) {
    switch (action) {
      case 'accept':
        return 'Order accepted! Ready for pickup.';
      case 'pickup':
        return 'Order picked up!';
      case 'deliver':
        return 'Order delivered!';
      case 'cancel':
        return 'Order cancelled.';
      default:
        return 'Order ${action}ed successfully!';
    }
  }

  void _navigateToDashboard() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Go to Dashboard tab to top up'),
        backgroundColor: Color(0xFF00509D),
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
            labelColor: const Color(0xFF00509D),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF00509D),
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
                      _buildOrdersList(_orders.where(isOrderActive).toList()),
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
          final availableActions = getAvailableActions(order);
          final bool canShowAccept =
              showAccept &&
              availableActions.contains('accept') &&
              _acceptedOrderId == null; // Only show if no order accepted
          final bool isAcceptingThisOrder =
              _isAcceptingOrder && _acceptedOrderId == order.serverHeaderId;

          return OrderCard(
            orderNumber: order.orderNumber,
            pickup: order.storeName,
            dropoff: order.customerAddress,
            orderTime: order.dateTimeCreated,
            storeImageUrl: order.storeImageUrl,
            deliveryFee: order.deliveryFee,
            subTotal: order.subTotal,
            showAccept: canShowAccept,
            isAccepting: isAcceptingThisOrder,
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
                      if (newStatus == '7' || newStatus == '8') {
                        setState(() {
                          _acceptedOrderId = null;
                        });
                      } else if (newStatus == '4') {
                        setState(() {
                          _acceptedOrderId = order.serverHeaderId;
                        });
                      }
                    },
                  ),
                ),
              );
            },
            onAccept: () async {
              // Prevent multiple simultaneous accepts
              if (_isAcceptingOrder) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please wait, processing another order...'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

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
                setState(() {
                  _isAcceptingOrder = true;
                });

                await _handleOrderAction(order, 'accept');

                setState(() {
                  _isAcceptingOrder = false;
                });
              }
            },
          );
        },
      ),
    );
  }
}
