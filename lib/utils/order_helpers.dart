import 'package:flutter/material.dart';

String getOrderStatusLabel(String statusId) {
  switch (statusId) {
    case '0':
    case '1':
      return 'Pending';
    case '2':
      return 'Confirmed';
    case '3':
      return 'Preparing';
    case '4':
      return 'Ready';
    case '6':
      return 'In Transit';
    case '7':
      return 'Delivered';
    case '8':
      return 'Cancelled';
    default:
      return 'Unknown';
  }
}

Color getOrderStatusColor(String statusId) {
  switch (statusId) {
    case '0':
    case '1':
    case '2':
      return Colors.blue;
    case '3':
    case '4':
      return Colors.orange;
    case '6':
    case '7':
      return Colors.green;
    case '8':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

// Modifier helpers (kukunin natin later from riderV1)
List<Map<String, dynamic>> extractModifiers(Map<String, dynamic> item) {
  // We'll implement this later
  return [];
}

String readModifierValue(Map<String, dynamic> mod, String targetKey) {
  // We'll implement this later
  return '';
}

double readModifierPrice(Map<String, dynamic> mod) {
  // We'll implement this later
  return 0.0;
}