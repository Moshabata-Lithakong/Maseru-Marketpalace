import 'package:flutter/material.dart'; // ✅ Import added

class AppConstants {
  static const String appName = 'Maseru Marketplace';
  static const String appVersion = '1.0.0';

  // API Endpoints
  static const String baseUrl = 'http://localhost:5000/api';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String languageKey = 'app_language';
  static const String themeKey = 'app_theme';

  // Product Categories
  static const List<Map<String, String>> categories = [
    {'value': 'all', 'label': 'All Products'},
    {'value': 'food', 'label': 'Food'},
    {'value': 'drinks', 'label': 'Drinks'},
    {'value': 'clothing', 'label': 'Clothing'},
    {'value': 'electronics', 'label': 'Electronics'},
    {'value': 'household', 'label': 'Household'},
    {'value': 'other', 'label': 'Other'},
  ];

  // Order Status
  static const Map<String, String> orderStatus = {
    'pending': 'Pending',
    'confirmed': 'Confirmed',
    'preparing': 'Preparing',
    'ready': 'Ready for Pickup',
    'delivering': 'On the Way',
    'completed': 'Completed',
    'cancelled': 'Cancelled',
  };

  // User Roles
  static const List<String> userRoles = [
    'passenger',
    'vendor',
    'taxi_driver',
    'admin',
  ];

  // Supported Languages
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'st': 'Sesotho',
  };
}

class AppColors {
  static const Color primaryColor = Color(0xFF1E88E5); // ✅ Explicit Color
  static const Color secondaryColor = Color(0xFFFF9800);
  static const Color accentColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color successColor = Color(0xFF4CAF50);

  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color darkBackground = Color(0xFF121212);

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);
}

class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyText1 = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyText2 = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
}
