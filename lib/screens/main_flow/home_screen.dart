import 'package:flutter/material.dart';
import '../../models/entities/order.dart';
import '../../widgets/cards/order_card.dart';
import '../../widgets/common/balance_warning_banner.dart';
import '../order_management/order_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data with different statuses for testing
  final List<OrderData> _mockOrders = [
    // Pending orders (can be accepted)
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
      rawDetails: [],
    ),
    OrderData(
      serverHeaderId: 123452,
      orderNumber: '123452',
      status: '1', // Pending
      dateTimeCreated: '15:30',
      storeName: 'Greenwich',
      storeImageUrl: '',
      storeAddress: 'Ayala Mall, Manila',
      customerName: 'Pedro Santos',
      customerAddress: '456 Oak St, Manila',
      customerMobileNo: '09234567890',
      storeLat: 14.6005,
      storeLng: 120.9852,
      customerLat: 14.5905,
      customerLng: 120.9952,
      deliveryFee: 55.0,
      onlineServiceCharge: 15.0,
      subTotal: 380.0,
      totalDue: '450.00',
      rawDetails: [],
    ),

    // Ready for pickup orders
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
      rawDetails: [],
    ),

    // In Transit orders (can be delivered)
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
      rawDetails: [],
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
      rawDetails: [],
    ),

    // Completed orders
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
      rawDetails: [],
    ),

    // Cancelled orders
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
      rawDetails: [],
    ),
  ];

  Future<void> _updateOrderStatus(int orderId, String newStatus) async {
    print('🟡 Updating order $orderId to status $newStatus');
    setState(() {
      final index = _mockOrders.indexWhere((o) => o.serverHeaderId == orderId);
      if (index != -1) {
        final oldOrder = _mockOrders[index];
        _mockOrders[index] = OrderData(
          serverHeaderId: oldOrder.serverHeaderId,
          orderNumber: oldOrder.orderNumber,
          status: newStatus,
          dateTimeCreated: oldOrder.dateTimeCreated,
          storeName: oldOrder.storeName,
          storeImageUrl: oldOrder.storeImageUrl,
          storeAddress: oldOrder.storeAddress,
          customerName: oldOrder.customerName,
          customerAddress: oldOrder.customerAddress,
          customerMobileNo: oldOrder.customerMobileNo,
          storeLat: oldOrder.storeLat,
          storeLng: oldOrder.storeLng,
          customerLat: oldOrder.customerLat,
          customerLng: oldOrder.customerLng,
          deliveryFee: oldOrder.deliveryFee,
          onlineServiceCharge: oldOrder.onlineServiceCharge,
          subTotal: oldOrder.subTotal,
          totalDue: oldOrder.totalDue,
          rawDetails: oldOrder.rawDetails,
        );
        print('✅ Order updated successfully to status $newStatus');
      } else {
        print('❌ Order not found with ID: $orderId');
      }
    });
  }

  Future<void> _loadInitialOrders() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          BalanceWarningBanner(balance: 50.0, onTap: () {}),

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
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList(
                  _mockOrders
                      .where((o) => o.status != '7' && o.status != '8')
                      .toList(),
                ),
                _buildOrdersList(
                  _mockOrders.where((o) => o.status == '8').toList(),
                  showAccept: false,
                ),
                _buildOrdersList(
                  _mockOrders.where((o) => o.status == '7').toList(),
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

    return ListView.builder(
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
            // FIXED: Added onAccept callback for view details
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailsScreen(
                  order: order,
                  showAccept: canShowAccept,
                  onAccept: (newStatus) async {
                    print('🟢 HOME (onTap): Received status $newStatus');
                    await _updateOrderStatus(order.serverHeaderId, newStatus);
                    await _loadInitialOrders();
                  },
                ),
              ),
            );
          },
          onAccept: () async {
            // FIXED: Added onAccept callback for accept flow
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailsScreen(
                  order: order,
                  showAccept: true,
                  onAccept: (newStatus) async {
                    print(
                      '🟢 HOME (onAccept): Received status $newStatus for order ${order.orderNumber}',
                    );

                    await _updateOrderStatus(order.serverHeaderId, newStatus);
                    await _loadInitialOrders();

                    if (context.mounted) {
                      String message = '';
                      if (newStatus == '3')
                        message = 'Order accepted!';
                      else if (newStatus == '6')
                        message = 'Order picked up!';
                      else if (newStatus == '7')
                        message = 'Order delivered!';
                      else if (newStatus == '8')
                        message = 'Order cancelled!';

                      if (message.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(message),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            );

            if (result == true) {
              setState(() {});
            }
          },
        );
      },
    );
  }
}
