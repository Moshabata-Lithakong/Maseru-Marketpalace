import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:maseru_marketplace/src/services/api_service.dart';
import 'package:maseru_marketplace/src/models/order_model.dart';

class OrderProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Order> _orders = [];
  List<Order> _vendorOrders = [];
  List<Order> _driverOrders = [];
  List<Order> _acceptedOrders = []; // NEW: Track accepted orders separately
  bool _isLoading = false;
  String? _error;
  double _driverEarnings = 0.0; // NEW: Track driver earnings
  int _completedOrdersCount = 0; // NEW: Track completed orders count

  OrderProvider(this._apiService);

  List<Order> get orders => _orders;
  List<Order> get vendorOrders => _vendorOrders;
  List<Order> get driverOrders => _driverOrders;
  List<Order> get acceptedOrders => _acceptedOrders; // NEW: Getter for accepted orders
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get driverEarnings => _driverEarnings; // NEW: Getter for earnings
  int get completedOrdersCount => _completedOrdersCount; // NEW: Getter for completed count

  // NEW: Enhanced earnings breakdown
  Map<String, dynamic> get earningsBreakdown {
    try {
      final completedOrders = _driverOrders.where((order) => order.isCompleted);
      final totalEarnings = completedOrders.fold(0.0, (sum, order) => sum + order.deliveryFee);
      final pendingOrders = _driverOrders.where((order) => order.isDelivering);
      final pendingEarnings = pendingOrders.fold(0.0, (sum, order) => sum + order.deliveryFee);
      
      return {
        'total': totalEarnings,
        'pending': pendingEarnings,
        'completedCount': completedOrders.length,
        'pendingCount': pendingOrders.length,
      };
    } catch (e) {
      print('❌ ERROR in earningsBreakdown: $e');
      return {
        'total': 0.0,
        'pending': 0.0,
        'completedCount': 0,
        'pendingCount': 0,
      };
    }
  }

  double get pendingEarnings {
    try {
      return _driverOrders
          .where((order) => order.isDelivering)
          .fold(0.0, (sum, order) => sum + order.deliveryFee);
    } catch (e) {
      print('❌ ERROR in pendingEarnings: $e');
      return 0.0;
    }
  }

  Future<void> fetchOrders({required String role}) async {
    print('🔍 OrderProvider.fetchOrders called for role: $role');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      switch (role) {
        case 'taxi_driver':
          await loadDriverOrders(); // Load both available and assigned orders
          await getDriverDeliveryEarnings(); // NEW: Load earnings for drivers
          break;
        case 'vendor':
          await loadVendorOrders();
          break;
        case 'passenger':
          await loadPassengerOrders();
          break;
        default:
          throw Exception('Invalid role: $role');
      }
      print('✅ OrderProvider.fetchOrders completed successfully for role: $role');
    } catch (e) {
      _error = 'Error fetching orders: $e';
      print('❌ ERROR in OrderProvider.fetchOrders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // FIXED: Enhanced createOrder method with proper delivery location handling
  Future<bool> createOrder({
    required String vendorId,
    required List<Map<String, dynamic>> items,
    required double destinationLatitude,
    required double destinationLongitude,
    required String paymentMethod,
    String? pickupAddress,
    String? destinationAddress,
    String? destinationInstructions,
    double? pickupLatitude,
    double? pickupLongitude,
    String? phoneNumber,
    bool isUrgent = false,
    String? notes,
    required String vendorName,
    required String vendorPhone,
    required String passengerName,
    required String passengerPhone,
  }) async {
    print('🛒 OrderProvider.createOrder called');
    print('📦 Vendor ID: $vendorId');
    print('💰 Payment Method: $paymentMethod');
    print('📍 Destination: ($destinationLatitude, $destinationLongitude)');
    print('📍 Destination Address: $destinationAddress');
    print('📋 Items count: ${items.length}');
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Calculate delivery fee based on urgency
      final deliveryFee = isUrgent ? 25.0 : 15.0;
      final itemsTotal = _calculateTotalAmount(items);
      final totalAmount = itemsTotal + deliveryFee;

      // FIXED: Ensure destination address is properly set
      final String finalDestinationAddress = destinationAddress ?? 'Passenger Location';
      
      final Map<String, dynamic> orderData = {
        'items': items,
        'pickupLocation': {
          'address': pickupAddress ?? 'Vendor Location',
          'coordinates': {
            'latitude': pickupLatitude ?? -29.3100,
            'longitude': pickupLongitude ?? 27.4800,
          },
          'vendorName': vendorName,
          'vendorPhone': vendorPhone,
        },
        'destination': {
          'address': finalDestinationAddress,
          'coordinates': {
            'latitude': destinationLatitude,
            'longitude': destinationLongitude,
          },
          'instructions': destinationInstructions,
          'passengerName': passengerName,
          'passengerPhone': passengerPhone,
        },
        'payment': {
          'method': paymentMethod,
          'phoneNumber': phoneNumber,
        },
        'isUrgent': isUrgent,
        'notes': notes,
        'deliveryFee': deliveryFee,
        'totalAmount': totalAmount,
      };

      print('📦 Creating order with delivery fee: LSL $deliveryFee');
      print('💰 Total amount: LSL $totalAmount');
      print('📍 Final destination: $finalDestinationAddress');
      
      final response = await _apiService.post('orders', orderData);

      _isLoading = false;

      print('📡 API Response status: ${response['status']}');
      
      if (response['status'] == 'success') {
        final newOrder = Order.fromJson(response['data']?['order'] ?? response);
        _orders.add(newOrder);
        print('✅ Order created successfully with ID: ${newOrder.id}');
        print('🚚 Delivery fee set: LSL ${newOrder.deliveryFee}');
        print('📍 Delivery location: ${newOrder.destination.address}');
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to create order';
        print('❌ Order creation failed: $_error');
        print('📡 Full response: $response');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error creating order: $e';
      print('❌ ERROR in OrderProvider.createOrder: $e');
      print('📋 Stack trace: ${e.toString()}');
      notifyListeners();
      return false;
    }
  }

  // FIXED: Enhanced loadAvailableDeliveryOrders method
  Future<void> loadAvailableDeliveryOrders() async {
    print('🚚 OrderProvider.loadAvailableDeliveryOrders called');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('orders/driver/available');
      print('📡 Available delivery orders API response received');
      
      if (response['status'] == 'success') {
        final ordersData = response['data']?['orders'] as List? ?? [];
        _driverOrders = ordersData.map((orderJson) => Order.fromJson(orderJson)).toList();
        _error = null;
        print('✅ Loaded ${_driverOrders.length} available delivery orders');
        
        // Debug print delivery orders with fees
        for (var order in _driverOrders) {
          print('📦 Delivery Order: ${order.id} | Fee: LSL ${order.deliveryFee} | Status: ${order.status} | Payment: ${order.payment.status}');
        }
      } else {
        _error = response['message'] ?? 'Failed to load available delivery orders';
        print('❌ Failed to load delivery orders: $_error');
        print('📡 Response: $response');
      }
    } catch (e) {
      _error = 'Error loading available delivery orders: $e';
      print('❌ ERROR in OrderProvider.loadAvailableDeliveryOrders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // FIXED: Enhanced acceptDeliveryAssignment method
  Future<bool> acceptDeliveryAssignment(String orderId) async {
    print('✅ OrderProvider.acceptDeliveryAssignment called for order: $orderId');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.patch('orders/driver/$orderId/accept', {});

      _isLoading = false;

      if (response['status'] == 'success') {
        final orderData = response['data']?['order'] ?? response;
        final acceptedOrder = Order.fromJson(orderData);
        
        // Remove from available orders and add to accepted orders
        _driverOrders.removeWhere((order) => order.id == orderId);
        _acceptedOrders.add(acceptedOrder);
        
        final deliveryFee = acceptedOrder.deliveryFee;
        
        print('✅ Delivery assignment accepted successfully');
        print('💰 Delivery fee: LSL $deliveryFee');
        print('📍 Delivery to: ${acceptedOrder.destination.address}');
        
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to accept delivery assignment';
        print('❌ Delivery assignment failed: $_error');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error accepting delivery assignment: $e';
      print('❌ ERROR in OrderProvider.acceptDeliveryAssignment: $e');
      notifyListeners();
      return false;
    }
  }

  // FIXED: Enhanced completeDelivery method
  Future<bool> completeDelivery(String orderId) async {
    print('🏁 OrderProvider.completeDelivery called for order: $orderId');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.patch('orders/driver/$orderId/complete', {});

      _isLoading = false;

      if (response['status'] == 'success') {
        // Remove from accepted orders
        _acceptedOrders.removeWhere((order) => order.id == orderId);
        
        // Update earnings
        await getDriverDeliveryEarnings();
        
        print('✅ Delivery completed successfully!');
        print('💰 Earnings updated');
        
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to complete delivery';
        print('❌ Delivery completion failed: $_error');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error completing delivery: $e';
      print('❌ ERROR in OrderProvider.completeDelivery: $e');
      notifyListeners();
      return false;
    }
  }

  // FIXED: Enhanced getDriverDeliveryEarnings method
  Future<Map<String, dynamic>?> getDriverDeliveryEarnings() async {
    print('💰 OrderProvider.getDriverDeliveryEarnings called');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('orders/driver/earnings');

      _isLoading = false;
      
      if (response['status'] == 'success') {
        final earningsData = response['data']?['earnings'];
        final recentDeliveries = response['data']?['recentDeliveries'];
        
        // Update local state
        _driverEarnings = (earningsData?['totalEarnings'] ?? 0).toDouble();
        _completedOrdersCount = earningsData?['totalDeliveries'] ?? 0;
        
        print('✅ Loaded driver delivery earnings');
        print('📊 Total earnings: LSL $_driverEarnings');
        print('📦 Completed deliveries: $_completedOrdersCount');
        
        notifyListeners();
        return {
          'summary': earningsData,
          'recentDeliveries': recentDeliveries,
        };
      } else {
        _error = response['message'] ?? 'Failed to load earnings';
        print('❌ Failed to load earnings: $_error');
        return null;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error loading driver delivery earnings: $e';
      print('❌ ERROR in OrderProvider.getDriverDeliveryEarnings: $e');
      return null;
    }
  }

  // FIXED: Enhanced loadDriverAssignedDeliveries method
  Future<void> loadDriverAssignedDeliveries() async {
    print('📋 OrderProvider.loadDriverAssignedDeliveries called');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('orders/driver/assigned');
      
      _isLoading = false;

      if (response['status'] == 'success') {
        final ordersData = response['data']?['orders'] as List? ?? [];
        final assignedOrders = ordersData.map((orderJson) => Order.fromJson(orderJson)).toList();
        
        // Update accepted orders
        _acceptedOrders = assignedOrders;
        
        print('✅ Loaded ${_acceptedOrders.length} assigned deliveries');
        for (var order in _acceptedOrders) {
          print('📦 Assigned Order: ${order.id} | Status: ${order.status} | To: ${order.destination.address}');
        }
      } else {
        _error = response['message'] ?? 'Failed to load assigned deliveries';
        print('❌ Failed to load assigned deliveries: $_error');
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error loading assigned deliveries: $e';
      print('❌ ERROR in OrderProvider.loadDriverAssignedDeliveries: $e');
    } finally {
      notifyListeners();
    }
  }

  // FIXED: Enhanced loadDriverOrders method
  Future<void> loadDriverOrders() async {
    print('🚕 OrderProvider.loadDriverOrders called');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load both available and assigned orders
      await Future.wait([
        loadAvailableDeliveryOrders(),
        loadDriverAssignedDeliveries(),
      ]);
      print('✅ Loaded all driver orders (available + assigned)');
    } catch (e) {
      _error = 'Error loading driver orders: $e';
      print('❌ ERROR in OrderProvider.loadDriverOrders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // FIXED: Enhanced createOrderWithPayment method
  Future<bool> createOrderWithPayment({
    required String vendorId,
    required List<Map<String, dynamic>> items,
    required double destinationLatitude,
    required double destinationLongitude,
    required String paymentMethod,
    String? pickupAddress,
    String? destinationAddress,
    String? destinationInstructions,
    double? pickupLatitude,
    double? pickupLongitude,
    String? phoneNumber,
    bool isUrgent = false,
    String? notes,
    required String vendorName,
    required String vendorPhone,
    required String passengerName,
    required String passengerPhone,
  }) async {
    print('🛒 OrderProvider.createOrderWithPayment called');
    
    return await createOrder(
      vendorId: vendorId,
      items: items,
      destinationLatitude: destinationLatitude,
      destinationLongitude: destinationLongitude,
      paymentMethod: paymentMethod,
      pickupAddress: pickupAddress,
      destinationAddress: destinationAddress,
      destinationInstructions: destinationInstructions,
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      phoneNumber: phoneNumber,
      isUrgent: isUrgent,
      notes: notes,
      vendorName: vendorName,
      vendorPhone: vendorPhone,
      passengerName: passengerName,
      passengerPhone: passengerPhone,
    );
  }

  double _calculateTotalAmount(List<Map<String, dynamic>> items) {
    try {
      double total = 0.0;
      for (var item in items) {
        final price = (item['price'] as num?)?.toDouble() ?? 0.0;
        final quantity = (item['quantity'] as int?) ?? 0;
        total += price * quantity;
      }
      return total;
    } catch (e) {
      print('❌ ERROR in _calculateTotalAmount: $e');
      return 0.0;
    }
  }

  Future<bool> rejectDeliveryAssignment(String orderId) async {
    print('❌ OrderProvider.rejectDeliveryAssignment called for order: $orderId');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.patch('orders/driver/$orderId/reject', {});

      _isLoading = false;

      if (response['status'] == 'success') {
        // Remove from available orders
        _driverOrders.removeWhere((order) => order.id == orderId);
        print('✅ Delivery assignment rejected');
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to reject delivery assignment';
        print('❌ Delivery rejection failed: $_error');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error rejecting delivery assignment: $e';
      print('❌ ERROR in OrderProvider.rejectDeliveryAssignment: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> startDelivery(String orderId) async {
    print('🚀 OrderProvider.startDelivery called for order: $orderId');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.patch('orders/driver/$orderId/start', {});

      _isLoading = false;

      if (response['status'] == 'success') {
        print('✅ Delivery started - order picked up from vendor');
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to start delivery';
        print('❌ Delivery start failed: $_error');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error starting delivery: $e';
      print('❌ ERROR in OrderProvider.startDelivery: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> assignDriver(String orderId, String driverId) async {
    print('🚗 OrderProvider.assignDriver called for order: $orderId, driver: $driverId');
    try {
      final response = await _apiService.patch('orders/$orderId/assign-driver', {
        'driverId': driverId,
      });

      if (response['status'] == 'success') {
        final updatedOrderData = response['data']?['order'] ?? response;
        _updateOrderInList(_driverOrders, orderId, updatedOrderData);
        _updateOrderInList(_orders, orderId, updatedOrderData);
        print('✅ Driver assigned successfully');
        notifyListeners();
        return true;
      }
      print('❌ Driver assignment failed: ${response['message']}');
      return false;
    } catch (e) {
      _error = 'Error assigning driver: $e';
      print('❌ ERROR in OrderProvider.assignDriver: $e');
      notifyListeners();
      return false;
    }
  }

  // FIXED: Enhanced loadPassengerOrders method
  Future<void> loadPassengerOrders() async {
    print('👤 OrderProvider.loadPassengerOrders called');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('orders/my-orders');
      print('📡 Passenger orders API response received');
      
      if (response['status'] == 'success') {
        final ordersData = response['data']?['orders'] as List? ?? [];
        _orders = ordersData.map((orderJson) => Order.fromJson(orderJson)).toList();
        _error = null;
        print('✅ Loaded ${_orders.length} passenger orders');
        
        // Debug print passenger orders with delivery locations
        for (var order in _orders) {
          print('📦 Passenger Order: ${order.id} | Status: ${order.status} | To: ${order.destination.address}');
        }
      } else {
        _error = response['message'] ?? 'Failed to load orders';
        print('❌ Failed to load passenger orders: $_error');
      }
    } catch (e) {
      _error = 'Error loading orders: $e';
      print('❌ ERROR in OrderProvider.loadPassengerOrders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // FIXED: Enhanced loadVendorOrders method
  Future<void> loadVendorOrders() async {
    print('🏪 OrderProvider.loadVendorOrders called');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('orders/vendor/my-orders');
      print('📡 Vendor orders API response received');
      
      if (response['status'] == 'success') {
        final ordersData = response['data']?['orders'] as List? ?? [];
        _vendorOrders = ordersData.map((orderJson) => Order.fromJson(orderJson)).toList();
        _error = null;
        print('✅ Loaded ${_vendorOrders.length} vendor orders');
      } else {
        _error = response['message'] ?? 'Failed to load vendor orders';
        print('❌ Failed to load vendor orders: $_error');
      }
    } catch (e) {
      _error = 'Error loading vendor orders: $e';
      print('❌ ERROR in OrderProvider.loadVendorOrders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // FIXED: Enhanced updateOrderStatus method - allows passenger cancellation
  Future<bool> updateOrderStatus(String orderId, String status) async {
    print('🔄 OrderProvider.updateOrderStatus called for order: $orderId, status: $status');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.patch('orders/$orderId/status', {
        'status': status,
      });

      _isLoading = false;

      if (response['status'] == 'success') {
        final updatedOrderData = response['data']?['order'] ?? response;
        _updateOrderInList(_orders, orderId, updatedOrderData);
        _updateOrderInList(_vendorOrders, orderId, updatedOrderData);
        _updateOrderInList(_driverOrders, orderId, updatedOrderData);
        _updateOrderInList(_acceptedOrders, orderId, updatedOrderData);
        print('✅ Order status updated successfully to: $status');
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to update order status';
        print('❌ Order status update failed: $_error');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error updating order status: $e';
      print('❌ ERROR in OrderProvider.updateOrderStatus: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> initiateMpesaPayment(String orderId, String phoneNumber, double amount) async {
    print('📱 OrderProvider.initiateMpesaPayment called for order: $orderId');
    try {
      final response = await _apiService.post('payments/mpesa/initiate', {
        'orderId': orderId,
        'phoneNumber': phoneNumber,
        'amount': amount,
      });

      if (response['status'] == 'success') {
        print('✅ M-Pesa payment initiated successfully');
        notifyListeners();
        return true;
      }
      print('❌ M-Pesa payment initiation failed: ${response['message']}');
      return false;
    } catch (e) {
      _error = 'Error initiating Mpesa payment: $e';
      print('❌ ERROR in OrderProvider.initiateMpesaPayment: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> initiateEcocashPayment(String orderId, String phoneNumber, double amount) async {
    print('📱 OrderProvider.initiateEcocashPayment called for order: $orderId');
    try {
      final response = await _apiService.post('payments/ecocash/initiate', {
        'orderId': orderId,
        'phoneNumber': phoneNumber,
        'amount': amount,
      });

      if (response['status'] == 'success') {
        print('✅ EcoCash payment initiated successfully');
        notifyListeners();
        return true;
      }
      print('❌ EcoCash payment initiation failed: ${response['message']}');
      return false;
    } catch (e) {
      _error = 'Error initiating Ecocash payment: $e';
      print('❌ ERROR in OrderProvider.initiateEcocashPayment: $e');
      notifyListeners();
      return false;
    }
  }

  void _updateOrderInList(List<Order> orderList, String orderId, Map<String, dynamic> orderData) {
    try {
      final index = orderList.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        orderList[index] = Order.fromJson(orderData);
        print('🔄 Updated order $orderId in list at index $index');
      } else {
        print('⚠️ Order $orderId not found in list for update');
      }
    } catch (e) {
      print('❌ ERROR in _updateOrderInList: $e');
    }
  }

  void clearError() {
    _error = null;
    print('🧹 OrderProvider error cleared');
    notifyListeners();
  }

  List<Order> getOrdersByStatus(String status) {
    try {
      return _orders.where((order) => order.status == status).toList();
    } catch (e) {
      print('❌ ERROR in getOrdersByStatus: $e');
      return [];
    }
  }

  List<Order> getVendorOrdersByStatus(String status) {
    try {
      return _vendorOrders.where((order) => order.status == status).toList();
    } catch (e) {
      print('❌ ERROR in getVendorOrdersByStatus: $e');
      return [];
    }
  }

  List<Order> getDriverOrdersByStatus(String status) {
    try {
      return _driverOrders.where((order) => order.status == status).toList();
    } catch (e) {
      print('❌ ERROR in getDriverOrdersByStatus: $e');
      return [];
    }
  }

  List<Order> get availableDriverOrders {
    try {
      return _driverOrders.where((order) => 
        (order.status == 'confirmed' || order.status == 'preparing' || order.status == 'ready') &&
        (order.taxiDriverId == null || order.taxiDriverId!.isEmpty) &&
        (order.payment.status == 'completed' || order.payment.status == 'processing')
      ).toList();
    } catch (e) {
      print('❌ ERROR in availableDriverOrders: $e');
      return [];
    }
  }

  List<Order> get activeDriverDeliveries {
    try {
      return _acceptedOrders.where((order) => order.status == 'delivering').toList();
    } catch (e) {
      print('❌ ERROR in activeDriverDeliveries: $e');
      return [];
    }
  }

  List<Order> get completedDriverDeliveries {
    try {
      return _acceptedOrders.where((order) => order.status == 'completed').toList();
    } catch (e) {
      print('❌ ERROR in completedDriverDeliveries: $e');
      return [];
    }
  }

  // NEW: Clear all data
  void clearData() {
    _orders.clear();
    _vendorOrders.clear();
    _driverOrders.clear();
    _acceptedOrders.clear();
    _error = null;
    _isLoading = false;
    _driverEarnings = 0.0;
    _completedOrdersCount = 0;
    print('🧹 OrderProvider data cleared');
    notifyListeners();
  }

  // NEW: Get order by ID
  Future<Order?> getOrderById(String orderId) async {
    print('🔍 OrderProvider.getOrderById called for order: $orderId');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('orders/$orderId');

      _isLoading = false;

      if (response['status'] == 'success') {
        final orderData = response['data']?['order'] ?? response;
        final order = Order.fromJson(orderData);
        print('✅ Loaded order: ${order.id}');
        print('📍 Delivery to: ${order.destination.address}');
        return order;
      } else {
        _error = response['message'] ?? 'Failed to load order';
        print('❌ Failed to load order: $_error');
        return null;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error loading order: $e';
      print('❌ ERROR in OrderProvider.getOrderById: $e');
      return null;
    }
  }

  // NEW: Retry mechanism for failed requests
  Future<T> _retryRequest<T>(Future<T> Function() requestFn, {int maxRetries = 3}) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        return await requestFn();
      } catch (e) {
        print('❌ Request attempt ${i + 1} failed: $e');
        if (i == maxRetries - 1) {
          rethrow;
        }
        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(seconds: (i + 1) * 2));
      }
    }
    throw Exception('All retry attempts failed');
  }

  // NEW: Enhanced create order with retry
  Future<bool> createOrderWithRetry({
    required String vendorId,
    required List<Map<String, dynamic>> items,
    required double destinationLatitude,
    required double destinationLongitude,
    required String paymentMethod,
    String? pickupAddress,
    String? destinationAddress,
    String? destinationInstructions,
    double? pickupLatitude,
    double? pickupLongitude,
    String? phoneNumber,
    bool isUrgent = false,
    String? notes,
    required String vendorName,
    required String vendorPhone,
    required String passengerName,
    required String passengerPhone,
  }) async {
    return await _retryRequest(() => createOrder(
      vendorId: vendorId,
      items: items,
      destinationLatitude: destinationLatitude,
      destinationLongitude: destinationLongitude,
      paymentMethod: paymentMethod,
      pickupAddress: pickupAddress,
      destinationAddress: destinationAddress,
      destinationInstructions: destinationInstructions,
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      phoneNumber: phoneNumber,
      isUrgent: isUrgent,
      notes: notes,
      vendorName: vendorName,
      vendorPhone: vendorPhone,
      passengerName: passengerName,
      passengerPhone: passengerPhone,
    ));
  }
}