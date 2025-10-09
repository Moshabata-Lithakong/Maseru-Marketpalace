```dart
import 'package:maseru_marketplace/src/services/api_service.dart';

class AuthApi {
  final ApiService _apiService;

  AuthApi(this._apiService);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiService.login(email, password);
    return {'user': response.toJson()};
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final response = await _apiService.register(userData);
    return {'user': response.toJson()};
  }

  Future<Map<String, dynamic>> updateMe(Map<String, dynamic> userData) async {
    final response = await _apiService.updateProfile(userData);
    return {'user': response.toJson()};
  }

  Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    await _apiService.changePassword(currentPassword, newPassword);
    return {};
  }
}
