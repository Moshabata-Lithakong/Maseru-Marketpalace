import 'package:flutter/material.dart';
import 'package:maseru_marketplace/src/localization/app_localizations.dart';
import 'package:maseru_marketplace/src/providers/product_provider.dart';
import 'package:maseru_marketplace/src/screens/passenger/product_detail_screen.dart';
import 'package:maseru_marketplace/src/widgets/common/loading_indicator.dart';
import 'package:maseru_marketplace/src/widgets/common/product_card.dart';
import 'package:provider/provider.dart';

class ProductListScreen extends StatefulWidget {
  final String? category;

  const ProductListScreen({super.key, this.category});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();
  String _selectedSort = 'name';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadProducts() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      await productProvider.loadProducts();
      
      if (widget.category != null) {
        productProvider.filterProducts(category: widget.category);
      }
    } catch (e) {
      print('Error loading products: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    productProvider.filterProducts(
      searchQuery: _searchController.text,
      category: widget.category,
    );
  }

  void _onSortChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedSort = value;
      });
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      productProvider.sortProducts(value);
    }
  }

  void _clearFilters() {
    _searchController.clear();
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    productProvider.clearFilters();
  }

  void _navigateToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final appLocalizations = AppLocalizations.of(context);
    final products = productProvider.filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category?.toUpperCase() ?? appLocalizations.translate('products.title') ?? 'Products',
        ),
        actions: [
          // Sort Dropdown
          DropdownButton<String>(
            value: _selectedSort,
            onChanged: _onSortChanged,
            underline: const SizedBox(),
            items: [
              DropdownMenuItem(
                value: 'name',
                child: Text(appLocalizations.translate('products.sort_name') ?? 'Name'),
              ),
              DropdownMenuItem(
                value: 'price_low',
                child: Text(appLocalizations.translate('products.sort_price_low') ?? 'Price: Low to High'),
              ),
              DropdownMenuItem(
                value: 'price_high',
                child: Text(appLocalizations.translate('products.sort_price_high') ?? 'Price: High to Low'),
              ),
              DropdownMenuItem(
                value: 'rating',
                child: Text(appLocalizations.translate('products.sort_rating') ?? 'Rating'),
              ),
              DropdownMenuItem(
                value: 'newest',
                child: Text(appLocalizations.translate('products.sort_newest') ?? 'Newest'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: appLocalizations.translate('products.search') ?? 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              ),
            ),
          ),

          // Results Info and Clear Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${products.length} ${appLocalizations.translate('products.found') ?? 'products found'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                if (widget.category != null || _searchController.text.isNotEmpty)
                  TextButton(
                    onPressed: _clearFilters,
                    child: Text(
                      appLocalizations.translate('products.clear_filters') ?? 'Clear filters',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Products Grid
          Expanded(
            child: _isLoading
                ? const LoadingIndicator()
                : products.isEmpty
                    ? _buildEmptyState(appLocalizations)
                    : RefreshIndicator(
                        onRefresh: _loadProducts,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return ProductCard(
                              product: product,
                              onTap: () => _navigateToProductDetail(product),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations appLocalizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            appLocalizations.translate('products.no_products') ?? 'No products found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              appLocalizations.translate('products.adjust_search') ?? 'Try adjusting your search or filters to find what you\'re looking for.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (widget.category != null || _searchController.text.isNotEmpty)
            ElevatedButton(
              onPressed: _clearFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear Filters'),
            ),
        ],
      ),
    );
  }
}