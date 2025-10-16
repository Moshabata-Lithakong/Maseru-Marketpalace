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
    
    // Only print response body if it's not too large
    if (response.body.length < 1000) {
      print('📡 Response Body: ${response.body}');
    } else {
      print('📡 Response Body: [Too large to display]');
    }

    // Handle 204 No Content
    if (response.statusCode == 204) {
      print('✅ 204 No Content - Operation successful');
      return {'status': 'success', 'message': 'Operation completed successfully'};
    }

    // Handle empty response body
    if (response.body.isEmpty) {
      print('⚠️ Empty response body');
      return {'status': 'success', 'message': 'Operation completed'};
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

  // Generic HTTP methods WITHOUT timeout
  Future<Map<String, dynamic>> get(String endpoint) async {
    await _loadToken();
    final url = Uri.parse('$baseUrl/$endpoint');
    print('📤 GET Request: $url');
    
    try {
      final response = await http.get(url, headers: headers);
      return _processResponse(response);
    } catch (e) {
      print('❌ GET Request failed: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, dynamic data) async {
    await _loadToken();
    final url = Uri.parse('$baseUrl/$endpoint');
    print('📤 POST Request: $url');
    print('📦 Request Data: ${jsonEncode(data)}');
    
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      return _processResponse(response);
    } catch (e) {
      print('❌ POST Request failed: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> patch(String endpoint, dynamic data) async {
    await _loadToken();
    final url = Uri.parse('$baseUrl/$endpoint');
    print('📤 PATCH Request: $url');
    
    try {
      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      return _processResponse(response);
    } catch (e) {
      print('❌ PATCH Request failed: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> put(String endpoint, dynamic data) async {
    await _loadToken();
    final url = Uri.parse('$baseUrl/$endpoint');
    print('📤 PUT Request: $url');
    
    try {
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      return _processResponse(response);
    } catch (e) {
      print('❌ PUT Request failed: $e');
      throw Exception('Network error: $e');
    }
  }

  // Generic delete method WITHOUT timeout
  Future<Map<String, dynamic>> delete(String endpoint) async {
    await _loadToken();
    final url = Uri.parse('$baseUrl/$endpoint');
    print('📤 DELETE Request: $url');
    
    try {
      final response = await http.delete(url, headers: headers);
      
      // Handle 204 No Content specifically
      if (response.statusCode == 204) {
        print('✅ 204 No Content - Operation successful');
        return {'status': 'success', 'message': 'Operation completed successfully'};
      }
      
      return _processResponse(response);
    } catch (e) {
      print('❌ DELETE Request failed: $e');
      throw Exception('Network error: $e');
    }
  }

  // SINGLE deleteProduct method WITHOUT timeout
  Future<void> deleteProduct(String id) async {
    try {
      await _loadToken();
      final url = Uri.parse('$baseUrl/products/$id');
      print('📤 DELETE Request: $url');
      
      final response = await http.delete(url, headers: headers);
      
      // Handle 204 No Content as success
      if (response.statusCode == 204) {
        print('✅ 204 No Content - Product deleted successfully');
        return;
      }
      
      // For other status codes, process normally
      await _processResponse(response);
    } catch (e) {
      print('❌ Delete product error: $e');
      rethrow;
    }
  }

  // Test connection method WITHOUT timeout
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

  // Authentication Methods WITHOUT timeout
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

  // Payment Methods WITHOUT timeout
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

  // Order creation methods WITHOUT timeout
  Future<Map<String, dynamic>> createOrderWithPayment({
    required List<Map<String, dynamic>> items,
    required String destinationAddress,
    required String paymentMethod,
    String? pickupAddress,
    String? destinationInstructions,
    double? pickupLatitude,
    double? pickupLongitude,
    double? destinationLatitude,
    double? destinationLongitude,
    String? phoneNumber,
    String? notes,
    bool isUrgent = false,
    String? vendorName,
    String? vendorPhone,
    String? passengerName,
    String? passengerPhone,
  }) async {
    try {
      await _loadToken();
      final url = Uri.parse('$baseUrl/orders/create-with-payment');

      final orderData = {
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
          'address': destinationAddress,
          'coordinates': {
            'latitude': destinationLatitude ?? -29.3100,
            'longitude': destinationLongitude ?? 27.4800,
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
      };

      print('📦 Creating order with payment: $paymentMethod');
      print('📍 Pickup: ${pickupAddress ?? 'Vendor Location'}');
      print('📍 Destination: $destinationAddress');
      
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

  // Alternative: Create order using main orders endpoint WITHOUT timeout
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    try {
      await _loadToken();
      final url = Uri.parse('$baseUrl/orders');
      print('📤 Creating order via main endpoint');
      
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

  // Driver-specific methods WITHOUT timeout
  Future<Map<String, dynamic>> acceptDelivery(String orderId) async {
    try {
      await _loadToken();
      final url = Uri.parse('$baseUrl/orders/driver/$orderId/accept');
      print('🚚 Accepting delivery for order: $orderId');

      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode({}),
      );

      return await _processResponse(response);
    } catch (e) {
      print('❌ Accept delivery error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> completeDelivery(String orderId) async {
    try {
      await _loadToken();
      final url = Uri.parse('$baseUrl/orders/driver/$orderId/complete');
      print('✅ Completing delivery for order: $orderId');

      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode({}),
      );

      return await _processResponse(response);
    } catch (e) {
      print('❌ Complete delivery error: $e');
      rethrow;
    }
  }

  // Registration method WITHOUT timeout
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

  // Product Methods WITHOUT timeout
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

  // Order Methods WITHOUT timeout
  Future<List<dynamic>> getOrders() async {
    try {
      await _loadToken();
      final url = Uri.parse('$baseUrl/orders/my-orders');
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
      final url = Uri.parse('$baseUrl/orders/vendor/my-orders');
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
      final url = Uri.parse('$baseUrl/orders/driver/available');
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

  // Upload image method WITHOUT timeout
  Future<Map<String, dynamic>> uploadImage(String imagePath) async {
    try {
      await _loadToken();
      final url = Uri.parse('$baseUrl/upload');
      
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        return jsonDecode(responseData);
      } else {
        throw Exception('Image upload failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Upload image error: $e');
      rethrow;
    }
  }

  // Get user orders with pagination WITHOUT timeout
  Future<Map<String, dynamic>> getUserOrders({int page = 1, int limit = 10}) async {
    try {
      await _loadToken();
      final url = Uri.parse('$baseUrl/orders/my-orders?page=$page&limit=$limit');
      final response = await http.get(url, headers: headers);
      return await _processResponse(response);
    } catch (e) {
      print('❌ Get user orders error: $e');
      rethrow;
    }
  }

  // Get vendor analytics WITHOUT timeout
  Future<Map<String, dynamic>> getVendorAnalytics() async {
    try {
      await _loadToken();
      final url = Uri.parse('$baseUrl/analytics/vendor');
      final response = await http.get(url, headers: headers);
      return await _processResponse(response);
    } catch (e) {
      print('❌ Get vendor analytics error: $e');
      rethrow;
    }
  }

  // Reset password WITHOUT timeout
  Future<void> resetPassword(String email) async {
    try {
      final url = Uri.parse('$baseUrl/auth/forgotPassword');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      await _processResponse(response);
      print('✅ Password reset email sent to: $email');
    } catch (e) {
      print('❌ Reset password error: $e');
      rethrow;
    }
  }

  // Verify email WITHOUT timeout
  Future<void> verifyEmail(String token) async {
    try {
      final url = Uri.parse('$baseUrl/auth/verify-email');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );
      await _processResponse(response);
      print('✅ Email verified successfully');
    } catch (e) {
      print('❌ Verify email error: $e');
      rethrow;
    }
  }

  // NEW: Method to check if backend is reachable
  Future<bool> isBackendReachable() async {
    try {
      final url = Uri.parse('$baseUrl/health');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Backend is not reachable: $e');
      return false;
    }
  }

  // NEW: Method with custom timeout for specific operations
  Future<Map<String, dynamic>> getWithCustomTimeout(String endpoint, {int timeoutSeconds = 10}) async {
    await _loadToken();
    final url = Uri.parse('$baseUrl/$endpoint');
    print('📤 GET Request with ${timeoutSeconds}s timeout: $url');
    
    try {
      final response = await http.get(url, headers: headers)
          .timeout(Duration(seconds: timeoutSeconds));
      return _processResponse(response);
    } catch (e) {
      print('❌ GET Request with timeout failed: $e');
      throw Exception('Request timeout: $e');
    }
  }

  // NEW: Method to retry failed requests
  Future<Map<String, dynamic>> retryRequest(
    Future<Map<String, dynamic>> Function() requestFn, 
    {int maxRetries = 3}
  ) async {
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
}