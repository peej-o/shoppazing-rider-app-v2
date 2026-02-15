// FILE: lib/screens/main_flow/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/cards/dashboard_card.dart';
import '../../widgets/cards/transaction_card.dart';
import '../../widgets/common/balance_warning_banner.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Mock data for design only
  final double _mockBalance = 250.50;
  final int _mockOngoing = 3;
  final double _mockEarnings = 1250.75;
  final int _mockCompleted = 15;

  // Mock pending loads for design
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
    return _mockBalance < 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Low balance warning banner (shown conditionally)
          if (_isBalanceLow())
            BalanceWarningBanner(
              balance: _mockBalance,
              onTap: () {
                _showTopUpModal(context);
              },
            ),

          // Main content
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isSmall = constraints.maxWidth < 400;
                final double horizontalPadding = isSmall ? 8.0 : 24.0;

                return SingleChildScrollView(
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
                          value: '₱${_mockBalance.toStringAsFixed(2)}',
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
                                onPressed: () => _showTopUpModal(context),
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
                          onTap: () {
                            _showTransactionHistory(context);
                          },
                        ),

                        const SizedBox(height: 12),

                        // Ongoing Orders Card
                        DashboardCard(
                          icon: Icons.timelapse,
                          label: 'On Going',
                          value: '$_mockOngoing Orders',
                        ),

                        const SizedBox(height: 12),

                        // Earnings Card
                        DashboardCard(
                          icon: Icons.attach_money,
                          label: 'Earnings',
                          value: '₱${_mockEarnings.toStringAsFixed(2)}',
                        ),

                        const SizedBox(height: 12),

                        // Completed Orders Card
                        DashboardCard(
                          icon: Icons.check_circle,
                          label: 'Completed',
                          value: '$_mockCompleted Orders',
                        ),

                        const SizedBox(height: 30),

                        // Recent Transactions Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                                onPressed: () {
                                  _showTransactionHistory(context);
                                },
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Resume payment for ${tx['referenceNo']} (Demo)',
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showTopUpModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return const TopUpSheet();
      },
    );
  }

  void _showTransactionHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TransactionHistoryPage()),
    );
  }
}

// TopUpSheet widget remains here or can be moved to a separate file
class TopUpSheet extends StatefulWidget {
  const TopUpSheet({super.key});

  @override
  State<TopUpSheet> createState() => _TopUpSheetState();
}

class _TopUpSheetState extends State<TopUpSheet> {
  final List<int> presets = [100, 200, 300, 400, 500, 1000];
  int? selectedAmount;
  final TextEditingController customController = TextEditingController();
  String? errorText;

  @override
  void dispose() {
    customController.dispose();
    super.dispose();
  }

  void _selectPreset(int amount) {
    setState(() {
      selectedAmount = amount;
      customController.text = amount.toString();
      errorText = null;
    });
  }

  void _onCustomChanged(String value) {
    final int? val = int.tryParse(value);
    setState(() {
      selectedAmount = val;
      if (val == null) {
        errorText = 'Enter a valid number';
      } else if (val < 100) {
        errorText = 'Minimum is ₱100';
      } else if (val > 1000) {
        errorText = 'Maximum is ₱1000';
      } else {
        errorText = null;
      }
    });
  }

  void _confirm() {
    if (selectedAmount == null) {
      setState(() => errorText = 'Please select or enter an amount');
      return;
    }
    if (selectedAmount! < 100 || selectedAmount! > 1000) {
      setState(() => errorText = 'Amount must be between ₱100 and ₱1000');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Top up ₱$selectedAmount (Demo)'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Center(
            child: Text(
              'Top Up Load Balance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D8AA8),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: presets.map((amount) {
              final bool selected = selectedAmount == amount;
              return ChoiceChip(
                label: Text('₱$amount'),
                selected: selected,
                onSelected: (_) => _selectPreset(amount),
                selectedColor: const Color(0xFF5D8AA8),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF5D8AA8),
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor: Colors.grey[100],
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: customController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Custom Amount',
              prefixText: '₱',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              errorText: errorText,
            ),
            onChanged: _onCustomChanged,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D8AA8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _confirm,
              child: const Text('Confirm'),
            ),
          ),
        ],
      ),
    );
  }
}

// Transaction History Page
class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: const Color(0xFF5D8AA8),
        foregroundColor: Colors.white,
      ),
      body: const TransactionHistoryContent(),
    );
  }
}

class TransactionHistoryContent extends StatefulWidget {
  const TransactionHistoryContent({super.key});

  @override
  State<TransactionHistoryContent> createState() =>
      _TransactionHistoryContentState();
}

class _TransactionHistoryContentState extends State<TransactionHistoryContent> {
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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Refreshed (Demo)')));
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _mockTransactions.length,
          itemBuilder: (context, index) {
            final tx = _mockTransactions[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TransactionCard(
                referenceNo: tx['referenceNo'],
                amount: tx['amount'],
                date: tx['date'],
                remarks: tx['remarks'],
                isConfirmed: tx['isConfirmed'],
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Resume payment for ${tx['referenceNo']} (Demo)',
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
