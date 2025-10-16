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
  String _selectedCategory = 'all';

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
        setState(() {
          _selectedCategory = widget.category!;
        });
        productProvider.filterProducts(category: widget.category);
      }
    } catch (e) {
      print('Error loading products: $e');
      _showErrorSnackBar('Error loading products');
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
      category: _selectedCategory == 'all' ? null : _selectedCategory,
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

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    productProvider.filterProducts(
      searchQuery: _searchController.text,
      category: category == 'all' ? null : category,
    );
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _selectedCategory = 'all';
    });
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<String> _getCategories(List<Product> products) {
    final categories = {'all': 'All Categories'};
    for (var product in products) {
      categories[product.category] = product.category;
    }
    return categories.values.toList();
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
    final theme = Theme.of(context);
    final products = productProvider.filteredProducts;
    final categories = _getCategories(productProvider.products);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category?.toUpperCase() ?? appLocalizations.translate('products.title') ?? 'Products',
          style: TextStyle(
            color: theme.colorScheme.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.colorScheme.onBackground,
        actions: [
          // Sort Dropdown
          DropdownButton<String>(
            value: _selectedSort,
            onChanged: _onSortChanged,
            underline: const SizedBox(),
            dropdownColor: theme.colorScheme.surface,
            items: [
              DropdownMenuItem(
                value: 'name',
                child: Text(
                  appLocalizations.translate('products.sort_name') ?? 'Name',
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              ),
              DropdownMenuItem(
                value: 'price_low',
                child: Text(
                  appLocalizations.translate('products.sort_price_low') ?? 'Price: Low to High',
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              ),
              DropdownMenuItem(
                value: 'price_high',
                child: Text(
                  appLocalizations.translate('products.sort_price_high') ?? 'Price: High to Low',
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              ),
              DropdownMenuItem(
                value: 'rating',
                child: Text(
                  appLocalizations.translate('products.sort_rating') ?? 'Rating',
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              ),
              DropdownMenuItem(
                value: 'newest',
                child: Text(
                  appLocalizations.translate('products.sort_newest') ?? 'Newest',
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: appLocalizations.translate('products.search') ?? 'Search products...',
                    prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.colorScheme.primary),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  ),
                ),
                const SizedBox(height: 12),

                // Category Filter
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: categories.map((category) {
                      final isSelected = _selectedCategory == (category == 'All Categories' ? 'all' : category);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (_) => _onCategoryChanged(category == 'All Categories' ? 'all' : category),
                          backgroundColor: theme.colorScheme.surface,
                          selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          checkmarkColor: theme.colorScheme.primary,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                if (widget.category != null || _searchController.text.isNotEmpty || _selectedCategory != 'all')
                  TextButton(
                    onPressed: _clearFilters,
                    child: Text(
                      appLocalizations.translate('products.clear_filters') ?? 'Clear filters',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
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
                    ? _buildEmptyState(appLocalizations, theme)
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

  Widget _buildEmptyState(AppLocalizations appLocalizations, ThemeData theme) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 60,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              appLocalizations.translate('products.no_products') ?? 'No products found',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                appLocalizations.translate('products.adjust_search') ?? 'Try adjusting your search or filters to find what you\'re looking for.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(height: 32),
            if (widget.category != null || _searchController.text.isNotEmpty || _selectedCategory != 'all')
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _clearFilters,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Clear Filters',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}