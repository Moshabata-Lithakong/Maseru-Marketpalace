import 'package:flutter/material.dart';
import 'package:maseru_marketplace/src/models/user_model.dart';
import 'package:maseru_marketplace/src/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  final ApiService _apiService;

  AuthProvider(this._apiService);

  // LOGIN without timeout
  Future<void> login(String email, String password) async {
    _setLoading(true);
    _error = null;
    notifyListeners();

    try {
      print('🔐 Attempting login for: $email');
      
      final loggedUser = await _apiService.login(email, password);
      _user = loggedUser;
      _token = _apiService.token;
      _error = null;
      
      print('✅ Login successful for: ${_user?.email}');
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('❌ Login error: $_error');
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // REGISTER without timeout
  Future<void> register(Map<String, dynamic> userData) async {
    _setLoading(true);
    _error = null;
    notifyListeners();

    try {
      print('👤 Attempting registration for: ${userData['email']}');
      
      await _apiService.register(userData);

      // IMPORTANT: Don't set user or token after registration
      // User needs to login separately
      _user = null;
      _token = null;
      _error = null;
      
      print('✅ Registration successful for: ${userData['email']}');
      notifyListeners();
    } catch (e) {
      _user = null;
      _token = null;
      _error = e.toString();
      print('❌ Registration error: $_error');
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // GET CURRENT USER without timeout
  Future<void> loadCurrentUser() async {
    _setLoading(true);
    _error = null;
    
    try {
      print('🔄 Loading current user...');
      
      final savedUser = await _apiService.getCurrentUser();
      _user = savedUser;
      _token = _apiService.token;
      _error = null;
      
      print('✅ Current user loaded: ${_user?.email}');
      notifyListeners();
    } catch (_) {
      _user = null;
      _token = null;
      _error = null;
      print('ℹ️ No current user found or error loading user');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // LOGOUT without timeout
  Future<void> logout() async {
    _setLoading(true);
    _error = null;
    
    try {
      print('🚪 Logging out...');
      
      await _apiService.logout();

      _user = null;
      _token = null;
      _error = null;
      
      print('✅ Logout successful');
      notifyListeners();
    } catch (e) {
      // Even if there's an error, clear local user data
      _user = null;
      _token = null;
      _error = null;
      print('⚠️ Logout error, but cleared local data: $e');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // UPDATE PROFILE without timeout
  Future<void> updateProfile(Map<String, dynamic> userData) async {
    _setLoading(true);
    _error = null;
    notifyListeners();

    try {
      print('📝 Updating profile...');
      
      final updatedUser = await _apiService.updateProfile(userData);
      _user = updatedUser;
      _error = null;
      
      print('✅ Profile updated successfully');
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('❌ Profile update error: $_error');
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // CHANGE PASSWORD without timeout
  Future<void> changePassword(String currentPassword, String newPassword) async {
    _setLoading(true);
    _error = null;
    notifyListeners();

    try {
      print('🔑 Changing password...');
      
      await _apiService.changePassword(currentPassword, newPassword);
      _error = null;
      
      print('✅ Password changed successfully');
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('❌ Password change error: $_error');
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // CLEAR ERROR
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Check if user data exists
  bool hasUserData() {
    return _user != null && _token != null;
  }

  // PRIVATE LOADING HELPER
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Manual token setter (for testing or recovery)
  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  // Manual user setter (for testing or recovery)
  void setUser(User user) {
    _user = user;
    notifyListeners();
  }
}