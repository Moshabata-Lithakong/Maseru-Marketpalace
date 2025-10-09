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
import 'package:maseru_marketplace/src/screens/passenger/chat_screen.dart';
import 'package:maseru_marketplace/src/widgets/common/bottom_nav.dart';
import 'package:maseru_marketplace/src/widgets/common/product_card.dart';
import 'package:maseru_marketplace/src/widgets/common/loading_indicator.dart';

class PassengerScreen extends StatefulWidget {
  const PassengerScreen({super.key});

  @override
  State<PassengerScreen> createState() => _PassengerScreenState();
}

class _PassengerScreenState extends State<PassengerScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'all';
  int _currentIndex = 0;

  // FIXED: Now 5 pages to match the 5 bottom nav items
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
    // FIXED: Defer loading until after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
    _searchController.addListener(_filterProducts);
  }

  void _loadProducts() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await productProvider.loadProducts();
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
    _filterProducts();
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
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
      // FIXED: Floating action button using CartProvider
      floatingActionButton: cartProvider.cartItems.isNotEmpty && _currentIndex != 2
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CartScreen(),
                ),
              ),
              child: Badge(
                label: Text(cartProvider.cartItemCount.toString()),
                child: const Icon(Icons.shopping_cart),
              ),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// ProductListScreen for the Products tab - FIXED: Safe list access
class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Products'),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading) {
            return const LoadingIndicator();
          }
          
          final products = productProvider.products;
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              // FIXED: Safe bounds checking
              if (index < 0 || index >= products.length) {
                return const SizedBox();
              }
              
              final product = products[index];
              return ListTile(
                leading: product.images.isNotEmpty
                    ? Image.network(
                        product.images.first.url,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[200],
                            child: const Icon(Icons.shopping_bag),
                          );
                        },
                      )
                    : Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[200],
                        child: const Icon(Icons.shopping_bag),
                      ),
                title: Text(product.name.en),
                subtitle: Text('LSL ${product.price.toStringAsFixed(2)}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(
                        product: product,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// Basic ChatScreen
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Chat Feature',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Coming soon...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
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
    _filterProducts();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Header Section
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
          ),

          // Search Section
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
                ),
              ),
            ),
          ),

          // Categories Section
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

          // Products Grid - FIXED: Safe list access
          productProvider.isLoading
              ? const SliverToBoxAdapter(
                  child: LoadingIndicator(),
                )
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
                            // FIXED: Safe bounds checking
                            if (index < 0 || index >= filteredProducts.length) {
                              return const SizedBox();
                            }
                            
                            final product = filteredProducts[index];
                            return ProductCard(
                              product: product,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailScreen(
                                      product: product,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          childCount: productProvider.filteredProducts.length,
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