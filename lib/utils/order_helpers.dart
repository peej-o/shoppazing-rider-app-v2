import 'package:flutter/material.dart';
import '../../models/entities/order.dart';

// ============ STATUS HELPERS ============

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

// Check if order is pending (can be accepted)
bool isOrderPending(OrderData order) {
  return order.status == '0' || order.status == '1';
}

// Check if order is ready for pickup
bool isOrderReady(OrderData order) {
  return order.status == '4';
}

// Check if order is in transit
bool isOrderInTransit(OrderData order) {
  return order.status == '6';
}

// Check if order is active (not delivered or cancelled)
bool isOrderActive(OrderData order) {
  return order.status != '7' && order.status != '8';
}

// Check if order can be cancelled
bool canCancelOrder(OrderData order) {
  return order.status != '7' && order.status != '8';
}

// ============ ACTION HELPERS ============

// Get available actions for an order based on its status
List<String> getAvailableActions(OrderData order) {
  final actions = <String>[];

  switch (order.status) {
    case '0':
    case '1': // Pending
      actions.add('accept');
      break;

    case '4': // Ready for pickup
      actions.add('pickup_pin');
      actions.add('cancel');
      break;

    case '6': // In Transit
      actions.add('delivery_pin');
      break;

    case '7': // Delivered
    case '8': // Cancelled
      // No actions available
      break;
  }

  return actions;
}

// ============ BUTTON HELPERS ============

String getButtonText(String action) {
  switch (action) {
    case 'accept':
      return 'Accept Order';
    case 'pickup_pin':
      return 'Pickup via PIN';
    case 'delivery_pin':
      return 'Delivered';
    case 'cancel':
      return 'Cancel Order';
    default:
      return action;
  }
}

IconData getButtonIcon(String action) {
  switch (action) {
    case 'accept':
      return Icons.check_circle;
    case 'pickup_pin':
      return Icons.qr_code_scanner;
    case 'delivery_pin':
      return Icons.check_circle;
    case 'cancel':
      return Icons.cancel;
    default:
      return Icons.help;
  }
}

Color getButtonColor(String action) {
  switch (action) {
    case 'accept':
      return const Color(0xFF00509D);
    case 'pickup_pin':
      return const Color(0xFF00509D);
    case 'delivery_pin':
      return Colors.green;
    case 'cancel':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

// ============ MODIFIER HELPERS ============

List<Map<String, dynamic>> extractModifiers(Map<String, dynamic> item) {
  final dynamic direct = item['OrderDetailModifiers'] ?? item['Modifiers'];
  if (direct is List && direct.isNotEmpty) {
    return direct
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .cast<Map<String, dynamic>>()
        .toList();
  }

  for (final entry in item.entries) {
    final value = entry.value;
    if (value is List) {
      final asMaps = value.whereType<Map>().toList();
      if (asMaps.isNotEmpty) {
        final hasModifierKeys = asMaps.first.keys.any((k) {
          final lower = k.toString().toLowerCase();
          return lower.contains('modifiername') ||
              lower.contains('modifieroptionname');
        });
        if (hasModifierKeys) {
          return asMaps
              .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
              .cast<Map<String, dynamic>>()
              .toList();
        }
      }
    }
  }
  return <Map<String, dynamic>>[];
}

String readModifierValue(Map<String, dynamic> mod, String targetKey) {
  if (mod.isEmpty) return '';
  final String targetLower = targetKey.toLowerCase();

  for (final entry in mod.entries) {
    if (entry.key.toString().toLowerCase() == targetLower) {
      final val = entry.value?.toString().trim();
      if (val != null && val.isNotEmpty && val.toLowerCase() != 'n/a') {
        return val;
      }
      return '';
    }
  }

  for (final entry in mod.entries) {
    final keyLower = entry.key.toString().toLowerCase();
    if (keyLower.contains(targetLower)) {
      final val = entry.value?.toString().trim();
      if (val != null && val.isNotEmpty && val.toLowerCase() != 'n/a') {
        return val;
      }
    }
  }

  return '';
}

double readModifierPrice(Map<String, dynamic> mod) {
  if (mod.isEmpty) return 0.0;
  final priceKeys = ['Price', 'ModifierPrice', 'OptionPrice', 'UnitPrice'];

  for (final key in priceKeys) {
    final priceValue = readModifierValue(mod, key);
    if (priceValue.isNotEmpty) {
      final price = double.tryParse(priceValue);
      if (price != null && price > 0) {
        return price;
      }
    }
  }
  return 0.0;
}
