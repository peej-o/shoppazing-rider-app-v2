import 'package:flutter/material.dart';
import '../../widgets/cards/transaction_card.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  // Mock data for now - will be replaced with real data later
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

  bool _isLoading = false;
  String? _error;

  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: const Color(0xFF5D8AA8),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _handleRefresh,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : _mockTransactions.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
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
                          _handlePendingTransactionTap(tx);
                        },
                      ),
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleRefresh,
        backgroundColor: const Color(0xFF5D8AA8),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.refresh),
        label: const Text('Refresh'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No transactions found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pull down to refresh',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _handlePendingTransactionTap(Map<String, dynamic> tx) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resume Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resume payment for:'),
            const SizedBox(height: 8),
            Text(
              'Amount: ₱${(tx['amount'] as double).toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Reference: ${tx['referenceNo']}'),
            const SizedBox(height: 16),
            const Text(
              'This will open the payment page where you left off.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Resuming payment for ${tx['referenceNo']}'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5D8AA8),
              foregroundColor: Colors.white,
            ),
            child: const Text('Resume Payment'),
          ),
        ],
      ),
    );
  }
}
