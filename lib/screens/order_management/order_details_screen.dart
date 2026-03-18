import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/entities/order.dart';
import '../../services/api/api_config.dart';
import '../../widgets/common/address_button.dart';
import '../../widgets/common/mobile_phone_button.dart';
import '../../utils/order_helpers.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderData order;
  final bool showAccept;
  final Function(String)? onAccept;

  const OrderDetailsScreen({
    super.key,
    required this.order,
    this.showAccept = false,
    this.onAccept,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _isAccepting = false;
  bool _isCancelling = false;
  bool _isPickedUp = false;
  bool _isDelivered = false;
  String? _error;

  final TextEditingController _pinController = TextEditingController();
  bool _isSubmittingPin = false;
  String? _pinError;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  // ============ ACCEPT ORDER ============
  Future<void> _acceptOrder() async {
    setState(() {
      _isAccepting = true;
      _error = null;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order accepted!'),
          backgroundColor: Colors.green,
        ),
      );

      print('🔵 ACCEPT: Calling onAccept with status 3');
      if (widget.onAccept != null) {
        widget.onAccept!('3');
      }

      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _error = 'Failed to accept order: $e';
        _isAccepting = false;
      });
    }
  }

  // ============ CANCEL ORDER ============
  Future<void> _showCancelDialog() async {
    final TextEditingController reasonController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please tell us why you are cancelling this order:'),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter cancellation reason',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
            ElevatedButton(
              onPressed: () {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a cancellation reason'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                Navigator.pop(context, reason);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cancel Order'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      await _cancelOrder(result);
    }
  }

  Future<void> _cancelOrder(String reason) async {
    setState(() {
      _isCancelling = true;
      _error = null;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order cancelled successfully'),
          backgroundColor: Colors.green,
        ),
      );

      print('🔵 CANCEL: Calling onAccept with status 8');
      if (widget.onAccept != null) {
        widget.onAccept!('8');
      }

      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _error = 'Failed to cancel order: $e';
        _isCancelling = false;
      });
    }
  }

  // ============ PICKUP PIN ============
  Future<void> _showPickupPinDialog() async {
    _pinController.clear();
    _pinError = null;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Pickup PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please enter the 4-digit PIN from the store:'),
              const SizedBox(height: 16),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: '4-digit PIN',
                  errorText: _pinError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  counterText: '',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isSubmittingPin ? null : _submitPickupPin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D8AA8),
                foregroundColor: Colors.white,
              ),
              child: _isSubmittingPin
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Confirm Pickup'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitPickupPin() async {
    final pin = _pinController.text.trim();

    if (pin.length != 4) {
      setState(() => _pinError = 'PIN must be 4 digits');
      return;
    }

    setState(() {
      _pinError = null;
      _isSubmittingPin = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() {
        _isSubmittingPin = false;
        _isPickedUp = true;
      });

      Navigator.pop(context); // Close dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order picked up successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      print('🔵 PICKUP: Calling onAccept with status 6');
      if (widget.onAccept != null) {
        widget.onAccept!('6');
      }

      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isSubmittingPin = false;
        _pinError = 'Error: $e';
      });
    }
  }

  // ============ DELIVERY PIN ============
  Future<void> _showDeliveredPinDialog() async {
    _pinController.clear();
    _pinError = null;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Delivery PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please enter the 4-digit PIN provided by the customer:',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: '4-digit PIN',
                  errorText: _pinError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  counterText: '',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isSubmittingPin ? null : _submitDeliveredPin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: _isSubmittingPin
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Confirm Delivery'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitDeliveredPin() async {
    final pin = _pinController.text.trim();

    if (pin.length != 4) {
      setState(() => _pinError = 'PIN must be 4 digits');
      return;
    }

    setState(() {
      _pinError = null;
      _isSubmittingPin = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() {
        _isSubmittingPin = false;
        _isDelivered = true;
      });

      Navigator.pop(context); // Close dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order marked as delivered!'),
          backgroundColor: Colors.green,
        ),
      );

      print('🔵 DELIVERY: Calling onAccept with status 7');
      if (widget.onAccept != null) {
        widget.onAccept!('7');
      }

      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isSubmittingPin = false;
        _pinError = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    // RIDERV1 LOGIC - Button visibility conditions
    final bool showAcceptButton =
        widget.showAccept && order.status == '1'; // Pending
    final bool showPickupButton = order.status == '4' && !_isPickedUp; // Ready
    final bool showDeliveredButton =
        order.status == '6' && !_isDelivered; // In Transit
    final bool showCancelButton =
        order.status != '1' &&
        order.status != '7' &&
        order.status != '8' &&
        !_isDelivered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: const Color(0xFF5D8AA8),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Number and Date
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.orderNumber}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D8AA8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Placed on: ${order.dateTimeCreated}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: getOrderStatusColor(
                          order.status,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: getOrderStatusColor(order.status),
                        ),
                      ),
                      child: Text(
                        getOrderStatusLabel(order.status),
                        style: TextStyle(
                          color: getOrderStatusColor(order.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Store Information
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pickup Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D8AA8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.store,
                            color: Color(0xFF5D8AA8),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.storeName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              AddressButton(
                                address: order.storeAddress,
                                latitude: order.storeLat,
                                longitude: order.storeLng,
                                isCompact: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Customer Information
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D8AA8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.person,
                          color: Color(0xFF5D8AA8),
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.customerName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  MobilePhoneButton(
                                    mobileNumber: order.customerMobileNo,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              AddressButton(
                                address: order.customerAddress,
                                latitude: order.customerLat,
                                longitude: order.customerLng,
                                isCompact: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Order Items
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Items',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D8AA8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildOrderItems(order.rawDetails),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Payment Summary
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSummaryRow('Subtotal', order.subTotal),
                    const Divider(),
                    _buildSummaryRow('Delivery Fee', order.deliveryFee),
                    const Divider(),
                    _buildSummaryRow(
                      'Total',
                      order.subTotal + order.deliveryFee,
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ACTION BUTTONS - RIDERV1 ORDER
            if (showAcceptButton)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isAccepting ? null : _acceptOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D8AA8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isAccepting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Accept Order',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

            if (showPickupButton) ...[
              if (showAcceptButton) const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showPickupPinDialog,
                  icon: const Icon(
                    Icons.qr_code_scanner,
                    color: Color(0xFF5D8AA8),
                  ),
                  label: const Text('Pickup via PIN'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF5D8AA8)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],

            if (showDeliveredButton) ...[
              if (showAcceptButton || showPickupButton)
                const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showDeliveredPinDialog,
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: const Text('Delivered'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],

            if (showCancelButton) ...[
              if (showAcceptButton || showPickupButton || showDeliveredButton)
                const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isCancelling ? null : _showCancelDialog,
                  icon: _isCancelling
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cancel, color: Colors.red),
                  label: Text(
                    _isCancelling ? 'Cancelling...' : 'Cancel Order',
                    style: TextStyle(
                      color: _isCancelling ? Colors.red.shade300 : Colors.red,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Chat Button
            if (order.OtherChatUserFirebaseUID != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Chat feature coming soon'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat, color: Color(0xFF5D8AA8)),
                  label: const Text('Chat with Customer'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF5D8AA8)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],

            if (_isDelivered)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Delivered!',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(List<dynamic> items) {
    if (items.isEmpty) {
      return const Text('No items found.');
    }

    return Column(
      children: items.map<Widget>((item) {
        final String itemName = item['ItemName']?.toString() ?? 'N/A';
        final String qty = _formatQty(item['Qty']);
        final double price = (item['UnitPrice'] as num?)?.toDouble() ?? 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF5D8AA8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF5D8AA8)),
                ),
                child: Text(
                  'x$qty',
                  style: const TextStyle(
                    color: Color(0xFF5D8AA8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  itemName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                NumberFormat.currency(
                  locale: 'en_PH',
                  symbol: '₱',
                ).format(price),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D8AA8),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? const Color(0xFF5D8AA8) : Colors.grey,
            ),
          ),
          Text(
            NumberFormat.currency(locale: 'en_PH', symbol: '₱').format(amount),
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? const Color(0xFF5D8AA8) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  String _formatQty(dynamic qty) {
    if (qty == null) return '0';
    if (qty is int) return qty.toString();
    if (qty is double) {
      return qty.toStringAsFixed(0);
    }
    return qty.toString();
  }
}
