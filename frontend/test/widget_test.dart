import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:maseru_marketplace/main.dart';
import 'package:maseru_marketplace/src/localization/app_localizations.dart';
import 'package:maseru_marketplace/src/providers/auth_provider.dart';
import 'package:maseru_marketplace/src/providers/language_provider.dart';
import 'package:maseru_marketplace/src/providers/product_provider.dart';
import 'package:maseru_marketplace/src/providers/order_provider.dart';
import 'package:maseru_marketplace/src/screens/passenger/profile_screen.dart';
import 'package:maseru_marketplace/src/screens/passenger/order_history_screen.dart';
import 'package:maseru_marketplace/src/screens/passenger/product_card.dart';
import 'package:maseru_marketplace/src/models/product_model.dart';
import 'package:maseru_marketplace/src/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maseru_marketplace/src/services/api_service.dart';

void main() {
  // Mock ApiService
  final mockApiService = ApiService('http://localhost:5000/api/v1');

  // Mock SharedPreferences
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  // Helper to wrap widgets with providers
  Widget wrapWithProviders(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(mockApiService)),
        ChangeNotifierProvider(create: (_) => ProductProvider(mockApiService)),
        ChangeNotifierProvider(create: (_) => LanguageProvider(SharedPreferences.getInstance())),
        ChangeNotifierProvider(create: (_) => OrderProvider(mockApiService)),
      ],
      child: MaterialApp(
        locale: const Locale('en', 'US'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  testWidgets('MyApp renders App widget', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.byType(App), findsOneWidget);
  });

  testWidgets('ProfileScreen renders user info', (WidgetTester tester) async {
    // Mock AuthProvider with a user
    final authProvider = AuthProvider(mockApiService);
    authProvider.setUser(User(
      id: '1',
      profile: Profile(firstName: 'John', lastName: 'Doe', phone: '1234567890'),
      email: 'john.doe@example.com',
      role: 'user',
    ));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authProvider),
          ChangeNotifierProvider(create: (_) => LanguageProvider(SharedPreferences.getInstance())),
        ],
        child: MaterialApp(
          locale: const Locale('en', 'US'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('john.doe@example.com'), findsOneWidget);
    expect(find.text('USER'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
  });

  testWidgets('OrderHistoryScreen renders empty state', (WidgetTester tester) async {
    // Mock OrderProvider with no orders
    final orderProvider = OrderProvider(mockApiService);
    orderProvider.setOrders([]);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: orderProvider),
          ChangeNotifierProvider(create: (_) => LanguageProvider(SharedPreferences.getInstance())),
        ],
        child: MaterialApp(
          locale: const Locale('en', 'US'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const OrderHistoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Order History'), findsOneWidget);
    expect(find.text('No Orders'), findsOneWidget);
    expect(find.text('You have no orders at the moment.'), findsOneWidget);
  });

  testWidgets('ProductCard renders product details', (WidgetTester tester) async {
    final product = Product(
      id: '1',
      name: ProductName(en: 'Test Product', st: 'Sehlahisoa sa Teko'),
      description: ProductDescription(en: 'A test product', st: 'Sehlahisoa sa teko'),
      images: [ProductImage(url: 'https://example.com/image.jpg')],
      price: 99.99,
      stockQuantity: 10,
      ratings: ProductRating(average: 4.5, count: 10),
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en', 'US'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProductCard(
          product: product,
          onTap: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Test Product'), findsOneWidget);
    expect(find.text('A test product'), findsOneWidget);
    expect(find.text('LSL 99.99'), findsOneWidget);
    expect(find.text('4.5'), findsOneWidget);
    expect(find.text('(10)'), findsOneWidget);
    expect(find.text('Add to Cart'), findsOneWidget);
  });
}