import 'package:maseru_marketplace/src/models/user_model.dart';
import 'package:maseru_marketplace/src/services/api_service.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<User> login(String email, String password) async {
    return await _apiService.login(email, password);
  }

  Future<User> register(Map<String, dynamic> userData) async {
    return await _apiService.register(userData);
  }

  Future<void> logout() async {
    await _apiService.logout();
  }

  Future<User> updateProfile(Map<String, dynamic> userData) async {
    return await _apiService.updateProfile(userData);
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    await _apiService.changePassword(currentPassword, newPassword);
  }
}