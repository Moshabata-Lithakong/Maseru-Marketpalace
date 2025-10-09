import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maseru_marketplace/src/screens/admin/admin_dashboard.dart';
import 'package:maseru_marketplace/src/screens/passenger/product_detail_screen.dart';
import 'package:maseru_marketplace/src/screens/taxi_driver/driver_dashboard.dart';
import 'package:maseru_marketplace/src/screens/vendor/vendor_dashboard.dart';
import 'package:maseru_marketplace/src/screens/shared/settings_screen.dart';
import 'package:maseru_marketplace/src/screens/taxi_driver/delivery_request.dart';
import 'package:maseru_marketplace/src/screens/admin/user_management.dart';
import 'package:maseru_marketplace/src/screens/admin/interview_management.dart';
import 'package:maseru_marketplace/src/screens/shared/chart_screen.dart';
import 'package:maseru_marketplace/src/providers/language_provider.dart';
import 'package:maseru_marketplace/src/localization/app_localizations.dart';
import 'package:maseru_marketplace/src/screens/passenger/order_history_screen.dart';
import 'package:maseru_marketplace/src/models/product_model.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    Widget homeScreen;

    // Placeholder role-based navigation
    String role = 'vendor'; // This should come from auth state
    switch (role) {
      case 'admin':
        homeScreen = const AdminDashboard();
        break;
      case 'vendor':
        homeScreen = const VendorDashboard();
        break;
      case 'driver':
        homeScreen = const DriverDashboard();
        break;
      default:
        homeScreen = const OrderHistoryScreen();
    }

    return MaterialApp(
      locale: Locale(languageProvider.currentLanguage),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: homeScreen,
      routes: {
        '/admin': (context) => const AdminDashboard(),
        '/vendor': (context) => const VendorDashboard(),
        '/driver': (context) => const DriverDashboard(),
        '/settings': (context) => const SettingsScreen(),
        '/delivery': (context) => const DeliveryRequestScreen(),
        '/user_management': (context) => const UserManagementScreen(),
        '/interview_management': (context) => const InterviewManagementScreen(),
        '/charts': (context) => const ChartScreen(),
        '/order_history': (context) => const OrderHistoryScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/product_detail') {
          final product = settings.arguments as Product;
          return MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          );
        }
        return null;
      },
    );
  }
}