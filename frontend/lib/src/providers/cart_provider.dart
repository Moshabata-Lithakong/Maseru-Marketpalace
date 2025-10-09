import 'package:flutter/foundation.dart';
import 'package:maseru_marketplace/src/models/product_model.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;
  
  int get cartItemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  
  double get totalAmount => _cartItems.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));

  void addToCart(Product product, {int quantity = 1}) {
    final existingIndex = _cartItems.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex != -1) {
      // Update quantity if product already in cart
      _cartItems[existingIndex] = CartItem(
        product: product,
        quantity: _cartItems[existingIndex].quantity + quantity,
      );
    } else {
      // Add new item to cart
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
      _cartItems[existingIndex] = CartItem(
        product: _cartItems[existingIndex].product,
        quantity: newQuantity,
      );
      notifyListeners();
    }
  }

  void incrementQuantity(String productId) {
    updateQuantity(productId, getQuantity(productId) + 1);
  }

  void decrementQuantity(String productId) {
    updateQuantity(productId, getQuantity(productId) - 1);
  }

  int getQuantity(String productId) {
    final item = _cartItems.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(product: Product(id: '', name: ProductName(en: '', st: ''), description: ProductDescription(en: '', st: ''), category: '', price: 0, stockQuantity: 0, ratings: ProductRatings(average: 0, count: 0), images: [], vendorId: ''), quantity: 0),
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
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  double get subtotal => product.price * quantity;
}