import 'package:flutter/material.dart';
import '../../models/entities/order.dart';  // Gamitin ang OrderData model
import '../../widgets/cards/order_card.dart';  // Gamitin ang OrderCard widget

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data for testing - gamitin ang OrderData model
  final List<OrderData> _mockOrders = [
    OrderData(
      serverHeaderId: 12345,
      orderNumber: '12345',
      status: '1',  // Pending
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
      serverHeaderId: 67890,
      orderNumber: '67890',
      status: '3',  // Preparing
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
  ];

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
                  _mockOrders.where((o) => o.status != '7' && o.status != '8').toList()
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
        return OrderCard(
          orderNumber: order.orderNumber,
          pickup: order.storeName,
          dropoff: order.customerAddress,
          orderTime: order.dateTimeCreated,
          storeImageUrl: order.storeImageUrl,
          deliveryFee: order.deliveryFee,
          subTotal: order.subTotal,
          showAccept: showAccept && order.status != '8' && order.status != '7',
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Order ${order.orderNumber} tapped (demo)')),
            );
          },
          onAccept: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Accepting order ${order.orderNumber} (demo)')),
            );
          },
        );
      },
    );
  }
}