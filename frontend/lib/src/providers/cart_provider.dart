import 'package:flutter/foundation.dart';
import 'package:maseru_marketplace/src/models/product_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  double get subtotal => product.price * quantity;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.product.id == product.id;
  }

  @override
  int get hashCode => product.id.hashCode;
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => List.from(_cartItems);

  int get cartItemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => _cartItems.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));

  Map<String, List<CartItem>> getCartByVendor() {
    final Map<String, List<CartItem>> vendorCarts = {};
    for (var item in _cartItems) {
      final vendorId = item.product.vendorId;
      if (!vendorCarts.containsKey(vendorId)) {
        vendorCarts[vendorId] = [];
      }
      vendorCarts[vendorId]!.add(item);
    }
    return vendorCarts;
  }

  void addToCart(Product product, {int quantity = 1}) {
    if (quantity <= 0) return;

    final existingIndex = _cartItems.indexWhere((item) => item.product.id == product.id);

    if (existingIndex != -1) {
      final newQuantity = _cartItems[existingIndex].quantity + quantity;
      if (newQuantity > product.stockQuantity) return;
      _cartItems[existingIndex] = CartItem(
        product: product,
        quantity: newQuantity,
      );
    } else {
      if (quantity > product.stockQuantity) return;
      _cartItems.add(CartItem(
        product: product,
        quantity: quantity,
      ));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final existingIndex = _cartItems.indexWhere((item) => item.product.id == productId);
    if (existingIndex != -1) {
      final product = _cartItems[existingIndex].product;
      if (newQuantity > product.stockQuantity) return;
      _cartItems[existingIndex] = CartItem(
        product: product,
        quantity: newQuantity,
      );
      notifyListeners();
    }
  }

  void incrementQuantity(String productId) {
    final currentQuantity = getQuantity(productId);
    updateQuantity(productId, currentQuantity + 1);
  }

  void decrementQuantity(String productId) {
    final currentQuantity = getQuantity(productId);
    if (currentQuantity > 1) {
      updateQuantity(productId, currentQuantity - 1);
    } else {
      removeFromCart(productId);
    }
  }

  int getQuantity(String productId) {
    final item = _cartItems.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(
        product: Product(
          id: '',
          name: const ProductName(en: '', st: ''),
          description: const ProductDescription(en: '', st: ''),
          category: '',
          price: 0,
          currency: 'LSL',
          stockQuantity: 0,
          ratings: const ProductRatings(average: 0, count: 0),
          vendorId: '',
          priority: 1,
          images: [],
          tags: [],
          available: true,
          inStock: true,
        ),
        quantity: 0,
      ),
    );
    return item.quantity;
  }

  bool isInCart(String productId) {
    return _cartItems.any((item) => item.product.id == productId);
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // Get cart item by product ID
  CartItem? getCartItem(String productId) {
    try {
      return _cartItems.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }
}