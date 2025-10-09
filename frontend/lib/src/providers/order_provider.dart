import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:maseru_marketplace/src/services/api_service.dart';
import 'package:maseru_marketplace/src/models/product_model.dart';

class Order {
  final String id;
  final String passengerId;
  final String vendorId;
  final String? taxiDriverId;
  final List<OrderItem> items;
  final String status;
  final double totalAmount;
  final double deliveryFee;
  final bool isUrgent;
  final String? deliveryAddress;
  
  // UPDATED: Enhanced pickup location with coordinates
  final PickupLocation pickupLocation;
  
  // UPDATED: Enhanced destination with coordinates and instructions
  final DeliveryDestination destination;
  
  // NEW: Payment information
  final PaymentInfo payment;
  
  final String? notes;
  final DateTime? estimatedDelivery;
  final DateTime? actualDelivery;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.passengerId,
    required this.vendorId,
    this.taxiDriverId,
    required this.items,
    required this.status,
    required this.totalAmount,
    required this.deliveryFee,
    required this.isUrgent,
    this.deliveryAddress,
    required this.pickupLocation,
    required this.destination,
    required this.payment,
    this.notes,
    this.estimatedDelivery,
    this.actualDelivery,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      passengerId: json['passengerId'] as String? ?? '',
      vendorId: json['vendorId'] as String? ?? '',
      taxiDriverId: json['taxiDriverId'] as String?,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String? ?? 'pending',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      isUrgent: json['isUrgent'] as bool? ?? false,
      deliveryAddress: json['deliveryAddress'] as String?,
      
      // UPDATED: Enhanced pickup location parsing
      pickupLocation: PickupLocation.fromJson(
        json['pickupLocation'] as Map<String, dynamic>? ?? {},
      ),
      
      // UPDATED: Enhanced destination parsing
      destination: DeliveryDestination.fromJson(
        json['destination'] as Map<String, dynamic>? ?? {},
      ),
      
      // NEW: Payment info parsing
      payment: PaymentInfo.fromJson(
        json['payment'] as Map<String, dynamic>? ?? {},
      ),
      
      notes: json['notes'] as String?,
      estimatedDelivery: json['estimatedDelivery'] != null
          ? DateTime.tryParse(json['estimatedDelivery'] as String)
          : null,
      actualDelivery: json['actualDelivery'] != null
          ? DateTime.tryParse(json['actualDelivery'] as String)
          : null,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'passengerId': passengerId,
      'vendorId': vendorId,
      'taxiDriverId': taxiDriverId,
      'items': items.map((item) => item.toJson()).toList(),
      'status': status,
      'totalAmount': totalAmount,
      'deliveryFee': deliveryFee,
      'isUrgent': isUrgent,
      'deliveryAddress': deliveryAddress,
      'pickupLocation': pickupLocation.toJson(),
      'destination': destination.toJson(),
      'payment': payment.toJson(),
      'notes': notes,
      'estimatedDelivery': estimatedDelivery?.toIso8601String(),
      'actualDelivery': actualDelivery?.toIso8601String(),
    };
  }

  String get displayTotal => 'LSL ${totalAmount.toStringAsFixed(2)}';
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isPreparing => status == 'preparing';
  bool get isReady => status == 'ready';
  bool get isDelivering => status == 'delivering';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get requiresDelivery => deliveryAddress != null;
  
  // NEW: Payment status helpers
  bool get isPaymentPending => payment.status == 'pending';
  bool get isPaymentCompleted => payment.status == 'completed';
  bool get isPaymentFailed => payment.status == 'failed';
}

// NEW: Enhanced pickup location class
class PickupLocation {
  final String address;
  final LocationCoordinates? coordinates;
  final String? vendorName;
  final String? vendorPhone;

  PickupLocation({
    required this.address,
    this.coordinates,
    this.vendorName,
    this.vendorPhone,
  });

  factory PickupLocation.fromJson(Map<String, dynamic> json) {
    return PickupLocation(
      address: json['address'] as String? ?? '',
      coordinates: json['coordinates'] != null 
          ? LocationCoordinates.fromJson(json['coordinates'] as Map<String, dynamic>)
          : null,
      vendorName: json['vendorName'] as String?,
      vendorPhone: json['vendorPhone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'coordinates': coordinates?.toJson(),
      'vendorName': vendorName,
      'vendorPhone': vendorPhone,
    };
  }
}

// NEW: Enhanced delivery destination class
class DeliveryDestination {
  final String address;
  final LocationCoordinates? coordinates;
  final String? instructions;
  final String? passengerName;
  final String? passengerPhone;

