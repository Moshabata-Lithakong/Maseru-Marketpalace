import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maseru_marketplace/src/localization/app_localizations.dart';
import 'package:maseru_marketplace/src/providers/product_provider.dart';
import 'package:maseru_marketplace/src/providers/auth_provider.dart';
import 'package:maseru_marketplace/src/providers/cart_provider.dart';
import 'package:maseru_marketplace/src/models/product_model.dart';
import 'package:maseru_marketplace/src/screens/passenger/product_detail_screen.dart';
import 'package:maseru_marketplace/src/screens/passenger/order_history_screen.dart';
import 'package:maseru_marketplace/src/screens/passenger/profile_screen.dart';
import 'package:maseru_marketplace/src/screens/passenger/cart_screen.dart';
import 'package:maseru_marketplace/src/widgets/common/bottom_nav.dart';
import 'package:maseru_marketplace/src/widgets/common/product_card.dart';
import 'package:maseru_marketplace/src/widgets/common/loading_indicator.dart';
import 'package:flutter/services.dart';
import 'package:maseru_marketplace/src/screens/passenger/location_input_screen.dart';
import 'package:maseru_marketplace/src/screens/passenger/payment_screen.dart';
import 'package:maseru_marketplace/src/models/simple_location.dart';

// Import the chat screen
import 'package:maseru_marketplace/src/screens/passenger/chat_screen.dart';

class PassengerScreen extends StatefulWidget {
  const PassengerScreen({super.key});

  @override
  State<PassengerScreen> createState() => _PassengerScreenState();
}

