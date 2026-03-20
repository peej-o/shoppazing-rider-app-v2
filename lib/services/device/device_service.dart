import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/api_config.dart';

class DeviceService {
  static Future<Position?> getCurrentLocation(BuildContext context) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      print('[ERROR] getCurrentLocation: $e');
      return null;
    }
  }

  static Future<bool> updateDeviceInfo(
    String userId,
    BuildContext context,
  ) async {
    try {
      final position = await getCurrentLocation(context);

      if (position == null) return false;

      final response = await ApiClient.post(
        ApiConfig.apiUri('/postridertoken'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'UserId': userId,
          'Lat': position.latitude,
          'Lng': position.longitude,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('[ERROR] updateDeviceInfo: $e');
      return false;
    }
  }

  static Future<String?> getFirebaseUID() async {
    // Return a mock UID for now
    return 'mock_uid_${DateTime.now().millisecondsSinceEpoch}';
  }
}
