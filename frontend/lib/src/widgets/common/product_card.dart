import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maseru_marketplace/src/models/product_model.dart';
import 'package:maseru_marketplace/src/providers/cart_provider.dart';
import 'package:maseru_marketplace/src/screens/passenger/cart_screen.dart'; // ADD THIS IMPORT

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final bool showAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.showAddToCart = true,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final isInCart = cartProvider.isInCart(product.id);
    final cartQuantity = cartProvider.getQuantity(product.id);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
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
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderIcon();
                          },
                        ),
                      )
                    : _buildPlaceholderIcon(),
              ),
              
              const SizedBox(height: 8),
              
              // Product Name
              Text(
                product.name.en,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Category
              Text(
                product.category,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Price
              Text(
                product.displayPrice,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              
              const Spacer(),
              
              // Stock & Add to Cart
              Row(
                children: [
                  // Stock Info
                  Expanded(
                    child: Text(
                      product.stockQuantity > 0 
                          ? '${product.stockQuantity} in stock'
                          : 'Out of stock',
                      style: TextStyle(
                        fontSize: 11,
                        color: product.stockQuantity > 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                  
                  // Add to Cart/Quantity Controls
                  if (showAddToCart && product.stockQuantity > 0) ...[
                    if (isInCart)
                      _buildQuantityControls(context, cartProvider, cartQuantity)
                    else
                      _buildAddToCartButton(context, cartProvider),
                  ],
                ],
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
    return IconButton(
      icon: const Icon(Icons.add_shopping_cart, size: 20),
      onPressed: () {
        cartProvider.addToCart(product);
        _showAddToCartSnackbar(context);
      },
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }

  Widget _buildQuantityControls(BuildContext context, CartProvider cartProvider, int quantity) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove, size: 16),
          onPressed: () => cartProvider.decrementQuantity(product.id),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Text(
          '$quantity',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.add, size: 16),
          onPressed: () => cartProvider.incrementQuantity(product.id),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  void _showAddToCartSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name.en} added to cart'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View Cart',
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