class _PassengerScreenState extends State<PassengerScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'all';
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const PassengerHomeTab(),      // Home - index 0
    const ProductListScreen(),     // Products - index 1
    const OrderHistoryScreen(),    // Orders - index 2
    const ChatScreen(),            // Chat - index 3
    const ProfileScreen(),         // Profile - index 4
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
    _searchController.addListener(_filterProducts);
  }

  void _loadProducts() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    try {
      await productProvider.loadProducts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load products: $e')),
      );
    }
  }

  void _filterProducts() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    productProvider.filterProducts(
      category: _selectedCategory == 'all' ? null : _selectedCategory,
      searchQuery: _searchController.text,
    );
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    HapticFeedback.lightImpact();
    _filterProducts();
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    HapticFeedback.selectionClick();
  }

  void _openLocationInput() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationInputScreen(
          onLocationSelected: (address, landmark, instructions, phone, lat, lng) {
            // Handle the selected location data
            final location = SimpleLocation(
              latitude: lat,
              longitude: lng,
              address: address,
            );
            // You can save this location or use it as needed
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Location set: $address')),
            );
          },
          isPickupLocation: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
      ),
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          if (cartProvider.cartItems.isNotEmpty && _currentIndex != 2)
            FloatingActionButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CartScreen(),
                  ),
                );
              },
              tooltip: 'View Cart',
              child: Badge(
                label: Text(cartProvider.cartItemCount.toString()),
                child: const Icon(Icons.shopping_cart),
              ),
            ),
          if (_currentIndex == 2) // Show location input on Orders tab
            Padding(
              padding: const EdgeInsets.only(bottom: 70.0),
              child: FloatingActionButton(
                onPressed: _openLocationInput,
                tooltip: 'Set Delivery Location',
                child: const Icon(Icons.location_pin),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search Products',
            onPressed: () {
              HapticFeedback.lightImpact();
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading) {
            return const LoadingIndicator();
          }

          final products = productProvider.products;

          if (products.isEmpty) {
            return const Center(
              child: Text('No products available.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              if (index < 0 || index >= products.length) {
                return const SizedBox();
              }

              final product = products[index];
              return ProductCard(
                product: product,
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.add_shopping_cart),
                  tooltip: 'Add to Cart',
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Provider.of<CartProvider>(context, listen: false)
                        .addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${product.name.en} added to cart')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        tooltip: 'Clear Search',
        onPressed: () {
          HapticFeedback.lightImpact();
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      tooltip: 'Back',
      onPressed: () {
        HapticFeedback.lightImpact();
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    productProvider.filterProducts(searchQuery: query);

    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final products = productProvider.filteredProducts;
        if (products.isEmpty) {
          return const Center(child: Text('No products found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              product: product,
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(product: product),
                  ),
                );
              },
              trailing: IconButton(
                icon: const Icon(Icons.add_shopping_cart),
                tooltip: 'Add to Cart',
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Provider.of<CartProvider>(context, listen: false)
                      .addToCart(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product.name.en} added to cart')),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const SizedBox();
  }
}

class PassengerHomeTab extends StatefulWidget {
  const PassengerHomeTab({super.key});

  @override
  State<PassengerHomeTab> createState() => _PassengerHomeTabState();
}

class _PassengerHomeTabState extends State<PassengerHomeTab> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProducts);
  }

  void _filterProducts() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    productProvider.filterProducts(
      category: _selectedCategory == 'all' ? null : _selectedCategory,
      searchQuery: _searchController.text,
    );
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    HapticFeedback.lightImpact();
    _filterProducts();
  }

  void _openLocationInput() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationInputScreen(
          onLocationSelected: (address, landmark, instructions, phone, lat, lng) {
            // Handle the selected location data
            final location = SimpleLocation(
              latitude: lat,
              longitude: lng,
              address: address,
            );
            // You can save this location or use it as needed
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Delivery location set: $address')),
            );
          },
          isPickupLocation: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade700,
                      Colors.purple.shade600,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appLocalizations.translate('home.welcome') ?? 'Welcome',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        authProvider.user?.profile?.firstName ?? 'Passenger',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.location_pin),
                tooltip: 'Set Delivery Location',
                onPressed: _openLocationInput,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: appLocalizations.translate('products.search') ?? 'Search products...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  onSubmitted: (_) {
                    HapticFeedback.selectionClick();
                    _filterProducts();
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 70,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCategoryChip('all', appLocalizations.translate('products.all') ?? 'All', Icons.all_inclusive),
                  _buildCategoryChip('food', appLocalizations.translate('products.food') ?? 'Food', Icons.restaurant),
                  _buildCategoryChip('drinks', appLocalizations.translate('products.drinks') ?? 'Drinks', Icons.local_drink),
                  _buildCategoryChip('clothing', appLocalizations.translate('products.clothing') ?? 'Clothing', Icons.shopping_bag),
                  _buildCategoryChip('electronics', appLocalizations.translate('products.electronics') ?? 'Electronics', Icons.electrical_services),
                  _buildCategoryChip('household', appLocalizations.translate('products.household') ?? 'Household', Icons.home),
                ],
              ),
            ),
          ),
          productProvider.isLoading
              ? const SliverToBoxAdapter(child: LoadingIndicator())
              : productProvider.filteredProducts.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off, size: 80, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              appLocalizations.translate('products.no_products') ?? 'No products found',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              appLocalizations.translate('products.adjust_search') ?? 'Try adjusting your search',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(16.0),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final filteredProducts = productProvider.filteredProducts;
                            if (index < 0 || index >= filteredProducts.length) {
                              return const SizedBox();
                            }

                            final product = filteredProducts[index];
                            return ProductCard(
                              product: product,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailScreen(product: product),
                                  ),
                                );
                              },
                              // Simple cart button instead of popup menu
                              trailing: IconButton(
                                icon: const Icon(Icons.add_shopping_cart),
                                tooltip: 'Add to Cart',
                                onPressed: () {
                                  HapticFeedback.mediumImpact();
                                  Provider.of<CartProvider>(context, listen: false)
                                      .addToCart(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${product.name.en} added to cart')),
                                  );
                                },
                              ),
                            );
                          },
                          childCount: productProvider.filteredProducts.length,
                        ),
                      ),
                    ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.payment),
                label: const Text('Proceed to Payment'),
                onPressed: cartProvider.cartItems.isEmpty
                    ? null
                    : () {
                        HapticFeedback.heavyImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) {
                              // Get the first vendor ID from cart items
                              final vendorCarts = cartProvider.getCartByVendor();
                              
                              if (vendorCarts.isEmpty) {
                                // Handle empty cart case
                                return Scaffold(
                                  appBar: AppBar(title: const Text('Error')),
                                  body: const Center(child: Text('Cart is empty')),
                                );
                              }
                              
                              // Use the first vendor ID (for single vendor orders)
                              final firstVendorId = vendorCarts.keys.first;
                              
                              return PaymentScreen(
                                cartItems: cartProvider.cartItems,
                                vendorId: firstVendorId,
                                destinationLatitude: -29.3100, // Default Maseru coordinates
                                destinationLongitude: 27.4800, // Default Maseru coordinates
                              );
                            },
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, String label, IconData icon) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: GestureDetector(
        onTap: () => _onCategorySelected(category),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade600 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.grey.shade700),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}