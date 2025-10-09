import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maseru_marketplace/src/providers/cart_provider.dart';
import 'package:maseru_marketplace/src/services/order_service.dart';
import 'package:maseru_marketplace/src/services/api_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  String _selectedPaymentMethod = 'cash';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final orderService = OrderService(ApiService('http://localhost:5000/api/v1'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: _isProcessing
          ? _buildProcessingState()
          : _buildCheckoutForm(cartProvider, orderService),
    );
  }

  Widget _buildProcessingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Processing your order...'),
          SizedBox(height: 10),
          Text('Please wait'),
        ],
      ),
    );
  }

  Widget _buildCheckoutForm(CartProvider cartProvider, OrderService orderService) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Summary
          _buildOrderSummary(cartProvider),
          
          const SizedBox(height: 24),
          
          // Delivery Address
          _buildAddressSection(),
          
          const SizedBox(height: 24),
          
          // Payment Method
          _buildPaymentSection(),
          
          const SizedBox(height: 24),
          
          // Phone Number (for M-Pesa/EcoCash)
          if (_selectedPaymentMethod == 'mpesa' || _selectedPaymentMethod == 'ecocash')
            _buildPhoneSection(),
          
          const SizedBox(height: 32),
          
          // Place Order Button
          _buildPlaceOrderButton(cartProvider, orderService),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...cartProvider.cartItems.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${item.product.name.en} x${item.quantity}'),
                  Text('LSL ${(item.product.price * item.quantity).toStringAsFixed(2)}'),
                ],
              ),
            )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'LSL ${cartProvider.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Address',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Full Delivery Address *',
                hintText: 'Enter your complete delivery address',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: 'Delivery Instructions (Optional)',
                hintText: 'e.g., Ring doorbell, Leave at gate, etc.',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
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
      title: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Text(title),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_selectedPaymentMethod == 'mpesa' ? 'M-Pesa' : 'EcoCash'} Phone Number',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number *',
                hintText: _selectedPaymentMethod == 'mpesa' 
                    ? 'e.g., 2665XXXXXXX' 
                    : 'e.g., 2665XXXXXXX',
                border: const OutlineInputBorder(),
                prefixText: '+266 ',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            Text(
              _selectedPaymentMethod == 'mpesa'
                  ? 'You will receive an M-Pesa prompt to complete payment'
                  : 'You will receive an EcoCash prompt to complete payment',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceOrderButton(CartProvider cartProvider, OrderService orderService) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : () => _placeOrder(cartProvider, orderService),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.green,
          disabledBackgroundColor: Colors.green.withOpacity(0.5),
        ),
        child: _isProcessing
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Processing...'),
                ],
              )
            : const Text(
                'Place Order',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> _placeOrder(CartProvider cartProvider, OrderService orderService) async {
    // Validate required fields
    if (_addressController.text.isEmpty) {
      _showError('Please enter delivery address');
      return;
    }

    if ((_selectedPaymentMethod == 'mpesa' || _selectedPaymentMethod == 'ecocash') &&
        _phoneController.text.isEmpty) {
      _showError('Please enter your phone number for ${_selectedPaymentMethod == 'mpesa' ? 'M-Pesa' : 'EcoCash'}');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Prepare order items
      final items = cartProvider.cartItems.map((item) => {
        'productId': item.product.id,
        'productName': {
          'en': item.product.name.en,
          'st': item.product.name.st,
        },
        'quantity': item.quantity,
        'price': item.product.price,
      }).toList();

      // Create order
      final orderResponse = await orderService.createOrder(
        items: items,
        totalAmount: cartProvider.totalAmount,
        destinationAddress: _addressController.text,
        paymentMethod: _selectedPaymentMethod,
        destinationInstructions: _instructionsController.text.isEmpty 
            ? null 
            : _instructionsController.text,
        phoneNumber: _selectedPaymentMethod == 'cash' 
            ? null 
            : _phoneController.text,
      );

      if (orderResponse['status'] == 'success') {
        final orderId = orderResponse['data']?['order']?['_id'] ?? orderResponse['_id'];
        
        // If M-Pesa or EcoCash, initiate payment
        if (_selectedPaymentMethod == 'mpesa' || _selectedPaymentMethod == 'ecocash') {
          await _processMobilePayment(orderService, orderId, cartProvider.totalAmount);
        } else {
          // For cash, just show success
          _showSuccess('Order placed successfully!');
          cartProvider.clearCart();
          Navigator.pop(context); // Go back to previous screen
        }
      } else {
        _showError('Failed to create order: ${orderResponse['message']}');
      }
    } catch (e) {
      _showError('Error placing order: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _processMobilePayment(
    OrderService orderService, 
    String orderId, 
    double amount,
  ) async {
    try {
      Map<String, dynamic> paymentResponse;
      
      if (_selectedPaymentMethod == 'mpesa') {
        paymentResponse = await orderService.initiateMpesaPayment(
          orderId: orderId,
          phoneNumber: _phoneController.text,
          amount: amount,
        );
      } else {
        paymentResponse = await orderService.initiateEcocashPayment(
          orderId: orderId,
          phoneNumber: _phoneController.text,
          amount: amount,
        );
      }

      if (paymentResponse['status'] == 'success') {
        _showSuccess(
          'Payment initiated! Please check your phone to complete the ${_selectedPaymentMethod == 'mpesa' ? 'M-Pesa' : 'EcoCash'} payment.',
        );
        cartProvider.clearCart();
        Navigator.pop(context);
      } else {
        _showError('Payment initiation failed: ${paymentResponse['message']}');
      }
    } catch (e) {
      _showError('Payment error: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _instructionsController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}