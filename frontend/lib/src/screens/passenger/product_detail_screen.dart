import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:maseru_marketplace/src/localization/app_localizations.dart';
import 'package:maseru_marketplace/src/models/product_model.dart';
import 'package:maseru_marketplace/src/providers/cart_provider.dart';
import 'package:maseru_marketplace/src/providers/product_provider.dart';
import 'package:flutter/services.dart';

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
  bool _isLoading = false;
  bool _isFavoriting = false;

  void _addToCart() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    try {
      // Validate quantity
      if (_quantity <= 0) {
        _showErrorSnackBar('Please select a valid quantity');
        return;
      }

      // Check stock availability
      if (_quantity > widget.product.stockQuantity) {
        _showErrorSnackBar('Only ${widget.product.stockQuantity} items available in stock');
        return;
      }

      // Add to cart
      cartProvider.addToCart(widget.product, quantity: _quantity);
      widget.onAddToCart?.call();
      
      // Haptic feedback
      HapticFeedback.heavyImpact();
      
      // Success message
      _showSuccessSnackBar('${widget.product.name.en} (x$_quantity) added to cart');
      
    } catch (e) {
      print('❌ Error adding to cart: $e');
      _showErrorSnackBar('Error adding to cart: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _buyNow() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Validate quantity
      if (_quantity <= 0) {
        _showErrorSnackBar('Please select a valid quantity');
        return;
      }

      // Check stock availability
      if (_quantity > widget.product.stockQuantity) {
        _showErrorSnackBar('Only ${widget.product.stockQuantity} items available in stock');
        return;
      }

      // Add to cart and proceed to checkout
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.addToCart(widget.product, quantity: _quantity);
      
      // Haptic feedback
      HapticFeedback.heavyImpact();
      
      // Success message
      _showSuccessSnackBar('${widget.product.name.en} added to cart');
      
      // Navigate to cart screen
      // Navigator.push(context, MaterialPageRoute(builder: (_) => CartScreen()));
      
    } catch (e) {
      print('❌ Error in buy now: $e');
      _showErrorSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isFavoriting) return;

    setState(() {
      _isFavoriting = true;
    });

    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    try {
      HapticFeedback.lightImpact();
      
      // Toggle favorite status
      await productProvider.toggleFavorite(widget.product.id);
      
      // Show success message
      _showSuccessSnackBar(
        widget.product.isFavorite 
            ? 'Removed from favorites' 
            : 'Added to favorites'
      );
    } catch (e) {
      print('❌ Error toggling favorite: $e');
      _showErrorSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isFavoriting = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildImageSection() {
    final theme = Theme.of(context);
    return Container(
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.surfaceVariant,
            theme.colorScheme.surface,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Product Image
          if (widget.product.images.isNotEmpty)
            CachedNetworkImage(
              imageUrl: widget.product.images.first.url,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => Container(
                color: theme.colorScheme.surfaceVariant,
                child: Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: theme.colorScheme.surfaceVariant,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 60, color: theme.colorScheme.onSurfaceVariant),
                      SizedBox(height: 12),
                      Text(
                        'Image not available',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Container(
              color: theme.colorScheme.surfaceVariant,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag, size: 80, color: theme.colorScheme.onSurfaceVariant),
                    SizedBox(height: 12),
                    Text(
                      'No image available',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          
          // Stock Badge
          if (widget.product.stockQuantity <= 0)
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'OUT OF STOCK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          
          // Urgent/Fast Delivery Badge
          if (widget.product.priority > 1)
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flash_on, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'FAST DELIVERY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductInfoSection(AppLocalizations appLocalizations) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name
          Text(
            widget.product.name.getLocalized(appLocalizations.currentLanguage),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          SizedBox(height: 8),
          
          // Price
          Text(
            'LSL ${widget.product.price.toStringAsFixed(2)}',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          
          // Description
          Text(
            widget.product.description.getLocalized(appLocalizations.currentLanguage),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              height: 1.6,
            ),
          ),
          SizedBox(height: 20),
          
          // Stock and Category Info
          _buildProductMetaInfo(theme),
          SizedBox(height: 24),
          
          // Quantity Selector
          _buildQuantitySelector(theme),
          SizedBox(height: 24),
          
          // Action Buttons
          _buildActionButtons(theme),
        ],
      ),
    );
  }

  Widget _buildProductMetaInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Stock Information
          Row(
            children: [
              Icon(
                widget.product.stockQuantity > 0 ? Icons.check_circle : Icons.cancel,
                color: widget.product.stockQuantity > 0 ? Colors.green : Colors.red,
                size: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.product.stockQuantity > 0
                      ? '${widget.product.stockQuantity} available in stock'
                      : 'Currently out of stock',
                  style: TextStyle(
                    color: widget.product.stockQuantity > 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          
          // Category
          Row(
            children: [
              Icon(Icons.category, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              SizedBox(width: 12),
              Text(
                'Category: ${widget.product.category}',
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
              ),
            ],
          ),
          SizedBox(height: 12),
          
          // Vendor Info (if available)
          if (widget.product.vendorId != null)
            Row(
              children: [
                Icon(Icons.store, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Sold by: ${_getVendorName()}',
                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quantity',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              // Decrease Button
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _isLoading || _quantity <= 1
                      ? null
                      : () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _quantity--;
                          });
                        },
                  icon: Icon(Icons.remove, color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
              
              // Quantity Display
              Container(
                width: 80,
                alignment: Alignment.center,
                child: Text(
                  '$_quantity',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              // Increase Button
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _isLoading || _quantity >= widget.product.stockQuantity
                      ? null
                      : () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _quantity++;
                          });
                        },
                  icon: Icon(Icons.add, color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
              
              Spacer(),
              
              // Total Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    'LSL ${(widget.product.price * _quantity).toStringAsFixed(2)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Stock warning
          if (_quantity > widget.product.stockQuantity)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(
                'Only ${widget.product.stockQuantity} items available',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    final isOutOfStock = widget.product.stockQuantity <= 0;
    
    return Column(
      children: [
        // Add to Cart Button
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _isLoading || isOutOfStock ? null : _addToCart,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: isOutOfStock ? Colors.grey : theme.colorScheme.primary,
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart, size: 20),
                      SizedBox(width: 8),
                      Text(
                        isOutOfStock 
                            ? 'Out of Stock' 
                            : 'Add to Cart - LSL ${(widget.product.price * _quantity).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        
        SizedBox(height: 12),
        
        // Buy Now Button
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _isLoading || isOutOfStock ? null : _buyNow,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: isOutOfStock ? Colors.grey : theme.colorScheme.secondary,
            ),
            child: Text(
              isOutOfStock ? 'Unavailable' : 'Buy Now',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getVendorName() {
    if (widget.product.vendorId is Map) {
      final vendor = widget.product.vendorId as Map<String, dynamic>;
      final profile = vendor['profile'] as Map<String, dynamic>?;
      if (profile != null) {
        return '${profile['firstName']} ${profile['lastName']}';
      }
    }
    return 'Unknown Vendor';
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product.name.getLocalized(appLocalizations.currentLanguage),
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: theme.colorScheme.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.colorScheme.onBackground,
        actions: [
          // Favorite Button
          IconButton(
            icon: _isFavoriting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : Icon(
                    widget.product.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: widget.product.isFavorite ? Colors.red : theme.colorScheme.onBackground,
                  ),
            tooltip: widget.product.isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
            onPressed: _toggleFavorite,
          ),
          
          // Share Button
          IconButton(
            icon: Icon(Icons.share, color: theme.colorScheme.onBackground),
            tooltip: 'Share Product',
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: Implement share functionality
              _showSuccessSnackBar('Share functionality coming soon');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Product Image Section
            _buildImageSection(),
            
            // Product Info Section
            _buildProductInfoSection(appLocalizations),
          ],
        ),
      ),
    );
  }
}