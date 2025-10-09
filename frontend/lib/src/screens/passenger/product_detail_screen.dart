import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:maseru_marketplace/src/localization/app_localizations.dart';
import 'package:maseru_marketplace/src/models/product_model.dart';
import 'package:maseru_marketplace/src/providers/order_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final VoidCallback? onAddToCart;

  const ProductDetailScreen({
    super.key, 
    required this.product,
    this.onAddToCart,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  void _addToCart() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final appLocalizations = AppLocalizations.of(context);
    
    // Create order item
    final orderItem = {
      'productId': widget.product.id,
      'productName': {
        'en': widget.product.name.en,
        'st': widget.product.name.st,
      },
      'quantity': _quantity,
      'price': widget.product.price,
    };

    // Call the onAddToCart callback if provided
    widget.onAddToCart?.call();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name.en} added to cart'),
        duration: const Duration(seconds: 2),
      ),
    );
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name.getLocalized(appLocalizations.currentLanguage)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey[200],
              child: widget.product.images.isNotEmpty 
                  ? CachedNetworkImage(
                      imageUrl: widget.product.images.first.url,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.shopping_bag, size: 80, color: Colors.grey),
                    ),
            ),
            
            // Product Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    widget.product.name.getLocalized(appLocalizations.currentLanguage),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Price
                  Text(
                    'LSL ${widget.product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    widget.product.description.getLocalized(appLocalizations.currentLanguage),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Stock Information
                  Row(
                    children: [
                      Icon(
                        widget.product.stockQuantity > 0 
                            ? Icons.check_circle 
                            : Icons.cancel,
                        color: widget.product.stockQuantity > 0 
                            ? Colors.green 
                            : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.product.stockQuantity > 0 
                            ? 'In Stock (${widget.product.stockQuantity} available)'
                            : 'Out of Stock',
                        style: TextStyle(
                          color: widget.product.stockQuantity > 0 
                              ? Colors.green 
                              : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quantity Selector
                  Row(
                    children: [
                      Text(
                        'Quantity:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _quantity > 1 
                                  ? () {
                                      setState(() {
                                        _quantity--;
                                      });
                                    }
                                  : null,
                              icon: const Icon(Icons.remove),
                              iconSize: 20,
                            ),
                            Container(
                              width: 40,
                              alignment: Alignment.center,
                              child: Text(
                                '$_quantity',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _quantity < widget.product.stockQuantity
                                  ? () {
                                      setState(() {
                                        _quantity++;
                                      });
                                    }
                                  : null,
                              icon: const Icon(Icons.add),
                              iconSize: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.product.stockQuantity > 0 ? _addToCart : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.product.stockQuantity > 0 
                            ? 'Add to Cart - LSL ${(widget.product.price * _quantity).toStringAsFixed(2)}'
                            : 'Out of Stock',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}