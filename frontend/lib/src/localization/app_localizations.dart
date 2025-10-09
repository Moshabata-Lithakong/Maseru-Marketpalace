import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  String get currentLanguage => locale.languageCode;

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Add these getters back
  String get productPrice => translate('product.price');
  String get addedToCart => translate('product.added_to_cart');

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app.title': 'Maseru Marketplace',
      'common.cancel': 'Cancel',
      'common.close': 'Close',
      'common.error': 'An error occurred',
      'common.view': 'View',
      'common.required': 'This field is required',
      'common.language': 'Language',
      'common.ok': 'OK',
      'home.title': 'Home',
      'dashboard.title': 'Dashboard',
      'delivery_requests.title': 'Delivery Requests',
      'driver.dashboard': 'Driver Dashboard',
      'driver.active_deliveries': 'Active Deliveries',
      'driver.completed_deliveries': 'Completed Deliveries',
      'driver.recent_deliveries': 'Recent Deliveries',
      'orders.title': 'Orders',
      'orders.all': 'All',
      'orders.history': 'Order History',
      'orders.no_orders': 'No Orders',
      'orders.no_orders_status': 'You have no orders in this status',
      'orders.order': 'Order',
      'orders.items': 'Items',
      'orders.date': 'Date',
      'orders.total': 'Total',
      'orders.products': 'Products',
      'orders.view_details': 'View Details',
      'orders.cancel': 'Cancel Order',
      'orders.cancel_title': 'Cancel Order',
      'orders.cancel_confirm': 'Are you sure you want to cancel this order?',
      'orders.cancel_yes': 'Yes, Cancel',
      'orders.cancel_success': 'Order cancelled successfully',
      'orders.error': 'Failed to load orders',
      'orders.more_items': 'more items',
      'orders.id': 'Order ID',
      'orders.status': 'Status',
      'orders.confirm': 'Confirm Order',
      'orders.prepare': 'Start Preparing',
      'orders.ready': 'Mark as Ready',
      'products.title': 'Products',
      'products.search': 'Search products...',
      'products.all': 'All',
      'products.food': 'Food',
      'products.drinks': 'Drinks',
      'products.clothing': 'Clothing',
      'products.electronics': 'Electronics',
      'products.household': 'Household',
      'products.no_products': 'No products found',
      'products.adjust_search': 'Try adjusting your search or filters',
      'vendor.dashboard': 'Vendor Dashboard',
      'vendor.products': 'Products',
      'vendor.active_orders': 'Active Orders',
      'vendor.revenue': 'Revenue',
      'vendor.total_sales': 'Total Sales',
      'vendor.recent_orders': 'Recent Orders',
      'vendor.low_stock': 'Low Stock Alert',
      'vendor.low_stock_message': 'Some products are running low on stock. Check your inventory.',
      'product.price': 'Price',
      'product.added_to_cart': 'Added to Cart',
      'product.add_to_cart': 'Add to Cart',
      'auth.welcome': 'Welcome to Maseru Marketplace',
      'auth.email': 'Email',
      'auth.password': 'Password',
      'auth.confirm_password': 'Confirm Password',
      'auth.first_name': 'First Name',
      'auth.last_name': 'Last Name',
      'auth.phone_number': 'Phone Number',
      'auth.shop_name': 'Shop Name',
      'auth.shop_location': 'Shop Location',
      'auth.license_number': 'License Number',
      'auth.vehicle_type': 'Vehicle Type',
      'auth.vehicle_plate': 'Vehicle Plate',
      'auth.invalid_email': 'Invalid email format',
      'auth.invalid_password': 'Password must be at least 6 characters',
      'auth.invalid_phone': 'Invalid phone number format',
      'auth.password_mismatch': 'Passwords do not match',
      'auth.login': 'Login',
      'auth.register': 'Register',
      'auth.login_success': 'Logged in successfully',
      'auth.register_success': 'Registered successfully',
      'auth.register_prompt': 'Don\'t have an account? Register',
      'auth.login_prompt': 'Already have an account? Login',
      'navigation.home': 'Home',
      'navigation.products': 'Products',
      'navigation.orders': 'Orders',
      'navigation.chat': 'Chat',
      'navigation.profile': 'Profile',
    },
    'st': {
      'app.title': 'Maseru Marketplace (Sesotho)',
      'common.cancel': 'Khansela',
      'common.close': 'Koala',
      'common.error': 'Ho bile le phoso',
      'common.view': 'Sheba',
      'common.required': 'Sebaka sena sea hlokahala',
      'common.language': 'Puo',
      'common.ok': 'Lokile',
      'home.title': 'Lehae',
      'dashboard.title': 'Dashboard (Sesotho)',
      'delivery_requests.title': 'Likopo tsa Delivery',
      'driver.dashboard': 'Dashboard ea Mokhanni',
      'driver.active_deliveries': 'Lipehelo tse Sebetsang',
      'driver.completed_deliveries': 'Lipehelo tse Phethiloeng',
      'driver.recent_deliveries': 'Lipehelo tsa Haufinyane',
      'orders.title': 'Liodara',
      'orders.all': 'Tsohle',
      'orders.history': 'Nalane ea Liodara',
      'orders.no_orders': 'Ha ho Liodara',
      'orders.no_orders_status': 'Ha u na liodara tsa boemo bona',
      'orders.order': 'Odara',
      'orders.items': 'Lintho',
      'orders.date': 'Letsatsi',
      'orders.total': 'Kakaretso',
      'orders.products': 'Lihlahisoa',
      'orders.view_details': 'Sheba Lintlha',
      'orders.cancel': 'Khansela Odara',
      'orders.cancel_title': 'Khansela Odara',
      'orders.cancel_confirm': 'Na u na le bonnete ba hore u batla ho khansela odara ee?',
      'orders.cancel_yes': 'E, Khansela',
      'orders.cancel_success': 'Odara e khanselitsoe ka katleho',
      'orders.error': 'E hloleha ho jarisa liodara',
      'orders.more_items': 'lintho tse ling',
      'orders.id': 'ID ea Odara',
      'orders.status': 'Boemo',
      'orders.confirm': 'Netefatsa Odara',
      'orders.prepare': 'Qala ho Itokisetsa',
      'orders.ready': 'Tšoaea e le e Lokile',
      'products.title': 'Lihlahisoa',
      'products.search': 'Batla lihlahisoa...',
      'products.all': 'Tsohle',
      'products.food': 'Lijo',
      'products.drinks': 'Lino',
      'products.clothing': 'Liaparo',
      'products.electronics': 'Lielektroniki',
      'products.household': 'Lintho tsa Lehae',
      'products.no_products': 'Ha ho lihlahisoa tse fumanehang',
      'products.adjust_search': 'Leka ho fetola patlisiso kapa lifiltara tsa hau',
      'vendor.dashboard': 'Dashboard ea Morekisi',
      'vendor.products': 'Lihlahisoa',
      'vendor.active_orders': 'Liodara tse Sebetsang',
      'vendor.revenue': 'Lekeno',
      'vendor.total_sales': 'Kakaretso ea Thekiso',
      'vendor.recent_orders': 'Liodara tsa Haufinyane',
      'vendor.low_stock': 'Temoso ea Stock e Tlase',
      'vendor.low_stock_message': 'Lihlahisoa tse ling li ntse li fokotseha ka har\'a stock. Sheba inventory ea hau.',
      'product.price': 'Theko',
      'product.added_to_cart': 'E kentsoe Kariking',
      'product.add_to_cart': 'Kenya Kariking',
      'auth.welcome': 'Rea u amohela ho Maseru Marketplace',
      'auth.email': 'Imeile',
      'auth.password': 'Phasewete',
      'auth.confirm_password': 'Netefatsa Phasewete',
      'auth.first_name': 'Lebitso la Pele',
      'auth.last_name': 'Lebitso la ho Qetela',
      'auth.phone_number': 'Nomoro ea Mohala',
      'auth.shop_name': 'Lebitso la Lebenkele',
      'auth.shop_location': 'Sebaka sa Lebenkele',
      'auth.license_number': 'Nomoro ea Laesense',
      'auth.vehicle_type': 'Mofuta oa Koloi',
      'auth.vehicle_plate': 'Nomoro ea Plate ea Koloi',
      'auth.invalid_email': 'Sebopeho sa imeile se fosahetse',
      'auth.invalid_password': 'Phasewete e tlameha ho ba bonyane litlhaku tse 6',
      'auth.invalid_phone': 'Nomoro ea mohala e fosahetse',
      'auth.password_mismatch': 'Liphasewete ha li lumellane',
      'auth.login': 'Kena',
      'auth.register': 'Ingolisa',
      'auth.login_success': 'U kene ka katleho',
      'auth.register_success': 'U ngolisitse ka katleho',
      'auth.register_prompt': 'Ha u na akhaonto? Ingolisa',
      'auth.login_prompt': 'U se u na le akhaonto? Kena',
      'navigation.home': 'Lehae',
      'navigation.products': 'Lihlahisoa',
      'navigation.orders': 'Liodara',
      'navigation.chat': 'Cheche',
      'navigation.profile': 'Profaele',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'st'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}