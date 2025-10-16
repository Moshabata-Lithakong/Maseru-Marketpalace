import 'package:flutter/foundation.dart';
import 'package:maseru_marketplace/src/services/api_service.dart';

class PaymentProvider with ChangeNotifier {
  final ApiService _apiService;
  
  bool _isProcessing = false;
  String? _error;
  String? _paymentStatus;
  String? _transactionId;

  PaymentProvider(this._apiService);

  bool get isProcessing => _isProcessing;
  String? get error => _error;
  String? get paymentStatus => _paymentStatus;
  String? get transactionId => _transactionId;

  Future<bool> initiateMpesaPayment({
    required String orderId,
    required String phoneNumber,
  }) async {
    print('💳 PaymentProvider: Initiating M-Pesa payment for order: $orderId');
    
    _isProcessing = true;
    _error = null;
    _paymentStatus = 'initiating';
    notifyListeners();

    try {
      final response = await _apiService.post('payments/mpesa/initiate', {
        'orderId': orderId,
        'phoneNumber': phoneNumber,
      });

      _isProcessing = false;

      if (response['status'] == 'success') {
        _paymentStatus = 'processing';
        _transactionId = response['data']?['payment']?['reference'] ?? 
                         response['data']?['mpesaResponse']?['transactionId'] ??
                         response['data']?['mpesaResponse']?['checkoutRequestID'];
        print('✅ M-Pesa payment initiated successfully. Transaction: $_transactionId');
        print('📱 Response: ${response['data']?['mpesaResponse']?['message']}');
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'M-Pesa payment initiation failed';
        _paymentStatus = 'failed';
        print('❌ M-Pesa payment failed: $_error');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isProcessing = false;
      _error = 'M-Pesa payment error: $e';
      _paymentStatus = 'failed';
      print('❌ M-Pesa payment exception: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> initiateEcocashPayment({
    required String orderId,
    required String phoneNumber,
  }) async {
    print('💳 PaymentProvider: Initiating EcoCash payment for order: $orderId');
    
    _isProcessing = true;
    _error = null;
    _paymentStatus = 'initiating';
    notifyListeners();

    try {
      final response = await _apiService.post('payments/ecocash/initiate', {
        'orderId': orderId,
        'phoneNumber': phoneNumber,
      });

      _isProcessing = false;

      if (response['status'] == 'success') {
        _paymentStatus = 'processing';
        _transactionId = response['data']?['payment']?['reference'] ?? 
                         response['data']?['ecocashResponse']?['transactionId'];
        print('✅ EcoCash payment initiated successfully. Transaction: $_transactionId');
        print('📱 Response: ${response['data']?['ecocashResponse']?['message']}');
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'EcoCash payment initiation failed';
        _paymentStatus = 'failed';
        print('❌ EcoCash payment failed: $_error');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isProcessing = false;
      _error = 'EcoCash payment error: $e';
      _paymentStatus = 'failed';
      print('❌ EcoCash payment exception: $e');
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>?> checkPaymentStatus(String orderId) async {
    print('🔍 PaymentProvider: Checking payment status for order: $orderId');
    
    _isProcessing = true;
    notifyListeners();

    try {
      final response = await _apiService.get('payments/status/$orderId');

      _isProcessing = false;

      if (response['status'] == 'success') {
        _paymentStatus = response['data']?['paymentStatus'] ?? 
                        response['data']?['orderPaymentStatus'];
        _transactionId = response['data']?['reference'];
        
        print('✅ Payment status check successful: $_paymentStatus');
        notifyListeners();
        
        return {
          'paymentStatus': _paymentStatus,
          'orderStatus': response['data']?['orderStatus'],
          'orderPaymentStatus': response['data']?['orderPaymentStatus'],
          'amount': response['data']?['amount'],
          'paymentMethod': response['data']?['paymentMethod'],
          'reference': _transactionId,
        };
      } else {
        _error = response['message'] ?? 'Failed to check payment status';
        print('❌ Payment status check failed: $_error');
        notifyListeners();
        return null;
      }
    } catch (e) {
      _isProcessing = false;
      _error = 'Payment status check error: $e';
      print('❌ Payment status check exception: $e');
      notifyListeners();
      return null;
    }
  }

  Future<bool> confirmPayment(String orderId, String status, {String? transactionId}) async {
    try {
      final response = await _apiService.post('payments/confirm', {
        'orderId': orderId,
        'status': status,
        'transactionId': transactionId,
      });

      if (response['status'] == 'success') {
        _paymentStatus = status;
        _transactionId = transactionId;
        print('✅ Payment manually confirmed as: $status');
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Payment confirmation failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error confirming payment: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _isProcessing = false;
    _error = null;
    _paymentStatus = null;
    _transactionId = null;
    notifyListeners();
  }
}