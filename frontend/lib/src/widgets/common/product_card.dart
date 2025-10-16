import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maseru_marketplace/src/models/product_model.dart';
import 'package:maseru_marketplace/src/providers/cart_provider.dart';
import 'package:maseru_marketplace/src/screens/passenger/cart_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final bool showAddToCart;
  final Widget? trailing; // Added trailing parameter

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.showAddToCart = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final isInCart = cartProvider.isInCart(product.id);
    final cartQuantity = cartProvider.getQuantity(product.id);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(4), // Added margin to prevent overflow
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 280, // Ensure minimum height
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // FIX: Prevent unbounded height
            children: [
              // Product Image - FIXED: Constrained height
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade100,
                ),
                child: product.images.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.images.first.url,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderIcon();
                          },
                        ),
                      )
                    : _buildPlaceholderIcon(),
              ),
              
              const SizedBox(height: 8),
              
              // Product Name - FIXED: Constrained text
              SizedBox(
                height: 40, // Fixed height for name
                child: Text(
                  product.name.en.isNotEmpty ? product.name.en : 'Unnamed Product',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.2, // Better line height
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Category
              Text(
                product.category.isNotEmpty ? product.category : 'Uncategorized',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Price
              Text(
                'LSL ${product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  height: 1.2,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Stock & Add to Cart or Trailing - FIXED: Proper row constraints
              Container(
                height: 32, // Fixed height for bottom row
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Stock Info - FIXED: Flexible to prevent overflow
                    Flexible(
                      child: Text(
                        product.stockQuantity > 0 
                            ? '${product.stockQuantity} in stock'
                            : 'Out of stock',
                        style: TextStyle(
                          fontSize: 11,
                          color: product.stockQuantity > 0 ? Colors.green : Colors.red,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Trailing or Add to Cart - FIXED: Constrained width
                    if (trailing != null)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 80),
                        child: trailing!,
                      )
                    else if (showAddToCart && product.stockQuantity > 0)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 80),
                        child: isInCart
                            ? _buildQuantityControls(context, cartProvider, cartQuantity)
                            : _buildAddToCartButton(context, cartProvider),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Center(
      child: Icon(
        Icons.shopping_bag,
        size: 40,
        color: Colors.grey.shade400,
      ),
    );
  }

  Widget _buildAddToCartButton(BuildContext context, CartProvider cartProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: const Icon(Icons.add_shopping_cart, size: 16, color: Colors.white),
        onPressed: () {
          cartProvider.addToCart(product);
          _showAddToCartSnackbar(context);
        },
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 32,
        ),
      ),
    );
  }

  Widget _buildQuantityControls(BuildContext context, CartProvider cartProvider, int quantity) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Decrease button
          IconButton(
            icon: const Icon(Icons.remove, size: 14),
            onPressed: () => cartProvider.decrementQuantity(product.id),
            padding: const EdgeInsets.all(2),
            constraints: const BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
          ),
          
          // Quantity display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          
          // Increase button
          IconButton(
            icon: const Icon(Icons.add, size: 14),
            onPressed: () => cartProvider.incrementQuantity(product.id),
            padding: const EdgeInsets.all(2),
            constraints: const BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddToCartSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${product.name.en.isNotEmpty ? product.name.en : 'Product'} added to cart',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            );
          },
        ),
      ),
    );
  }
}