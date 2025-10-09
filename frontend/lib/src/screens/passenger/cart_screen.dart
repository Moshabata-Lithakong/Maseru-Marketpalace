import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maseru_marketplace/src/providers/cart_provider.dart';
import 'package:maseru_marketplace/src/providers/order_provider.dart';
import 'package:maseru_marketplace/src/localization/app_localizations.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  String _selectedPaymentMethod = 'cash';
  bool _isUrgent = false;
  bool _isLoading = false;

  double get deliveryFee => _isUrgent ? 25.0 : 15.0;

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final appLocalizations = AppLocalizations.of(context);
    final cartItems = cartProvider.cartItems;

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.translate('cart.title') ?? 'Shopping Cart'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _clearCart(cartProvider),
              tooltip: 'Clear Cart',
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCartState(appLocalizations)
          : _buildCartWithItems(cartProvider, cartItems, appLocalizations),
    );
  }

  Widget _buildEmptyCartState(AppLocalizations appLocalizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            appLocalizations.translate('cart.empty') ?? 'Your cart is empty',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            appLocalizations.translate('cart.empty_message') ?? 'Add some products to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartWithItems(CartProvider cartProvider, List<CartItem> cartItems, AppLocalizations appLocalizations) {
    return Column(
      children: [
        // Cart Items with proper scrolling
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartItems[index];
                      final product = cartItem.product;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: product.images.isNotEmpty 
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      product.images.first.url,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.shopping_bag);
                                      },
                                    ),
                                  )
                                : const Icon(Icons.shopping_bag),
                          ),
                          title: Text(
                            product.name.en,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LSL ${product.price.toStringAsFixed(2)} each',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                'Quantity: ${cartItem.quantity}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                'Subtotal: LSL ${cartItem.subtotal.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          trailing: SizedBox(
                            width: 120,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Quantity Controls
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 16),
                                  onPressed: () => cartProvider.decrementQuantity(product.id),
                                  padding: const EdgeInsets.all(4),
                                ),
                                Text(
                                  '${cartItem.quantity}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 16),
                                  onPressed: () => cartProvider.incrementQuantity(product.id),
                                  padding: const EdgeInsets.all(4),
                                ),
                                // Remove Button
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                  onPressed: () => cartProvider.removeFromCart(product.id),
                                  padding: const EdgeInsets.all(4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Add bottom padding to prevent overlap with checkout section
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),

        // Checkout Section - Fixed at bottom
        _buildCheckoutSection(cartProvider),
      ],
    );
  }

  Widget _buildCheckoutSection(CartProvider cartProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Delivery Information
            _buildDeliveryInformation(),

            const SizedBox(height: 12),

            // Payment Method
            _buildPaymentSection(),

            // Phone Number (for M-Pesa/EcoCash)
            if (_selectedPaymentMethod == 'mpesa' || _selectedPaymentMethod == 'ecocash')
              Column(
                children: [
                  const SizedBox(height: 12),
                  _buildPhoneSection(),
                ],
              ),

            const SizedBox(height: 12),

            // Order Summary
            _buildOrderSummary(cartProvider),

            const SizedBox(height: 16),

            // Checkout Button
            _buildCheckoutButton(cartProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryInformation() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _destinationController,
              decoration: const InputDecoration(
                labelText: 'Delivery Address *',
                hintText: 'Enter your complete delivery address',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: 'Delivery Instructions (Optional)',
                hintText: 'e.g., Ring doorbell, Leave at gate, etc.',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: _isUrgent,
                  onChanged: (value) {
                    setState(() {
                      _isUrgent = value ?? false;
                    });
                  },
                ),
                const Text('Urgent Delivery (+LSL 10.00)'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),
            _buildPaymentOption('Cash on Delivery', 'cash', Icons.money),
            _buildPaymentOption('M-Pesa', 'mpesa', Icons.phone_android),
            _buildPaymentOption('EcoCash', 'ecocash', Icons.phone_iphone),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, String value, IconData icon) {
    return RadioListTile<String>(
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 14)),
        ],
      ),
      value: value,
      groupValue: _selectedPaymentMethod,
      onChanged: (String? newValue) {
        setState(() {
          _selectedPaymentMethod = newValue!;
        });
      },
    );
  }

  Widget _buildPhoneSection() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_selectedPaymentMethod == 'mpesa' ? 'M-Pesa' : 'EcoCash'} Phone Number',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number *',
                hintText: _selectedPaymentMethod == 'mpesa' 
                    ? 'e.g., 2665XXXXXXX' 
                    : 'e.g., 2665XXXXXXX',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                prefixText: '+266 ',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 4),
            Text(
              _selectedPaymentMethod == 'mpesa'
                  ? 'You will receive an M-Pesa prompt to complete payment'
                  : 'You will receive an EcoCash prompt to complete payment',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:', style: TextStyle(fontSize: 14)),
                Text('LSL ${cartProvider.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Delivery Fee:', style: TextStyle(fontSize: 14)),
                Text('LSL ${deliveryFee.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14)),
              ],
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16),
                ),
                Text(
                  'LSL ${(cartProvider.totalAmount + deliveryFee).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutButton(CartProvider cartProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _placeOrder(cartProvider),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Place Order - LSL ${(cartProvider.totalAmount + deliveryFee).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _placeOrder(CartProvider cartProvider) async {
    // Validate required fields
    if (_destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter delivery address')),
      );
      return;
    }

    if ((_selectedPaymentMethod == 'mpesa' || _selectedPaymentMethod == 'ecocash') &&
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your phone number for ${_selectedPaymentMethod == 'mpesa' ? 'M-Pesa' : 'EcoCash'}')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    try {
      // Prepare order items
      final orderItems = cartProvider.cartItems.map((cartItem) {
        return {
          'productId': cartItem.product.id,
          'productName': {
            'en': cartItem.product.name.en,
            'st': cartItem.product.name.st,
          },
          'quantity': cartItem.quantity,
          'price': cartItem.product.price,
        };
      }).toList();

      // Create order
      final success = await orderProvider.createOrder(
        items: orderItems,
        totalAmount: cartProvider.totalAmount + deliveryFee,
        destinationAddress: _destinationController.text,
        paymentMethod: _selectedPaymentMethod,
        destinationInstructions: _instructionsController.text.isEmpty 
            ? null 
            : _instructionsController.text,
        phoneNumber: _selectedPaymentMethod == 'cash' 
            ? null 
            : _phoneController.text,
        isUrgent: _isUrgent,
        notes: _instructionsController.text.isEmpty ? null : _instructionsController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        // Clear cart on successful order
        cartProvider.clearCart();
        
        // Show success message based on payment method
        String successMessage = 'Order placed successfully!';
        if (_selectedPaymentMethod == 'mpesa') {
          successMessage = 'Order placed! Please check your phone for M-Pesa payment prompt.';
        } else if (_selectedPaymentMethod == 'ecocash') {
          successMessage = 'Order placed! Please check your phone for EcoCash payment prompt.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: ${orderProvider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error placing order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearCart(CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to clear your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              cartProvider.clearCart();
              Navigator.pop(context);
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _instructionsController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}