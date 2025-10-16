import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:maseru_marketplace/src/services/api_service.dart';

class PaymentService {
  final ApiService apiService;

  PaymentService(this.apiService);

  // M-Pesa payment initiation
  Future<Map<String, dynamic>> initiateMpesaPayment({
    required String orderId,
    required String phoneNumber,
  }) async {
    try {
      final response = await apiService.post('payments/mpesa/initiate', {
        'orderId': orderId,
        'phoneNumber': phoneNumber,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // EcoCash payment initiation
  Future<Map<String, dynamic>> initiateEcocashPayment({
    required String orderId,
    required String phoneNumber,
  }) async {
    try {
      final response = await apiService.post('payments/ecocash/initiate', {
        'orderId': orderId,
        'phoneNumber': phoneNumber,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Check payment status
  Future<Map<String, dynamic>> checkPaymentStatus(String orderId) async {
    try {
      final response = await apiService.get('payments/status/$orderId');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Get payment details
  Future<Map<String, dynamic>> getPaymentDetails(String orderId) async {
    try {
      final response = await apiService.get('payments/details/$orderId');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Confirm payment manually
  Future<Map<String, dynamic>> confirmPayment({
    required String orderId,
    required String status,
    String? transactionId,
  }) async {
    try {
      final response = await apiService.post('payments/confirm', {
        'orderId': orderId,
        'status': status,
        'transactionId': transactionId,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }
}