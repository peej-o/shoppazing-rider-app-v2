import 'package:flutter/material.dart';
import '../../widgets/cards/dashboard_card.dart';
import '../../widgets/cards/transaction_card.dart';
import '../../widgets/modals/top_up_sheet.dart';
import '../payment/transaction_history_page.dart';
import '../payment/payment_webview_page.dart';
import '../../services/dashboard/dashboard_service.dart';
import '../../services/database/rider_orders_db.dart';
import '../../services/database/user_session_db.dart';
import '../../services/api/api_config.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Real data from API
  double _balance = 0.0;
  int _ongoing = 0;
  double _earnings = 0.0;
  int _completed = 0;
  List<Map<String, dynamic>> _pendingLoads = [];
  List<Map<String, dynamic>> _recentTransactions = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _loadTransactions();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await DashboardService.fetchDashboardData();

      if (mounted) {
        setState(() {
          _balance = data['balance'];
          _ongoing = data['ongoing'];
          _earnings = data['earnings'];
          _completed = data['completed'];
          _isLoading = false;
        });
        print(
          '[DEBUG] Dashboard loaded: Balance: $_balance, Ongoing: $_ongoing, Earnings: $_earnings, Completed: $_completed',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
        print('[ERROR] Failed to load dashboard: $e');
      }
    }
  }

  Future<void> _loadTransactions() async {
    try {
      final transactions = await DashboardService.getLoadTransactions();

      // Filter pending loads (unconfirmed transactions)
      final pending = transactions
          .where((tx) => tx['isConfirmed'] == false)
          .toList();
      final recent = transactions.take(3).toList();

      if (mounted) {
        setState(() {
          _pendingLoads = pending;
          _recentTransactions = recent;
        });
      }

      print(
        '[DEBUG] Loaded ${transactions.length} transactions, ${pending.length} pending',
      );

      // Save to local DB for offline access
      await RiderOrdersDB.saveLoadTransactions(transactions);
    } catch (e) {
      print('[ERROR] Loading transactions: $e');
      // Try to load from local DB as fallback
      try {
        final localTxs = await RiderOrdersDB.getLoadTransactions();
        if (mounted && localTxs.isNotEmpty) {
          setState(() {
            _recentTransactions = localTxs.take(3).toList();
          });
          print('[DEBUG] Loaded ${localTxs.length} transactions from local DB');
        }
      } catch (dbError) {
        print('[ERROR] Loading from local DB: $dbError');
      }
    }
  }

  Future<void> _refreshDashboard() async {
    await _loadDashboardData();
    await _loadTransactions();
  }

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
        _processTopUp(amount);
      }
    });
  }

  Future<void> _processTopUp(int amount) async {
    try {
      final session = await UserSessionDB.getSession();
      final riderId = session?['rider_id'] ?? '';
      final mobileNo = session?['mobile_no'] ?? '';
      final email = session?['email'] ?? '';

      if (riderId.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User session not found')));
        return;
      }

      // TODO: Call postLoadRiderWallet API to get order number
      // For now, use a mock order number
      final orderNo = 'REF${DateTime.now().millisecondsSinceEpoch}';

      final url =
          '${ApiConfig.paymentStartLoadPurchase}?Id=16&PROC_ID=GCSH&amount=$amount&PhoneNumber=$mobileNo&email=$email&LoadRefNo=$orderNo';

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentWebViewPage(
            paymentUrl: url,
            onPaymentComplete: () async {
              // Refresh data after payment
              await _refreshDashboard();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment completed! Balance updated.'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ),
      );

      // Refresh after returning from payment
      await _refreshDashboard();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Top up failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showTransactionHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TransactionHistoryPage()),
    ).then((_) {
      // Refresh when returning from transaction history
      _refreshDashboard();
    });
  }

  void _resumePayment(Map<String, dynamic> transaction) {
    // TODO: Implement resume payment flow
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Resume payment for ${transaction['referenceNo']}'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF5D8AA8)),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _refreshDashboard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D8AA8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        color: const Color(0xFF5D8AA8),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Low balance warning banner
                  if (_isBalanceLow()) _buildBalanceWarningBanner(),

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
                          onPressed: _showTopUpModal,
                          icon: const Icon(Icons.add_circle_outline, size: 18),
                          label: const Text(
                            'Top Up',
                            style: TextStyle(fontSize: 14),
                          ),
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
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        if (_pendingLoads.isNotEmpty) ...[
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
                              '${_pendingLoads.length} Pending',
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
                          onPressed: _showTransactionHistory,
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF5D8AA8),
                          ),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Transaction List
                  if (_recentTransactions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No recent transactions',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._recentTransactions.map(
                      (tx) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TransactionCard(
                          referenceNo: tx['referenceNo'] ?? 'N/A',
                          amount: (tx['amount'] as num?)?.toDouble() ?? 0.0,
                          date: _formatDate(tx['date']),
                          remarks: tx['remarks'] ?? 'Load purchase',
                          isConfirmed: tx['isConfirmed'] == true,
                          onTap: () {
                            if (!tx['isConfirmed']) {
                              _resumePayment(tx);
                            }
                          },
                        ),
                      ),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
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
