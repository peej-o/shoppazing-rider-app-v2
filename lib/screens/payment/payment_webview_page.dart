import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart'; // ✅ Import this

class PaymentWebViewPage extends StatefulWidget {
  final String paymentUrl;
  final VoidCallback? onPaymentComplete;

  const PaymentWebViewPage({
    super.key,
    required this.paymentUrl,
    this.onPaymentComplete,
  });

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
            debugPrint('🌐 Loading: $url');
          },
          onProgress: (int progress) {
            setState(() => _loadingProgress = progress / 100);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            debugPrint('✅ Page loaded: $url');
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('🔗 Navigation to: ${request.url}');

            // Check if payment completed
            if (_isPaymentSuccessUrl(request.url)) {
              widget.onPaymentComplete?.call();

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment completed successfully!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );

              // Navigate back to dashboard after delay
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  Navigator.popUntil(context, (route) => route.isFirst);
                }
              });

              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('❌ WebView error: ${error.description}');
            setState(() => _isLoading = false);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to load payment page: ${error.description}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  bool _isPaymentSuccessUrl(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('success') ||
        lowerUrl.contains('paid') ||
        lowerUrl.contains('completed') ||
        lowerUrl.contains('successful') ||
        lowerUrl.contains('thankyou');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GCash Payment'),
        backgroundColor: const Color(0xFF5D8AA8),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Show confirmation dialog before closing
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Cancel Payment'),
                content: const Text(
                  'Are you sure you want to cancel the payment?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('No'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Go back
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Yes'),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
            tooltip: 'Reload',
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              // Navigate back to dashboard
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            tooltip: 'Back to Dashboard',
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white.withValues(alpha: 0.8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF5D8AA8)),
                    const SizedBox(height: 16),
                    Text(
                      'Loading payment page...',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    if (_loadingProgress < 1.0) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _loadingProgress,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF5D8AA8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
