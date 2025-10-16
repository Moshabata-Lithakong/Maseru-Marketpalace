import 'dart:math'; // ADD THIS IMPORT for math functions
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:maseru_marketplace/src/services/api_service.dart';
import 'package:maseru_marketplace/src/models/product_model.dart';

// NEW: Enhanced OrderStatus enum
enum OrderStatus {
  pending('pending', 'Pending', '⏳'),
  confirmed('confirmed', 'Confirmed', '✅'),
  preparing('preparing', 'Preparing', '👨‍🍳'),
  ready('ready', 'Ready for Pickup', '📦'),
  delivering('delivering', 'On the Way', '🚗'),
  completed('completed', 'Completed', '🎉'),
  rejected('rejected', 'Rejected', '❌'),
  cancelled('cancelled', 'Cancelled', '🚫');

  final String value;
  final String displayName;
  final String emoji;

  const OrderStatus(this.value, this.displayName, this.emoji);

  factory OrderStatus.fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return OrderStatus.pending;
      case 'confirmed': return OrderStatus.confirmed;
      case 'preparing': return OrderStatus.preparing;
      case 'ready': return OrderStatus.ready;
      case 'delivering': return OrderStatus.delivering;
      case 'completed': return OrderStatus.completed;
      case 'rejected': return OrderStatus.rejected;
      case 'cancelled': return OrderStatus.cancelled;
      default: return OrderStatus.pending;
    }
  }
}

class Order {
  final String id;
  final Map<String, dynamic> passenger;
  final Map<String, dynamic> vendor;
  final Map<String, dynamic>? driver;
  final List<OrderItem> items;
  final String status;
  final double totalAmount;
  final double deliveryFee;
  final bool isUrgent;
  final PickupLocation pickupLocation;
  final DeliveryDestination destination;
  final PaymentInfo payment;
  final String? notes;
  final DateTime? estimatedDelivery;
  final DateTime? actualDelivery;
  final DateTime? pickupConfirmedAt;
  final DateTime? deliveryConfirmedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? taxiDriverId;
  final Map<String, dynamic>? deliveryLocation;

