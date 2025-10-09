import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:maseru_marketplace/src/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl;
  String? _token;

  ApiService(this.baseUrl) {
    print('🔧 API Service initialized with baseUrl: $baseUrl');
  }

  String? get token => _token;

  Map<String, String> get headers => {
        'Content-Type': 'application/json; charset=UTF-8',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      print('🔑 Loaded token: ${_token != null ? "Yes" : "No"}');
    } catch (e) {
      print('❌ Error loading token: $e');
      _token = null;
    }
  }

  Future<Map<String, dynamic>> _processResponse(http.Response response) async {
    print('📡 Response Status: ${response.statusCode}');
    print('📡 Response Body: ${response.body}');
    
    // Handle 204 No Content
    if (response.statusCode == 204) {
      print('✅ 204 No Content - Operation successful');
      return {'success': true, 'message': 'Operation completed successfully'};
    }
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final fullResponse = decoded;
          
          if (fullResponse['token'] != null && !response.request!.url.path.contains('/register')) {
            _token = fullResponse['token'];
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', _token!);
            print('🔑 Token saved successfully');
          }
          return fullResponse;
        }
        throw Exception('Invalid response format: Expected JSON object');
      } catch (e) {
        print('❌ JSON Parse Error: $e');
        throw Exception('Failed to parse response: $e');
      }
    } else {
      print('❌ HTTP Error: ${response.statusCode}');
      
      try {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? errorData['error'] ?? response.body;
        throw Exception('HTTP ${response.statusCode}: $errorMessage');
      } catch (_) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    }
  }

  // Generic HTTP methods for providers
  Future<Map<String, dynamic>> get(String endpoint) async {
    await _loadToken();
    final url = Uri.parse('$baseUrl/$endpoint');
    print('📤 GET Request: $url');
    final response = await http.get(url, headers: headers);
    return _processResponse(response);
  }

  Future<Map<String, dynamic>> post(String endpoint, dynamic data) async {
    await _loadToken();
    final url = Uri.parse('$baseUrl/$endpoint');
    print('📤 POST Request: $url');
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
    return _processResponse(response);
  }

  Future<Map<String, dynamic>> patch(String endpoint, dynamic data) async {
    await _loadToken();
    final url = Uri.parse('$baseUrl/$endpoint');
    print('📤 PATCH Request: $url');
    final response = await http.patch(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
    return _processResponse(response);
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    await _loadToken();
    final url = Uri.parse('$baseUrl/$endpoint');
    print('📤 DELETE Request: $url');
    final response = await http.delete(url, headers: headers);
    return _processResponse(response);
  }

  // Test connection method without timeout
  Future<void> testConnection() async {
    try {
      print('🧪 Testing connection to: $baseUrl');
      final url = Uri.parse('$baseUrl/health');
      print('🔗 Full URL: $url');
      
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      
      print('✅ Connection test successful: ${response.statusCode}');
      print('📄 Response: ${response.body}');
    } catch (e) {
      print('❌ Connection test failed: $e');
      rethrow;
    }
  }

  // Authentication Methods without timeout
  Future<User> login(String email, String password) async {
    try {
      print('🔐 Attempting login to: $baseUrl/auth/login');
      await _loadToken();
      
      final url = Uri.parse('$baseUrl/auth/login');
      print('📤 Sending request to: $url');
      print('📧 Email: $email');
      
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({'email': email, 'password': password}),
      );
      
      print('📥 Login response received');
      final data = await _processResponse(response);
      return User.fromJson(data['data']?['user'] ?? data['user'] ?? data);
    } catch (e) {
      print('❌ Login error: $e');
      rethrow;
    }
  }

  // Payment Methods
  Future<Map<String, dynamic>> initiateMpesaPayment({
    required String orderId,
    required String phoneNumber,
    required double amount,
  }) async {
    try {
      await _loadToken();
      final url = Uri.parse('$baseUrl/payments/mpesa/initiate');
      print('💳 Initiating M-Pesa payment for order: $orderId');
      
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'orderId': orderId,
          'phoneNumber': phoneNumber,
          'amount': amount,
        }),
      );
      
      return await _processResponse(response);
    } catch (e) {
      print('❌ M-Pesa payment initiation error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> initiateEcocashPayment({
    required String orderId,
    required String phoneNumber,
    required double amount,
  }) async {
    try {
      await _loadToken();
      final url = Uri.parse('$baseUrl/payments/ecocash/initiate');
      print('💳 Initiating EcoCash payment for order: $orderId');
      
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'orderId': orderId,
          'phoneNumber': phoneNumber,
          'amount': amount,
        }),
      );
      
      return await _processResponse(response);
    } catch (e) {
      print('❌ EcoCash payment initiation error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyPayment(String transactionId) async {
    try {
      await _loadToken();
      final url = Uri.parse('$baseUrl/payments/verify/$transactionId');
      print('🔍 Verifying payment: $transactionId');
      
      final response = await http.get(url, headers: headers);
      return await _processResponse(response);
    } catch (e) {
      print('❌ Payment verification error: $e');
      rethrow;
    }
  }

  // Order creation with payment method
  Future<Map<String, dynamic>> createOrderWithPayment({
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
      await _loadToken();
      final url = Uri.parse('$baseUrl/orders');
      
      final orderData = {
        'items': items,
        'totalAmount': totalAmount,
        'destination': {
          'address': destinationAddress,
          if (destinationInstructions != null)
            'instructions': destinationInstructions,
          if (latitude != null && longitude != null)
            'coordinates': {
              'latitude': latitude,
              'longitude': longitude,
            },
        },
        'payment': {
          'method': paymentMethod,
          'phoneNumber': phoneNumber,
        },
      };

      print('📦 Creating order with payment: $paymentMethod');
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(orderData),
      );
      
      return await _processResponse(response);
    } catch (e) {
      print('❌ Create order with payment error: $e');
      rethrow;
    }
  }

  // Registration method
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      print('👤 Attempting registration');
      final url = Uri.parse('$baseUrl/auth/register');
      print('📤 Sending request to: $url');
      print('📝 Registration data: ${userData['email']}');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(userData),
      );
      
      print('📥 Registration response received');
      final data = await _processResponse(response);
      
      print('✅ Registration successful for: ${userData['email']}');
      return data;
    } catch (e) {
      print('❌ Registration error: $e');
      rethrow;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      await _loadToken();
      if (_token == null) {
        print('🔑 No token found for current user');
        return null;
      }
      final url = Uri.parse('$baseUrl/users/me');
      final response = await http.get(url, headers: headers);
      final data = await _processResponse(response);
      return User.fromJson(data['data']?['user'] ?? data['user'] ?? data);
    } catch (e) {
      print('❌ Get current user error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      _token = null;
      print('🚪 User logged out, token cleared');
    } catch (e) {
      print('❌ Logout error: $e');
      _token = null;
      rethrow;
    }
  }

  Future<User> updateProfile(Map<String, dynamic> userData) async {
    try {
      await _loadToken();
      final url = Uri.parse('$baseUrl/users/me');
      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode(userData),
      );
      final data = await _processResponse(response);
      return User.fromJson(data['data']?['user'] ?? data['user'] ?? data);
    } catch (e) {
      print('❌ Update profile error: $e');
      rethrow;
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await _loadToken();
      final url = Uri.parse('$baseUrl/auth/updateMyPassword');
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );
      await _processResponse(response);
      print('✅ Password changed successfully');
    } catch (e) {
      print('❌ Change password error: $e');
      rethrow;
    }
  }

  // Product Methods without timeout
  Future<List<dynamic>> getProducts() async {
    try {
      await _loadToken();
      final url = Uri.parse('$baseUrl/products');
      final response = await http.get(url, headers: headers);
      final data = await _processResponse(response);
      return data['data']?['products'] ?? data['products'] ?? [];
    } catch (e) {
      print('❌ Get products error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getProduct(String id) async {
    try {
      await _loadToken();
      final url = Uri.parse('$baseUrl/products/$id');
      final response = await http.get(url, headers: headers);
      final data = await _processResponse(response);
      return data['data']?['product'] ?? data['product'] ?? data;
    } catch (e) {
      print('❌ Get product error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> productData) async {
    try {
      await _loadToken();
      final url = Uri.parse('$baseUrl/products');
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(productData),
      );
      return await _processResponse(response);
    } catch (e) {
      print('❌ Create product error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProduct(String id, Map<String, dynamic> productData) async {
    try {
      await _loadToken();
      final url = Uri.parse('$baseUrl/products/$id');
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(productData),
      );
      final data = await _processResponse(response);
      return data['data']?['product'] ?? data['product'] ?? data;
    } catch (e) {
      print('❌ Update product error: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _loadToken();
      final url = Uri.parse('$baseUrl/products/$id');
      final response = await http.delete(url, headers: headers);
      await _processResponse(response);
    } catch (e) {
      print('❌ Delete product error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> toggleFavorite(String productId) async {
    try {
      await _loadToken();
      final url = Uri.parse('$baseUrl/products/$productId/favorite');
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({}),
      );
      return await _processResponse(response);
    } catch (e) {
      print('❌ Toggle favorite error: $e');
      rethrow;
    }
  }

  // Order Methods without timeout
  Future<List<dynamic>> getOrders() async {
    try {
      await _loadToken();
      final url = Uri.parse('$baseUrl/orders');
      final response = await http.get(url, headers: headers);
      final data = await _processResponse(response);
      return data['data']?['orders'] ?? data['orders'] ?? [];
    } catch (e) {
      print('❌ Get orders error: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getVendorOrders() async {
    try {
      await _loadToken();
      final url = Uri.parse('$baseUrl/orders/vendor');
      final response = await http.get(url, headers: headers);
      final data = await _processResponse(response);
      return data['data']?['orders'] ?? data['orders'] ?? [];
    } catch (e) {
      print('❌ Get vendor orders error: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getDriverOrders() async {
    try {
      await _loadToken();
      final url = Uri.parse('$baseUrl/orders/driver');
      final response = await http.get(url, headers: headers);
      final data = await _processResponse(response);
      return data['data']?['orders'] ?? data['orders'] ?? [];
    } catch (e) {
      print('❌ Get driver orders error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getOrder(String id) async {
    try {
      await _loadToken();
      final url = Uri.parse('$baseUrl/orders/$id');
      final response = await http.get(url, headers: headers);
      final data = await _processResponse(response);
      return data['data']?['order'] ?? data['order'] ?? data;
    } catch (e) {
      print('❌ Get order error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    try {
      await _loadToken();
      final url = Uri.parse('$baseUrl/orders');
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(orderData),
      );
      return await _processResponse(response);
    } catch (e) {
      print('❌ Create order error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateOrder(String id, Map<String, dynamic> orderData) async {
    try {
      await _loadToken();
      final url = Uri.parse('$baseUrl/orders/$id');
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(orderData),
      );
      final data = await _processResponse(response);
      return data['data']?['order'] ?? data['order'] ?? data;
    } catch (e) {
      print('❌ Update order error: $e');
      rethrow;
    }
  }

  // Clear token manually (for testing)
  Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      _token = null;
      print('🔑 Token cleared manually');
    } catch (e) {
      print('❌ Error clearing token: $e');
    }
  }
}