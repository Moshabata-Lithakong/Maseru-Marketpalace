import 'package:maseru_marketplace/src/services/api_service.dart';

class OrderService {
  final ApiService _apiService;

  OrderService(this._apiService);

  // Create order with payment method
  Future<Map<String, dynamic>> createOrder({
    required String vendorId, // ADDED: Required vendorId parameter
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required String destinationAddress,
    required String paymentMethod,
    String? destinationInstructions,
    double? latitude,
    double? longitude,
    String? phoneNumber, // For M-Pesa/EcoCash
  }) async {
    try {
      return await _apiService.createOrderWithPayment(
        vendorId: vendorId, // PASS vendorId to API service
        items: items,
        totalAmount: totalAmount,
        destinationAddress: destinationAddress,
        paymentMethod: paymentMethod,
        destinationInstructions: destinationInstructions,
        latitude: latitude,
        longitude: longitude,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      print('❌ Order creation error: $e');
      rethrow;
    }
  }

  // Initiate M-Pesa payment
  Future<Map<String, dynamic>> initiateMpesaPayment({
    required String orderId,
    required String phoneNumber,
    required double amount,
  }) async {
    try {
      return await _apiService.initiateMpesaPayment(
        orderId: orderId,
        phoneNumber: phoneNumber,
        amount: amount,
      );
    } catch (e) {
      print('❌ M-Pesa payment error: $e');
      rethrow;
    }
  }

  // Initiate EcoCash payment
  Future<Map<String, dynamic>> initiateEcocashPayment({
    required String orderId,
    required String phoneNumber,
    required double amount,
  }) async {
    try {
      return await _apiService.initiateEcocashPayment(
        orderId: orderId,
        phoneNumber: phoneNumber,
        amount: amount,
      );
    } catch (e) {
      print('❌ EcoCash payment error: $e');
      rethrow;
    }
  }

  // Verify payment status
  Future<Map<String, dynamic>> verifyPayment(String transactionId) async {
    try {
      return await _apiService.verifyPayment(transactionId);
    } catch (e) {
      print('❌ Payment verification error: $e');
      rethrow;
    }
  }

  // Get user orders
  Future<List<dynamic>> getUserOrders() async {
    try {
      final response = await _apiService.get('orders/my-orders');
      return response['data']?['orders'] ?? [];
    } catch (e) {
      print('❌ Get user orders error: $e');
      rethrow;
    }
  }

  // Get vendor orders
  Future<List<dynamic>> getVendorOrders() async {
    try {
      final response = await _apiService.get('orders/vendor/my-orders');
      return response['data']?['orders'] ?? [];
    } catch (e) {
      print('❌ Get vendor orders error: $e');
      rethrow;
    }
  }

  // Update order status
  Future<Map<String, dynamic>> updateOrderStatus(
    String orderId,
    String status,
  ) async {
    try {
      return await _apiService.patch(
        'orders/$orderId',
        {'status': status},
      );
    } catch (e) {
      print('❌ Update order status error: $e');
      rethrow;
    }
  }

  // Cancel order
  Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    try {
      return await _apiService.patch(
        'orders/$orderId',
        {'status': 'cancelled'},
      );
    } catch (e) {
      print('❌ Cancel order error: $e');
      rethrow;
    }
  }
}