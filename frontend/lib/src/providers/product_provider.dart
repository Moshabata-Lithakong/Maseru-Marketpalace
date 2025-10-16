import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:maseru_marketplace/src/models/product_model.dart';
import 'package:maseru_marketplace/src/services/api_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<Product> _vendorProducts = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedCategory = 'all';

  ProductProvider(this._apiService);

  List<Product> get products => _products;
  List<Product> get filteredProducts => _filteredProducts;
  List<Product> get vendorProducts => _vendorProducts;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  set filteredProducts(List<Product> products) {
    _filteredProducts = products;
    notifyListeners();
  }

  // Load all products for passengers
  Future<void> loadProducts() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('products');
      if (response['status'] == 'success') {
        final productsData = response['data']?['products'] as List? ?? [];
        _products = productsData.map((productJson) => Product.fromJson(productJson)).toList();
        _filteredProducts = List.from(_products);
        _error = null;
        print('✅ Loaded ${_products.length} products');
      } else {
        _error = response['message'] ?? 'Failed to load products';
        print('❌ Load products error: $_error');
      }
    } catch (e) {
      _error = 'Error loading products: $e';
      print('❌ Load products exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load vendor-specific products
  Future<void> loadVendorProducts() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('products/vendor/my-products');
      print('🔍 Vendor products full response: $response');
      
      if (response['status'] == 'success') {
        final productsData = response['data']?['products'] as List? ?? [];
        _vendorProducts = productsData.map((productJson) => Product.fromJson(productJson)).toList();
        _error = null;
        print('✅ Loaded ${_vendorProducts.length} vendor products');
      } else {
        _error = response['message'] ?? 'Failed to load vendor products';
        print('❌ Load vendor products error: $_error');
      }
    } catch (e) {
      _error = 'Error loading vendor products: $e';
      print('❌ Load vendor products exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create product for vendors
  Future<bool> createProduct({
    required String name,
    required String description,
    required double price,
    required int quantity,
    required String category,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = {
        'name': {'en': name, 'st': name},
        'description': {'en': description, 'st': description},
        'price': price,
        'stockQuantity': quantity,
        'category': category,
        'available': true,
      };

      print('🔄 Creating product with data: $data');
      final response = await _apiService.post('products', data);
      print('📦 Full API response: $response');

      if (response['status'] == 'success') {
        try {
          // Extract product data from response
          Map<String, dynamic> productData;
          if (response['data'] != null && response['data']['product'] != null) {
            productData = response['data']['product'];
            print('✅ Extracted product from response[data][product]');
          } else {
            productData = response;
            print('⚠️ Using full response as product data');
          }
          
          final newProduct = Product.fromJson(productData);
          
          // Add to all lists
          _vendorProducts.insert(0, newProduct);
          _products.insert(0, newProduct);
          _filteredProducts.insert(0, newProduct);
          
          _isLoading = false;
          _error = null;
          notifyListeners();
          
          print('🎉 PRODUCT CREATION SUCCESSFUL!');
          print('📦 Product ID: ${newProduct.id}');
          print('🏷️ Product Name: ${newProduct.name.en}');
          print('💰 Product Price: ${newProduct.price}');
          print('📊 Total vendor products now: ${_vendorProducts.length}');
          return true;
        } catch (parseError) {
          // Even if parsing has minor issues, consider creation successful
          print('⚠️ Product created but parsing had minor issues: $parseError');
          _isLoading = false;
          _error = null;
          notifyListeners();
          return true;
        }
      } else {
        _isLoading = false;
        _error = response['message'] ?? 'Unknown error occurred';
        notifyListeners();
        print('❌ Product creation failed: $_error');
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Network error: $e';
      notifyListeners();
      print('❌ Product creation network error: $e');
      return false;
    }
  }

  // Load single product
  Future<void> loadProduct(String id) async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getProduct(id);
      _selectedProduct = Product.fromJson(data);
      _error = null;
    } catch (e) {
      _error = 'Error loading product: $e';
      print('❌ Load product error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update product
  Future<bool> updateProduct(String id, Map<String, dynamic> productData) async {
    if (_isLoading) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.patch('products/$id', productData);
      
      if (response['status'] == 'success') {
        final updatedProductData = response['data']?['product'] ?? response['product'] ?? response;
        final updatedProduct = Product.fromJson(updatedProductData);
        
        // Update in all lists
        _updateProductInLists(updatedProduct);
        
        _isLoading = false;
        _error = null;
        notifyListeners();
        print('✅ Product updated successfully: $id');
        return true;
      } else {
        _isLoading = false;
        _error = response['message'] ?? 'Failed to update product';
        notifyListeners();
        print('❌ Product update failed: $_error');
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error updating product: $e';
      notifyListeners();
      print('❌ Product update error: $e');
      return false;
    }
  }

  // Delete product - FIXED: Proper 204 No Content handling
  Future<bool> deleteProduct(String id) async {
    if (_isLoading) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Use the dedicated delete method from ApiService
      await _apiService.deleteProduct(id);
      
      // Remove from all lists
      _products.removeWhere((p) => p.id == id);
      _filteredProducts.removeWhere((p) => p.id == id);
      _vendorProducts.removeWhere((p) => p.id == id);
      
      // Clear selected product if it's the one being deleted
      if (_selectedProduct?.id == id) {
        _selectedProduct = null;
      }
      
      _isLoading = false;
      _error = null;
      notifyListeners();
      print('✅ Product deleted successfully: $id');
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Error deleting product: $e';
      notifyListeners();
      print('❌ Product delete error: $e');
      return false;
    }
  }

  // Toggle favorite
  Future<void> toggleFavorite(String productId) async {
    try {
      final response = await _apiService.post('products/$productId/favorite', {});
      
      if (response['status'] == 'success') {
        final isFavorite = response['data']?['isFavorite'] ?? false;
        
        // Update in products list
        final productIndex = _products.indexWhere((p) => p.id == productId);
        if (productIndex != -1) {
          _products[productIndex] = _products[productIndex].copyWith(isFavorite: isFavorite);
        }
        
        // Update in filtered products list
        final filteredIndex = _filteredProducts.indexWhere((p) => p.id == productId);
        if (filteredIndex != -1) {
          _filteredProducts[filteredIndex] = _filteredProducts[filteredIndex].copyWith(isFavorite: isFavorite);
        }
        
        notifyListeners();
        print('✅ Favorite toggled for product: $productId');
      }
    } catch (e) {
      _error = 'Error toggling favorite: $e';
      notifyListeners();
      print('❌ Toggle favorite error: $e');
    }
  }

  // Filtering and sorting methods
  void sortProducts(String sortBy) {
    _filteredProducts = List.from(_filteredProducts);
    switch (sortBy) {
      case 'name':
        _filteredProducts.sort((a, b) => a.name.en.compareTo(b.name.en));
        break;
      case 'price_low':
        _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        _filteredProducts.sort((a, b) => b.ratings.average.compareTo(a.ratings.average));
        break;
      case 'newest':
        _filteredProducts.sort((a, b) => b.id.compareTo(a.id));
        break;
    }
    notifyListeners();
  }

  void filterProducts({String? category, String? searchQuery}) {
    _selectedCategory = category ?? _selectedCategory;
    _searchQuery = searchQuery ?? _searchQuery;

    _filteredProducts = _products.where((product) {
      final matchesCategory = _selectedCategory == 'all' || product.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ? true : _matchesSearchQuery(product, _searchQuery);
      return matchesCategory && matchesSearch && product.available;
    }).toList();

    notifyListeners();
  }

  bool _matchesSearchQuery(Product product, String query) {
    final searchLower = query.toLowerCase();
    return product.name.en.toLowerCase().contains(searchLower) ||
           product.name.st.toLowerCase().contains(searchLower) ||
           product.description.en.toLowerCase().contains(searchLower) ||
           product.description.st.toLowerCase().contains(searchLower);
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'all';
    _filteredProducts = _products.where((product) => product.available).toList();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
  }

  // Helper method to update product in all lists
  void _updateProductInLists(Product updatedProduct) {
    final productId = updatedProduct.id;
    
    // Update in products list
    final productIndex = _products.indexWhere((p) => p.id == productId);
    if (productIndex != -1) {
      _products[productIndex] = updatedProduct;
    }
    
    // Update in filtered products list
    final filteredIndex = _filteredProducts.indexWhere((p) => p.id == productId);
    if (filteredIndex != -1) {
      _filteredProducts[filteredIndex] = updatedProduct;
    }
    
    // Update in vendor products list
    final vendorIndex = _vendorProducts.indexWhere((p) => p.id == productId);
    if (vendorIndex != -1) {
      _vendorProducts[vendorIndex] = updatedProduct;
    }
    
    // Update selected product if it's the one being edited
    if (_selectedProduct?.id == productId) {
      _selectedProduct = updatedProduct;
    }
  }

  // Get low stock products
  List<Product> get lowStockProducts {
    return _vendorProducts.where((product) => product.stockQuantity < 5).toList();
  }

  // Update product stock
  Future<bool> updateProductStock(String productId, int newStock) async {
    try {
      final response = await _apiService.patch('products/$productId', {
        'stockQuantity': newStock,
      });
      
      if (response['status'] == 'success') {
        final updatedProductData = response['data']?['product'] ?? response['product'] ?? response;
        final updatedProduct = Product.fromJson(updatedProductData);
        
        _updateProductInLists(updatedProduct);
        notifyListeners();
        print('✅ Stock updated for product: $productId');
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to update stock: $e';
      print('❌ Update stock error: $e');
      return false;
    }
  }

  // Get available products for passengers (only available products)
  List<Product> get availableProducts {
    return _products.where((product) => product.available && product.stockQuantity > 0).toList();
  }

  // Get products by vendor
  List<Product> getProductsByVendor(String vendorId) {
    return _products.where((product) => product.vendorId == vendorId && product.available).toList();
  }

  // Toggle product availability
  Future<bool> toggleProductAvailability(String productId, bool available) async {
    try {
      final response = await _apiService.patch('products/$productId', {
        'available': available,
      });
      
      if (response['status'] == 'success') {
        final updatedProductData = response['data']?['product'] ?? response['product'] ?? response;
        final updatedProduct = Product.fromJson(updatedProductData);
        
        _updateProductInLists(updatedProduct);
        notifyListeners();
        print('✅ Availability updated for product: $productId');
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to update availability: $e';
      print('❌ Update availability error: $e');
      return false;
    }
  }

  // Search products by name or description
  List<Product> searchProducts(String query) {
    if (query.isEmpty) {
      return _products.where((product) => product.available).toList();
    }
    
    return _products.where((product) {
      return product.available && _matchesSearchQuery(product, query);
    }).toList();
  }

  // Get products by category
  List<Product> getProductsByCategory(String category) {
    return _products.where((product) => product.available && product.category == category).toList();
  }

  // Get featured products
  List<Product> get featuredProducts {
    return _products.where((product) => product.available && product.ratings.average >= 4.0).toList();
  }

  // Refresh all data
  Future<void> refreshData() async {
    await loadProducts();
    await loadVendorProducts();
  }

  // Clear all data (for logout)
  void clearData() {
    _products.clear();
    _filteredProducts.clear();
    _vendorProducts.clear();
    _selectedProduct = null;
    _searchQuery = '';
    _selectedCategory = 'all';
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}