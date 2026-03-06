// lib/services/utils/network_service.dart
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkService {
  static final Connectivity _connectivity = Connectivity();

  static Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }
      try {
        final result = await InternetAddress.lookup('google.com');
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } catch (e) {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static String getNetworkErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'Network error. Please check your internet connection.';
    } else if (error.toString().contains('Failed host lookup')) {
      return 'No internet connection. Please check your data or WiFi.';
    } else if (error.toString().contains('Connection refused')) {
      return 'Unable to connect to server. Please try again later.';
    } else if (error.toString().contains('Connection timed out')) {
      return 'Connection timed out. Please check your internet connection.';
    } else {
      return 'Network error. Please check your internet connection.';
    }
  }

  static void showNetworkErrorSnackBar(
    BuildContext context, {
    String? customMessage,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.wifi_off, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                customMessage ??
                    'No internet connection. Please check your data or WiFi.',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
