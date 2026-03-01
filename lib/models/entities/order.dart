// lib/models/entities/order.dart
import 'package:intl/intl.dart';

class OrderData {
  final int serverHeaderId;
  final String orderNumber;
  final String status;
  final String dateTimeCreated;
  final String storeName;
  final String storeImageUrl;
  final String storeAddress;
  final String customerName;
  final String customerAddress;
  final String customerMobileNo;
  final double storeLat;
  final double storeLng;
  final double customerLat;
  final double customerLng;
  final double deliveryFee;
  final double onlineServiceCharge;
  final double subTotal;
  final String totalDue;
  final List<dynamic> rawDetails;
  final String? assignedTo;
  final String? OtherChatUserFirebaseUID;
  final String? OtherChatUserName;
  final String? OtherChatUserId;
  final String? customerPin;
  final bool isPaid;
  final bool isManualDelivered;
  final bool isOrderRated;
  final int? paymentTypeId;
  final int? onlinePaymentTypeId;
  final bool useLoyaltyPoints;
  final int? saleHeaderId;
  final double redeemedCash;
  final double dfDiscount;
  final String? riderProfilePic;
  final String? riderFullName;
  final String? riderPlateNo;
  final String? riderDriversLicenseNo;
  final String? riderUserId;
  final double? riderLat;
  final double? riderLng;

  OrderData({
    required this.serverHeaderId,
    required this.orderNumber,
    required this.status,
    required this.dateTimeCreated,
    required this.storeName,
    required this.storeImageUrl,
    required this.storeAddress,
    required this.customerName,
    required this.customerAddress,
    required this.customerMobileNo,
    required this.storeLat,
    required this.storeLng,
    required this.customerLat,
    required this.customerLng,
    required this.deliveryFee,
    required this.onlineServiceCharge,
    required this.subTotal,
    required this.totalDue,
    required this.rawDetails,
    this.assignedTo,
    this.OtherChatUserFirebaseUID,
    this.OtherChatUserName,
    this.OtherChatUserId,
    this.customerPin,
    this.isPaid = false,
    this.isManualDelivered = false,
    this.isOrderRated = false,
    this.paymentTypeId,
    this.onlinePaymentTypeId,
    this.useLoyaltyPoints = false,
    this.saleHeaderId,
    this.redeemedCash = 0.0,
    this.dfDiscount = 0.0,
    this.riderProfilePic,
    this.riderFullName,
    this.riderPlateNo,
    this.riderDriversLicenseNo,
    this.riderUserId,
    this.riderLat,
    this.riderLng,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    String formattedTime = '';
    if (json['OrderDate'] != null) {
      try {
        DateTime parsedDate = DateTime.parse(json['OrderDate']);
        formattedTime = DateFormat('HH:mm:ss').format(parsedDate);
      } catch (e) {
        print('Error parsing date: ${json['OrderDate']}');
      }
    }

    return OrderData(
      serverHeaderId: int.tryParse(json['ServerHeaderId']?.toString() ?? '0') ?? 0,
      orderNumber: json['OrderNo']?.toString() ?? '',
      status: json['OrderStatusId']?.toString() ?? '',
      dateTimeCreated: formattedTime,
      storeName: json['StoreName']?.toString() ?? 'N/A',
      storeImageUrl: json['StoreImageUrl']?.toString() ?? '',
      storeAddress: json['StoreAddress']?.toString() ?? 'N/A',
      customerName: json['CustomerName']?.toString() ?? '',
      customerAddress: json['CustomerAddressLine1']?.toString() ?? '',
      customerMobileNo: json['CustomerMobileNo']?.toString() ?? '',
      storeLat: double.tryParse(json['StoreLat']?.toString() ?? '0') ?? 0.0,
      storeLng: double.tryParse(json['StoreLng']?.toString() ?? '0') ?? 0.0,
      customerLat: double.tryParse(json['CustomerLAT']?.toString() ?? '0') ?? 0.0,
      customerLng: double.tryParse(json['CustomerLNG']?.toString() ?? '0') ?? 0.0,
      deliveryFee: double.tryParse(json['DeliveryFee']?.toString() ?? '0') ?? 0.0,
      onlineServiceCharge: double.tryParse(json['OnlineServiceCharge']?.toString() ?? '0') ?? 0.0,
      subTotal: double.tryParse(json['SubTotal']?.toString() ?? '0') ?? 0.0,
      totalDue: json['TotalDue']?.toString() ?? '0',
      rawDetails: json['OrderDetails'] is List ? json['OrderDetails'] : [],
      assignedTo: json['AssignedTo']?.toString(),
      OtherChatUserFirebaseUID: json['OtherChatUserFirebaseUID']?.toString(),
      OtherChatUserName: json['OtherChatUserName']?.toString(),
      OtherChatUserId: json['UserId']?.toString(),
      customerPin: json['CustomerPIN']?.toString(),
      isPaid: (json['IsPaid'] as bool?) ?? false,
      isManualDelivered: (json['IsManualDelivered'] as bool?) ?? false,
      isOrderRated: (json['IsOrderRated'] as bool?) ?? false,
      paymentTypeId: int.tryParse(json['PaymentTypeId']?.toString() ?? '') ?? null,
      onlinePaymentTypeId: int.tryParse(json['OnlinePaymentTypeId']?.toString() ?? '') ?? null,
      useLoyaltyPoints: (json['UseLoyaltyPoints'] as bool?) ?? false,
      saleHeaderId: int.tryParse(json['SaleHeaderId']?.toString() ?? '') ?? null,
      redeemedCash: double.tryParse(json['RedeemedCash']?.toString() ?? '0') ?? 0.0,
      dfDiscount: double.tryParse(json['DFDiscount']?.toString() ?? '0') ?? 0.0,
      riderProfilePic: json['RiderProfilePic']?.toString(),
      riderFullName: json['RiderFullName']?.toString(),
      riderPlateNo: json['RiderPlateNo']?.toString(),
      riderDriversLicenseNo: json['RiderDriversLicenseNo']?.toString(),
      riderUserId: json['RiderUserId']?.toString(),
      riderLat: double.tryParse(json['RiderLat']?.toString() ?? '') ?? null,
      riderLng: double.tryParse(json['RiderLng']?.toString() ?? '') ?? null,
    );
  }
}