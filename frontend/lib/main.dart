import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:maseru_marketplace/src/localization/app_localizations.dart';
import 'package:maseru_marketplace/src/providers/auth_provider.dart';
import 'package:maseru_marketplace/src/providers/cart_provider.dart'; // ADD THIS IMPORT
import 'package:maseru_marketplace/src/providers/language_provider.dart';
import 'package:maseru_marketplace/src/providers/product_provider.dart';
import 'package:maseru_marketplace/src/providers/order_provider.dart';
import 'package:maseru_marketplace/src/providers/theme_provider.dart';
import 'package:maseru_marketplace/src/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import your dashboard screens
import 'package:maseru_marketplace/src/screens/home/home_screen.dart';
import 'package:maseru_marketplace/src/screens/auth/login_screen.dart';
import 'package:maseru_marketplace/src/screens/auth/register_screen.dart';
import 'package:maseru_marketplace/src/screens/passenger/passenger_screen.dart';
import 'package:maseru_marketplace/src/screens/vendor/vendor_dashboard.dart';
import 'package:maseru_marketplace/src/screens/taxi_driver/driver_dashboard.dart';
import 'package:maseru_marketplace/src/screens/admin/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  // For Flutter web, use the same origin or your computer's IP
  String apiUrl;
  
  // Check if running on web
  if (kIsWeb) {
    // For web, use the same origin or your computer's IP
    final currentOrigin = Uri.base.origin;
    print('🌐 Running on web with origin: $currentOrigin');
    
    if (currentOrigin.contains('localhost') || currentOrigin.contains('127.0.0.1')) {
      apiUrl = 'http://localhost:5000/api/v1';
    } else {
      apiUrl = 'http://10.228.140.50:5000/api/v1';
    }
  } else {
    // For mobile/desktop
    apiUrl = 'http://10.228.140.50:5000/api/v1';
  }
  
  print('🎯 Using API URL: $apiUrl');
  
  final apiService = ApiService(apiUrl);
  final prefs = await SharedPreferences.getInstance();
  
  // Test connection
  try {
    await apiService.testConnection();
  } catch (e) {
    print('⚠️ Connection test failed: $e');
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()), 
        ChangeNotifierProvider(create: (_) => AuthProvider(apiService)),
        ChangeNotifierProvider(create: (_) => ProductProvider(apiService)),
        ChangeNotifierProvider(create: (_) => LanguageProvider(prefs)),
        ChangeNotifierProvider(create: (_) => OrderProvider(apiService)),
        ChangeNotifierProvider(create: (_) => CartProvider()), // ADD CART PROVIDER
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // ADD THEME PROVIDER

    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          title: 'Maseru Marketplace',
          locale: Locale(languageProvider.currentLanguage),
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('st', 'LS'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light, // ADD THEME MODE
          home: HomeScreen(),
          routes: {         
            '/passenger': (context) => PassengerScreen(),
            '/login': (context) => LoginScreen(),
            '/register': (context) => RegisterScreen(),
            '/vendor': (context) => VendorDashboard(),
            '/driver': (context) => DriverDashboard(),
            '/admin': (context) => AdminDashboard(),
            '/home': (context) => HomeScreen(),
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}