  DeliveryDestination({
    required this.address,
    this.coordinates,
    this.instructions,
    this.passengerName,
    this.passengerPhone,
  });

  factory DeliveryDestination.fromJson(Map<String, dynamic> json) {
    return DeliveryDestination(
      address: json['address'] as String? ?? '',
      coordinates: json['coordinates'] != null 
          ? LocationCoordinates.fromJson(json['coordinates'] as Map<String, dynamic>)
          : null,
      instructions: json['instructions'] as String?,
      passengerName: json['passengerName'] as String?,
      passengerPhone: json['passengerPhone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'coordinates': coordinates?.toJson(),
      'instructions': instructions,
      'passengerName': passengerName,
      'passengerPhone': passengerPhone,
    };
  }
}

// NEW: Location coordinates class
class LocationCoordinates {
  final double latitude;
  final double longitude;

  LocationCoordinates({
    required this.latitude,
    required this.longitude,
  });

  factory LocationCoordinates.fromJson(Map<String, dynamic> json) {
    return LocationCoordinates(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

// NEW: Payment information class
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
    return OrderItem(
      productId: json['productId'] as String? ?? '',
      productName: ProductName.fromJson(json['productName'] as Map<String, dynamic>? ?? {}),
      quantity: json['quantity'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
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
}

class OrderProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Order> _orders = [];
  List<Order> _vendorOrders = [];
  List<Order> _driverOrders = [];
  bool _isLoading = false;
  String? _error;

  // NEW: Earnings tracking properties
  double _pendingEarnings = 0.0;
  Map<String, double> _earningsBreakdown = {
    'today': 0.0,
    'thisWeek': 0.0,
    'thisMonth': 0.0,
    'allTime': 0.0,
  };

  OrderProvider(this._apiService);

  List<Order> get orders => _orders;
  List<Order> get vendorOrders => _vendorOrders;
  List<Order> get driverOrders => _driverOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // NEW: Add the missing properties that were causing errors
  double get pendingEarnings => _pendingEarnings;
  Map<String, double> get earningsBreakdown => _earningsBreakdown;

  // UPDATED: Create order with enhanced location and payment
  Future<bool> createOrder({
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required String destinationAddress,
    required String paymentMethod,
    String? pickupAddress,
    String? destinationInstructions,
    double? destinationLatitude,
    double? destinationLongitude,
    double? pickupLatitude,
    double? pickupLongitude,
    String? phoneNumber,
    bool isUrgent = false,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    // Safe notifyListeners
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());

    try {
      // Build enhanced destination
      final destination = {
        'address': destinationAddress,
        if (destinationInstructions != null) 'instructions': destinationInstructions,
        if (destinationLatitude != null && destinationLongitude != null)
          'coordinates': {
            'latitude': destinationLatitude,
            'longitude': destinationLongitude,
          },
      };

      // Build enhanced pickup location (use vendor's location or provided address)
      final pickupLocation = {
        'address': pickupAddress ?? 'Vendor Location', // Default to vendor location
        if (pickupLatitude != null && pickupLongitude != null)
          'coordinates': {
            'latitude': pickupLatitude,
            'longitude': pickupLongitude,
          },
      };

      // Build payment info
      final payment = {
        'method': paymentMethod,
        if (phoneNumber != null && (paymentMethod == 'mpesa' || paymentMethod == 'ecocash'))
          'phoneNumber': phoneNumber,
      };

      final data = {
        'items': items,
        'totalAmount': totalAmount,
        'pickupLocation': pickupLocation,
        'destination': destination,
        'payment': payment,
        'isUrgent': isUrgent,
        'notes': notes,
        'deliveryFee': isUrgent ? 25.0 : 15.0, // Example delivery fees
      };

      print('📦 Creating order with enhanced locations and payment');
      final response = await _apiService.post('orders', data);
      
      _isLoading = false;
      
      if (response['status'] == 'success') {
        final newOrder = Order.fromJson(response['data']?['order'] ?? response);
        _orders.add(newOrder);
        // Safe notifyListeners
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
        return true;
      } else {
        _error = response['message'] ?? 'Failed to create order';
        // Safe notifyListeners
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error creating order: $e';
      // Safe notifyListeners
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      return false;
    }
  }

  // UPDATED: Load passenger orders with safe state updates
  Future<void> loadPassengerOrders() async {
    _isLoading = true;
    _error = null;
    // Safe notifyListeners
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());

    try {
      final response = await _apiService.get('orders/my-orders');
      if (response['status'] == 'success') {
        final ordersData = response['data']?['orders'] as List? ?? [];
        _orders = ordersData.map((orderJson) => Order.fromJson(orderJson)).toList();
        _error = null;
      } else {
        _error = response['message'] ?? 'Failed to load orders';
      }
    } catch (e) {
      _error = 'Error loading orders: $e';
    } finally {
      _isLoading = false;
      // Safe notifyListeners
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }

  // UPDATED: Load vendor orders with safe state updates
  Future<void> loadVendorOrders() async {
    _isLoading = true;
    _error = null;
    // Safe notifyListeners
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());

    try {
      final response = await _apiService.get('orders/vendor/my-orders');
      if (response['status'] == 'success') {
        final ordersData = response['data']?['orders'] as List? ?? [];
        _vendorOrders = ordersData.map((orderJson) => Order.fromJson(orderJson)).toList();
        _error = null;
      } else {
        _error = response['message'] ?? 'Failed to load vendor orders';
      }
    } catch (e) {
      _error = 'Error loading vendor orders: $e';
    } finally {
      _isLoading = false;
      // Safe notifyListeners
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }

  // UPDATED: Load driver orders with safe state updates
  Future<void> loadDriverOrders() async {
    _isLoading = true;
    _error = null;
    // Safe notifyListeners
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());

    try {
      final response = await _apiService.get('orders/driver/available');
      if (response['status'] == 'success') {
        final ordersData = response['data']?['orders'] as List? ?? [];
        _driverOrders = ordersData.map((orderJson) => Order.fromJson(orderJson)).toList();
        _error = null;
        print('✅ Loaded ${_driverOrders.length} driver orders with enhanced location data');
        
        // NEW: Calculate earnings when loading driver orders
        _calculateEarnings();
      } else {
        _error = response['message'] ?? 'Failed to load driver orders';
      }
    } catch (e) {
      _error = 'Error loading driver orders: $e';
    } finally {
      _isLoading = false;
      // Safe notifyListeners
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }

  // NEW: Calculate earnings breakdown
  void _calculateEarnings() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    double todayEarnings = 0.0;
    double weekEarnings = 0.0;
    double monthEarnings = 0.0;
    double allTimeEarnings = 0.0;
    double pending = 0.0;

    for (final order in _driverOrders) {
      final deliveryFee = order.deliveryFee;
      final orderDate = order.createdAt;

      if (order.isCompleted) {
        allTimeEarnings += deliveryFee;

        if (orderDate.isAfter(today)) {
          todayEarnings += deliveryFee;
        }

        if (orderDate.isAfter(weekStart)) {
          weekEarnings += deliveryFee;
        }

        if (orderDate.isAfter(monthStart)) {
          monthEarnings += deliveryFee;
        }
      } else if (order.isDelivering || order.isReady) {
        // Orders that are in progress but not completed are considered pending earnings
        pending += deliveryFee;
      }
    }

    _earningsBreakdown = {
      'today': todayEarnings,
      'thisWeek': weekEarnings,
      'thisMonth': monthEarnings,
      'allTime': allTimeEarnings,
    };

    _pendingEarnings = pending;
  }

  // NEW: Load driver earnings specifically
  Future<void> loadDriverEarnings() async {
    try {
      final response = await _apiService.get('orders/driver/earnings');
      if (response['status'] == 'success') {
        final earningsData = response['data']?['earnings'] ?? {};
        _pendingEarnings = (earningsData['pending'] as num?)?.toDouble() ?? 0.0;
        _earningsBreakdown = {
          'today': (earningsData['today'] as num?)?.toDouble() ?? 0.0,
          'thisWeek': (earningsData['thisWeek'] as num?)?.toDouble() ?? 0.0,
          'thisMonth': (earningsData['thisMonth'] as num?)?.toDouble() ?? 0.0,
          'allTime': (earningsData['allTime'] as num?)?.toDouble() ?? 0.0,
        };
        // Safe notifyListeners
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      }
    } catch (e) {
      print('Error loading driver earnings: $e');
      // Fallback to calculating from local orders
      _calculateEarnings();
    }
  }

  // UPDATED: Update order status with safe state updates and earnings recalculation
  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await _apiService.patch('orders/$orderId', {
        'status': status,
      });
      
      if (response['status'] == 'success') {
        final updatedOrderData = response['data']?['order'] ?? response;
        // Update in all order lists
        _updateOrderInList(_orders, orderId, updatedOrderData);
        _updateOrderInList(_vendorOrders, orderId, updatedOrderData);
        _updateOrderInList(_driverOrders, orderId, updatedOrderData);
        
        // Recalculate earnings when order status changes
        _calculateEarnings();
        
        // Safe notifyListeners
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error updating order status: $e';
      // Safe notifyListeners
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      return false;
    }
  }

  // UPDATED: Accept delivery as driver with safe state updates
  Future<bool> acceptDelivery(String orderId) async {
    try {
      final response = await _apiService.patch('orders/$orderId/accept', {});
      
      if (response['status'] == 'success') {
        final updatedOrderData = response['data']?['order'] ?? response;
        _updateOrderInList(_driverOrders, orderId, updatedOrderData);
        
        // Recalculate earnings
        _calculateEarnings();
        
        // Safe notifyListeners
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error accepting delivery: $e';
      // Safe notifyListeners
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      return false;
    }
  }

  // UPDATED: Complete delivery with safe state updates
  Future<bool> completeDelivery(String orderId) async {
    try {
      final response = await _apiService.patch('orders/$orderId/complete', {});
      
      if (response['status'] == 'success') {
        final updatedOrderData = response['data']?['order'] ?? response;
        _updateOrderInList(_driverOrders, orderId, updatedOrderData);
        
        // Recalculate earnings
        _calculateEarnings();
        
        // Safe notifyListeners
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error completing delivery: $e';
      // Safe notifyListeners
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      return false;
    }
  }

  // NEW: Initiate M-Pesa payment
  Future<bool> initiateMpesaPayment({
    required String orderId,
    required String phoneNumber,
    required double amount,
  }) async {
    try {
      final response = await _apiService.initiateMpesaPayment(
        orderId: orderId,
        phoneNumber: phoneNumber,
        amount: amount,
      );
      
      if (response['status'] == 'success') {
        return true;
      } else {
        _error = response['message'] ?? 'M-Pesa payment failed';
        // Safe notifyListeners
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
        return false;
      }
    } catch (e) {
      _error = 'M-Pesa payment error: $e';
      // Safe notifyListeners
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      return false;
    }
  }

  // NEW: Initiate EcoCash payment
  Future<bool> initiateEcocashPayment({
    required String orderId,
    required String phoneNumber,
    required double amount,
  }) async {
    try {
      final response = await _apiService.initiateEcocashPayment(
        orderId: orderId,
        phoneNumber: phoneNumber,
        amount: amount,
      );
      
      if (response['status'] == 'success') {
        return true;
      } else {
        _error = response['message'] ?? 'EcoCash payment failed';
        // Safe notifyListeners
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
        return false;
      }
    } catch (e) {
      _error = 'EcoCash payment error: $e';
      // Safe notifyListeners
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      return false;
    }
  }

  void _updateOrderInList(List<Order> orderList, String orderId, Map<String, dynamic> orderData) {
    final index = orderList.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      orderList[index] = Order.fromJson(orderData);
    }
  }

  void clearError() {
    _error = null;
    // Safe notifyListeners
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }

  // Get orders by status
  List<Order> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }

  List<Order> getVendorOrdersByStatus(String status) {
    return _vendorOrders.where((order) => order.status == status).toList();
  }

  List<Order> getDriverOrdersByStatus(String status) {
    return _driverOrders.where((order) => order.status == status).toList();
  }

  // Get total earnings for driver
  double get driverEarnings {
    return _driverOrders
        .where((order) => order.isCompleted)
        .fold(0.0, (sum, order) => sum + order.deliveryFee);
  }

  // NEW: Get orders that need driver attention
  List<Order> get availableDriverOrders {
    return _driverOrders.where((order) => 
      order.isReady || order.isConfirmed
    ).toList();
  }

  // NEW: Get active driver deliveries
  List<Order> get activeDriverDeliveries {
    return _driverOrders.where((order) => 
      order.isDelivering
    ).toList();
  }

  // NEW: Get completed driver deliveries for earnings calculation
  List<Order> get completedDriverDeliveries {
    return _driverOrders.where((order) => order.isCompleted).toList();
  }
} 