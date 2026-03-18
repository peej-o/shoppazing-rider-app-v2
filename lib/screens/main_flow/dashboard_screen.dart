import 'package:flutter/material.dart';
import '../../widgets/cards/dashboard_card.dart';
import '../../widgets/cards/transaction_card.dart';
import '../../widgets/modals/top_up_sheet.dart';
import '../payment/transaction_history_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Mock data for now - will be replaced with real data later
  final double _balance = 250.50;
  final int _ongoing = 3;
  final double _earnings = 1250.75;
  final int _completed = 15;

  // Mock pending loads
  final List<Map<String, dynamic>> _mockPendingLoads = [
    {'amount': 100, 'referenceNo': 'REF123', 'isConfirmed': false},
    {'amount': 200, 'referenceNo': 'REF456', 'isConfirmed': false},
  ];

  // Mock transactions
  final List<Map<String, dynamic>> _mockTransactions = [
    {
      'referenceNo': 'REF123456',
      'amount': 500.00,
      'date': '2024-01-15 14:30',
      'remarks': 'Load purchase',
      'isConfirmed': true,
    },
    {
      'referenceNo': 'REF789012',
      'amount': 200.00,
      'date': '2024-01-14 09:15',
      'remarks': 'Load purchase',
      'isConfirmed': true,
    },
    {
      'referenceNo': 'REF345678',
      'amount': 100.00,
      'date': '2024-01-13 16:45',
      'remarks': 'Load purchase',
      'isConfirmed': false,
    },
  ];

  bool _isBalanceLow() {
    return _balance < 100;
  }

  void _showTopUpModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return const TopUpSheet();
      },
    ).then((amount) {
      if (amount != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Top up ₱$amount (demo)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _showTransactionHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TransactionHistoryPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Low balance warning banner
          if (_isBalanceLow()) _buildBalanceWarningBanner(),

          // Main content
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isSmall = constraints.maxWidth < 400;
                final double horizontalPadding = isSmall ? 8.0 : 24.0;

                return RefreshIndicator(
                  onRefresh: () async {
                    // Simulate refresh
                    await Future.delayed(const Duration(seconds: 1));
                    setState(() {});
                  },
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 24.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // Load Balance Card
                          DashboardCard(
                            icon: Icons.account_balance_wallet,
                            label: 'Load Balance',
                            value: '₱${_balance.toStringAsFixed(2)}',
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5D8AA8),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    minimumSize: const Size(0, 36),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Top Up',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  onPressed: _showTopUpModal,
                                ),
                                if (_mockPendingLoads.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${_mockPendingLoads.length} Pending',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            onTap: _showTransactionHistory,
                          ),

                          const SizedBox(height: 12),

                          // Ongoing Orders Card
                          DashboardCard(
                            icon: Icons.timelapse,
                            label: 'On Going',
                            value: '$_ongoing Orders',
                          ),

                          const SizedBox(height: 12),

                          // Earnings Card
                          DashboardCard(
                            icon: Icons.attach_money,
                            label: 'Earnings',
                            value: '₱${_earnings.toStringAsFixed(2)}',
                          ),

                          const SizedBox(height: 12),

                          // Completed Orders Card
                          DashboardCard(
                            icon: Icons.check_circle,
                            label: 'Completed',
                            value: '$_completed Orders',
                          ),

                          const SizedBox(height: 30),

                          // Recent Transactions Section
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Recent Transactions',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5D8AA8),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _showTransactionHistory,
                                  child: const Text('View All'),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Transaction List
                          ..._mockTransactions
                              .take(2)
                              .map(
                                (tx) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: TransactionCard(
                                    referenceNo: tx['referenceNo'],
                                    amount: tx['amount'],
                                    date: tx['date'],
                                    remarks: tx['remarks'],
                                    isConfirmed: tx['isConfirmed'],
                                    onTap: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Resume payment for ${tx['referenceNo']} (demo)',
                                          ),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceWarningBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.orange.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Low balance: ₱${_balance.toStringAsFixed(2)}. Please top up to continue.',
              style: TextStyle(
                color: Colors.orange.shade900,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _showTopUpModal,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Top Up',
              style: TextStyle(
                color: Colors.orange.shade900,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