  Order({
    required this.id,
    required this.passenger,
    required this.vendor,
    this.driver,
    required this.items,
    required this.status,
    required this.totalAmount,
    required this.deliveryFee,
    required this.isUrgent,
    required this.pickupLocation,
    required this.destination,
    required this.payment,
    this.notes,
    this.estimatedDelivery,
    this.actualDelivery,
    this.pickupConfirmedAt,
    this.deliveryConfirmedAt,
    required this.createdAt,
    required this.updatedAt,
    this.taxiDriverId,
    this.deliveryLocation,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    try {
      Map<String, dynamic> parseUser(dynamic userData) {
        if (userData is String) {
          return {'_id': userData};
        }
        return userData as Map<String, dynamic>? ?? {'_id': ''};
      }

      return Order(
        id: json['_id'] as String? ?? json['id'] as String? ?? '',
        passenger: parseUser(json['passengerId']),
        vendor: parseUser(json['vendorId']),
        driver: json['taxiDriverId'] != null ? parseUser(json['taxiDriverId']) : null,
        items: (json['items'] as List<dynamic>? ?? [])
            .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
            .toList(),
        status: json['status'] as String? ?? 'pending',
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
        deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
        isUrgent: json['isUrgent'] as bool? ?? false,
        pickupLocation: PickupLocation.fromJson(json['pickupLocation'] as Map<String, dynamic>? ?? {}),
        destination: DeliveryDestination.fromJson(json['destination'] as Map<String, dynamic>? ?? {}),
        payment: PaymentInfo.fromJson(json['payment'] as Map<String, dynamic>? ?? {}),
        notes: json['notes'] as String?,
        estimatedDelivery: json['estimatedDelivery'] != null
            ? DateTime.tryParse(json['estimatedDelivery'] as String)
            : null,
        actualDelivery: json['actualDelivery'] != null
            ? DateTime.tryParse(json['actualDelivery'] as String)
            : null,
        pickupConfirmedAt: json['pickupConfirmedAt'] != null
            ? DateTime.tryParse(json['pickupConfirmedAt'] as String)
            : null,
        deliveryConfirmedAt: json['deliveryConfirmedAt'] != null
            ? DateTime.tryParse(json['deliveryConfirmedAt'] as String)
            : null,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
        taxiDriverId: json['taxiDriverId'] is String ? json['taxiDriverId'] as String? : null,
        deliveryLocation: json['deliveryLocation'] as Map<String, dynamic>?,
      );
    } catch (e) {
      print('❌ ERROR in Order.fromJson: $e');
      print('❌ JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'passengerId': passenger,
      'vendorId': vendor,
      'taxiDriverId': driver,
      'items': items.map((item) => item.toJson()).toList(),
      'status': status,
      'totalAmount': totalAmount,
      'deliveryFee': deliveryFee,
      'isUrgent': isUrgent,
      'pickupLocation': pickupLocation.toJson(),
      'destination': destination.toJson(),
      'payment': payment.toJson(),
      'notes': notes,
      'estimatedDelivery': estimatedDelivery?.toIso8601String(),
      'actualDelivery': actualDelivery?.toIso8601String(),
      'pickupConfirmedAt': pickupConfirmedAt?.toIso8601String(),
      'deliveryConfirmedAt': deliveryConfirmedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'taxiDriverId': taxiDriverId,
      'deliveryLocation': deliveryLocation,
    };
  }

  // NEW: Enhanced getters with OrderStatus enum
  OrderStatus get statusEnum => OrderStatus.fromString(status);
  String get displayTotal => 'LSL ${totalAmount.toStringAsFixed(2)}';
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isPreparing => status == 'preparing';
  bool get isReady => status == 'ready';
  bool get isDelivering => status == 'delivering';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get requiresDelivery => destination.coordinates != null;
  bool get isPaymentPending => payment.status == 'pending';
  bool get isPaymentCompleted => payment.status == 'completed';
  bool get isPaymentFailed => payment.status == 'failed';
  
  // NEW: Helper methods for driver
  bool get isActiveForDriver => isDelivering || isReady;
  bool get canBeAccepted => (isConfirmed || isReady) && (taxiDriverId == null || taxiDriverId!.isEmpty);
  
  // NEW: Location display helpers
  String get pickupDisplayText {
    if (pickupLocation.vendorName != null) {
      return '${pickupLocation.vendorName} - ${pickupLocation.address}';
    }
    return pickupLocation.address;
  }
  
  String get destinationDisplayText {
    if (destination.passengerName != null) {
      return '${destination.passengerName} - ${destination.address}';
    }
    return destination.address;
  }

  // NEW: Add missing properties for driver dashboard
  String get passengerId => passenger['_id'] ?? passenger['id'] ?? '';
  String get passengerName => passenger['profile']?['firstName'] ?? 
                              passenger['firstName'] ?? 
                              passenger['name'] ?? 
                              passenger['username'] ?? 
                              'Passenger';
                              
  String get vendorId => vendor['_id'] ?? vendor['id'] ?? '';
  String get vendorName => vendor['profile']?['firstName'] ?? 
                          vendor['firstName'] ?? 
                          vendor['name'] ?? 
                          vendor['username'] ?? 
                          'Vendor';

  // NEW: Enhanced delivery information for drivers
  String get deliveryInstructions => destination.instructions ?? 'No special instructions';
  String get passengerPhone => destination.passengerPhone ?? 'Not provided';
  String get vendorPhone => pickupLocation.vendorPhone ?? 'Not provided';

  // NEW: Time helpers
  String get createdAtFormatted {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  // NEW: Status color helper
  Color get statusColor {
    switch (statusEnum) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.purple;
      case OrderStatus.ready:
        return Colors.teal;
      case OrderStatus.delivering:
        return Colors.indigo;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.rejected:
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  // NEW: Check if order can be cancelled by passenger
  bool get canPassengerCancel => isPending || isConfirmed;

  // NEW: Calculate items count
  int get itemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  // NEW: Get delivery status for display
  String get deliveryStatusDisplay {
    switch (statusEnum) {
      case OrderStatus.pending:
        return 'Waiting for vendor confirmation';
      case OrderStatus.confirmed:
        return 'Order confirmed by vendor';
      case OrderStatus.preparing:
        return 'Vendor is preparing your order';
      case OrderStatus.ready:
        return 'Ready for pickup by driver';
      case OrderStatus.delivering:
        return 'On the way to you';
      case OrderStatus.completed:
        return 'Delivered successfully';
      case OrderStatus.rejected:
        return 'Order was rejected';
      case OrderStatus.cancelled:
        return 'Order was cancelled';
    }
  }
}

class PickupLocation {
  final String address;
  final LocationCoordinates coordinates;
  final String? vendorName;
  final String? vendorPhone;

  PickupLocation({
    required this.address,
    required this.coordinates,
    this.vendorName,
    this.vendorPhone,
  });

  factory PickupLocation.fromJson(Map<String, dynamic> json) {
    try {
      return PickupLocation(
        address: json['address'] as String? ?? '',
        coordinates: LocationCoordinates.fromJson(json['coordinates'] as Map<String, dynamic>? ?? {}),
        vendorName: json['vendorName'] as String?,
        vendorPhone: json['vendorPhone'] as String?,
      );
    } catch (e) {
      print('❌ ERROR in PickupLocation.fromJson: $e');
      print('❌ JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'coordinates': coordinates.toJson(),
      'vendorName': vendorName,
      'vendorPhone': vendorPhone,
    };
  }

  // NEW: Display helper
  String get displayText {
    if (vendorName != null) {
      return '$vendorName - $address';
    }
    return address;
  }

  // NEW: Get coordinates for maps
  Map<String, double> get coordinatesMap {
    return {
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
    };
  }
}

class DeliveryDestination {
  final String address;
  final LocationCoordinates coordinates;
  final String? instructions;
  final String? passengerName;
  final String? passengerPhone;

  DeliveryDestination({
    required this.address,
    required this.coordinates,
    this.instructions,
    this.passengerName,
    this.passengerPhone,
  });

  factory DeliveryDestination.fromJson(Map<String, dynamic> json) {
    try {
      return DeliveryDestination(
        address: json['address'] as String? ?? '',
        coordinates: LocationCoordinates.fromJson(json['coordinates'] as Map<String, dynamic>? ?? {}),
        instructions: json['instructions'] as String?,
        passengerName: json['passengerName'] as String?,
        passengerPhone: json['passengerPhone'] as String?,
      );
    } catch (e) {
      print('❌ ERROR in DeliveryDestination.fromJson: $e');
      print('❌ JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'coordinates': coordinates.toJson(),
      'instructions': instructions,
      'passengerName': passengerName,
      'passengerPhone': passengerPhone,
    };
  }

  // NEW: Display helper
  String get displayText {
    if (passengerName != null) {
      return '$passengerName - $address';
    }
    return address;
  }

  // NEW: Get coordinates for maps
  Map<String, double> get coordinatesMap {
    return {
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
    };
  }

  // NEW: Check if delivery location is valid
  bool get hasValidCoordinates => 
      coordinates.latitude != 0.0 && coordinates.longitude != 0.0;
}

class LocationCoordinates {
  final double latitude;
  final double longitude;

  LocationCoordinates({
    required this.latitude,
    required this.longitude,
  });

  factory LocationCoordinates.fromJson(Map<String, dynamic> json) {
    try {
      return LocationCoordinates(
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e) {
      print('❌ ERROR in LocationCoordinates.fromJson: $e');
      print('❌ JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // NEW: Check if coordinates are valid
  bool get isValid => latitude != 0.0 && longitude != 0.0;

  // FIXED: Get distance between two coordinates using dart:math
  double distanceTo(LocationCoordinates other) {
    final lat1 = latitude * pi / 180;
    final lon1 = longitude * pi / 180;
    final lat2 = other.latitude * pi / 180;
    final lon2 = other.longitude * pi / 180;

    final dlat = lat2 - lat1;
    final dlon = lon2 - lon1;

    final a = 
        sin(dlat / 2) * sin(dlat / 2) +
        cos(lat1) * cos(lat2) * 
        sin(dlon / 2) * sin(dlon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return (6371 * c).toDouble(); // Distance in kilometers
  }
}

class PaymentInfo {
  final String method;
  final String status;
  final String? transactionId;
  final String? phoneNumber;
  final double amount;
  final DateTime? paymentDate;

  PaymentInfo({
    required this.method,
    required this.status,
    this.transactionId,
    this.phoneNumber,
    required this.amount,
    this.paymentDate,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    try {
      return PaymentInfo(
        method: json['method'] as String? ?? 'cash',
        status: json['status'] as String? ?? 'pending',
        transactionId: json['transactionId'] as String?,
        phoneNumber: json['phoneNumber'] as String?,
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        paymentDate: json['paymentDate'] != null
            ? DateTime.tryParse(json['paymentDate'] as String)
            : null,
      );
    } catch (e) {
      print('❌ ERROR in PaymentInfo.fromJson: $e');
      print('❌ JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'status': status,
      'transactionId': transactionId,
      'phoneNumber': phoneNumber,
      'amount': amount,
      'paymentDate': paymentDate?.toIso8601String(),
    };
  }

  bool get isCash => method == 'cash';
  bool get isMpesa => method == 'mpesa';
  bool get isEcocash => method == 'ecocash';
  bool get isProcessing => status == 'processing';
  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';

  // NEW: Payment method display
  String get methodDisplay {
    switch (method) {
      case 'cash':
        return 'Cash on Delivery';
      case 'mpesa':
        return 'M-Pesa';
      case 'ecocash':
        return 'EcoCash';
      default:
        return method;
    }
  }

  // NEW: Payment status display
  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      default:
        return status;
    }
  }
}

class OrderItem {
  final String productId;
  final ProductName productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    try {
      return OrderItem(
        productId: json['productId'] as String? ?? '',
        productName: ProductName.fromJson(json['productName'] as Map<String, dynamic>? ?? {}),
        quantity: json['quantity'] as int? ?? 0,
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e) {
      print('❌ ERROR in OrderItem.fromJson: $e');
      print('❌ JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName.toJson(),
      'quantity': quantity,
      'price': price,
    };
  }

  double get subtotal => quantity * price;

  // NEW: Display helpers
  String get displayName => productName.en;
  String get displaySubtotal => 'LSL ${subtotal.toStringAsFixed(2)}';
  String get displayPrice => 'LSL ${price.toStringAsFixed(2)}';
}