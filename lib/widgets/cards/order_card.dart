//order_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/order_helpers.dart';
import '../common/address_button.dart';

class OrderCard extends StatelessWidget {
  final String orderNumber;
  final String pickup;
  final String dropoff;
  final VoidCallback onTap;
  final VoidCallback onAccept;
  final String orderTime;
  final String storeImageUrl;
  final double deliveryFee;
  final double subTotal;
  final bool showAccept;
  final bool isAccepting;
  final String orderStatusId;
  final String storeAddress;
  final String customerName;
  final String customerAddress;
  final String customerMobileNo;
  final double storeLat;
  final double storeLng;
  final double customerLat;
  final double customerLng;

  const OrderCard({
    Key? key,
    required this.orderNumber,
    required this.pickup,
    required this.dropoff,
    required this.onTap,
    required this.onAccept,
    required this.orderTime,
    required this.storeImageUrl,
    required this.deliveryFee,
    required this.subTotal,
    required this.showAccept,
    this.isAccepting = false,
    required this.orderStatusId,
    required this.storeAddress,
    required this.customerName,
    required this.customerAddress,
    required this.customerMobileNo,
    required this.storeLat,
    required this.storeLng,
    required this.customerLat,
    required this.customerLng,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with order number and status
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF5D8AA8),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          'Order #$orderNumber',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: getOrderStatusColor(
                              orderStatusId,
                            ).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            getOrderStatusLabel(orderStatusId),
                            style: TextStyle(
                              color: getOrderStatusColor(orderStatusId),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Store with AddressButton
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.store, color: Color(0xFF5D8AA8), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pickup,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            AddressButton(
                              address: storeAddress,
                              latitude: storeLat,
                              longitude: storeLng,
                              isCompact: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24),

                  // Customer with AddressButton
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.person, color: Color(0xFF5D8AA8), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            AddressButton(
                              address: customerAddress,
                              latitude: customerLat,
                              longitude: customerLng,
                              isCompact: true,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              customerMobileNo,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Delivery fee and subtotal
                  Row(
                    children: [
                      const Text(
                        'Delivery Fee: ',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      Text(
                        NumberFormat.currency(locale: 'en_PH', symbol: '₱')
                            .format(deliveryFee),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Text(
                        'Sub Total: ',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      Text(
                        NumberFormat.currency(locale: 'en_PH', symbol: '₱')
                            .format(subTotal),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Accept button
                  if (showAccept)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAccepting
                              ? const Color(0xFF5D8AA8).withOpacity(0.7)
                              : const Color(0xFF5D8AA8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                        onPressed: isAccepting ? null : onAccept,
                        child: isAccepting
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'ACCEPTING...',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                'ACCEPT JOB',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
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
}