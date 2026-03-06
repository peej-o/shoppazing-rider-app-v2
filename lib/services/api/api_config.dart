// lib/services/api/api_config.dart
class ApiConfig {
  // Toggle this for debugging vs production
  static bool get isDebug => true; // Make sure this is true

  // From riderV1 api_config.dart
  static const String testOrigin = 'http://jaramburo19-001-site11.ftempurl.com';
  static const String sellerCenterOrigin =
      'https://sellercenter.shoppazing.com';

  // Base origin based on environment
  static String get baseOrigin => isDebug ? testOrigin : sellerCenterOrigin;

  // Common base paths
  static String get baseUrl => baseOrigin + '/api';
  static String get apiBase => baseOrigin + '/api/shop';
  static String get tokenUrl => baseOrigin + '/api/token';
  static String get paymentStartLoadPurchase =>
      baseOrigin + '/OnlinePayment/StartLoadPurchase';

  // Helper methods
  static Uri apiUri(String path) {
    final normalized = path.startsWith('/') ? path : '/' + path;
    final url = apiBase + normalized;
    print('[DEBUG] API URL: $url'); // Add this for debugging
    return Uri.parse(url);
  }

  static Uri absolute(String pathOrUrl) {
    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      return Uri.parse(pathOrUrl);
    }
    final normalized = pathOrUrl.startsWith('/') ? pathOrUrl : '/' + pathOrUrl;
    return Uri.parse(baseOrigin + normalized);
  }
}
