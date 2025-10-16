import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maseru_marketplace/src/providers/cart_provider.dart';
import 'package:maseru_marketplace/src/providers/order_provider.dart';
import 'package:maseru_marketplace/src/providers/payment_provider.dart';
import 'package:maseru_marketplace/src/models/order_model.dart';
import 'package:maseru_marketplace/src/localization/app_localizations.dart';
import 'package:maseru_marketplace/src/widgets/common/loading_indicator.dart';

class PaymentScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final String vendorId;
  final double destinationLatitude;
  final double destinationLongitude;
  final String? deliveryInstructions;
  final bool isUrgent;

  const PaymentScreen({
    super.key,
    required this.cartItems,
    required this.vendorId,
    required this.destinationLatitude,
    required this.destinationLongitude,
    this.deliveryInstructions,
    this.isUrgent = false,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'cash';
  bool _isProcessingOrder = false;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _passengerNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _phoneController.text = '+266';
    _passengerNameController.text = 'Passenger'; // Default name
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final appLocalizations = AppLocalizations.of(context);

    final vendorCarts = cartProvider.getCartByVendor();
    final totalAmount = cartProvider.totalAmount;
    final deliveryFee = widget.isUrgent ? 25.0 : 15.0;
    final grandTotal = totalAmount + deliveryFee;

    final isProcessing = _isProcessingOrder || paymentProvider.isProcessing;

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.translate('payment.title') ?? 'Payment'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: isProcessing
          ? _buildProcessingState(paymentProvider)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary
                    _buildOrderSummary(context, vendorCarts, totalAmount, deliveryFee, grandTotal, appLocalizations),

                    // Passenger Information
                    _buildPassengerInfoSection(),

                    // Payment Method Selection
                    _buildPaymentMethodSection(appLocalizations),

                    // Phone Number Input (for mobile payments)
                    if (_selectedPaymentMethod == 'mpesa' || _selectedPaymentMethod == 'ecocash')
                      _buildPhoneNumberSection(context),

                    // Additional Notes
                    _buildAdditionalNotesSection(),

                    // Payment Instructions
                    if (_selectedPaymentMethod == 'mpesa')
                      _buildPaymentInstructions(
                        'M-Pesa Payment Instructions:',
                        [
                          '1. Ensure you have sufficient balance in your M-Pesa account',
                          '2. You will receive a payment request on your phone',
                          '3. Enter your M-Pesa PIN to complete the payment',
                          '4. Wait for payment confirmation',
                        ],
                        Colors.green[700]!,
                      ),

                    if (_selectedPaymentMethod == 'ecocash')
                      _buildPaymentInstructions(
                        'EcoCash Payment Instructions:',
                        [
                          '1. Ensure you have sufficient balance in your EcoCash account',
                          '2. You will receive a payment prompt on your phone',
                          '3. Follow the instructions to authorize payment',
                          '4. Wait for payment confirmation',
                        ],
                        Colors.orange[700]!,
                      ),

                    // Error Display
                    if (paymentProvider.error != null)
                      _buildErrorSection(paymentProvider),

                    // Confirm Payment Button
                    _buildConfirmButton(context, orderProvider, paymentProvider, cartProvider, grandTotal, appLocalizations),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProcessingState(PaymentProvider paymentProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoadingIndicator(),
          const SizedBox(height: 20),
          Text(
            paymentProvider.paymentStatus == 'initiating' 
                ? 'Initiating payment...'
                : 'Processing your order...',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (paymentProvider.paymentStatus == 'processing')
            const Text(
              'Please check your phone to complete payment',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          if (paymentProvider.transactionId != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Transaction: ${paymentProvider.transactionId}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPassengerInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Your Information',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passengerNameController,
          decoration: const InputDecoration(
            labelText: 'Your Name *',
            hintText: 'Enter your full name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Text(
          'This name will be shared with the vendor for delivery',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildOrderSummary(
    BuildContext context,
    Map<String, List<CartItem>> vendorCarts,
    double totalAmount,
    double deliveryFee,
    double grandTotal,
    AppLocalizations appLocalizations,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appLocalizations.translate('payment.order_summary') ?? 'Order Summary',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        const SizedBox(height: 16),
        
        // Vendor carts
        ...vendorCarts.entries.map((entry) {
          final vendorId = entry.key;
          final items = entry.value;
          final vendorTotal = items.fold<double>(
            0.0,
            (sum, item) => sum + (item.product.price * item.quantity),
          );
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vendor Order',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...items.map((item) => ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: item.product.images.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item.product.images.first.url,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.shopping_bag, size: 20, color: Colors.green[700]);
                                    },
                                  ),
                                )
                              : Icon(Icons.shopping_bag, size: 20, color: Colors.green[700]),
                        ),
                        title: Text(
                          item.product.name.en,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          'LSL ${item.product.price.toStringAsFixed(2)} x ${item.quantity}',
                        ),
                        trailing: Text(
                          'LSL ${(item.product.price * item.quantity).toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      )),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Vendor Subtotal:',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'LSL ${vendorTotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),

        // Order Total Summary
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'LSL ${totalAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Delivery Fee:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'LSL ${deliveryFee.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                if (widget.isUrgent) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Urgent Delivery:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.orange),
                      ),
                      Text(
                        '+LSL 10.00',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.orange),
                      ),
                    ],
                  ),
                ],
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount:',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    Text(
                      'LSL ${grandTotal.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection(AppLocalizations appLocalizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          appLocalizations.translate('payment.method') ?? 'Payment Method',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        const SizedBox(height: 8),
        
        // Cash on Delivery
        _buildPaymentMethodCard(
          'cash',
          'Cash on Delivery',
          'Pay when you receive your order',
          Icons.money,
          Colors.blue,
        ),
        
        // M-Pesa Payment
        _buildPaymentMethodCard(
          'mpesa',
          'M-Pesa',
          'Pay with your M-Pesa account',
          Icons.phone_android,
          Colors.green[700]!,
        ),
        
        // EcoCash Payment
        _buildPaymentMethodCard(
          'ecocash',
          'EcoCash',
          'Pay with your EcoCash account',
          Icons.phone_iphone,
          Colors.orange[700]!,
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(String method, String title, String subtitle, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: _selectedPaymentMethod == method ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _selectedPaymentMethod == method ? color : Colors.grey[300]!,
          width: _selectedPaymentMethod == method ? 2 : 1,
        ),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: _selectedPaymentMethod == method ? color : Colors.black87,
          ),
        ),
        subtitle: Text(subtitle),
        leading: Radio<String>(
          value: method,
          groupValue: _selectedPaymentMethod,
          onChanged: (value) {
            setState(() {
              _selectedPaymentMethod = value!;
            });
          },
          activeColor: color,
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        onTap: () {
          setState(() {
            _selectedPaymentMethod = method;
          });
        },
      ),
    );
  }

  Widget _buildPhoneNumberSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phone Number for Payment',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: '+266 1234 5678',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.phone),
              suffixIcon: IconButton(
                icon: const Icon(Icons.contacts),
                onPressed: _selectFromContacts,
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            validator: (value) {
              if (_selectedPaymentMethod != 'cash') {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                final cleanedValue = value.replaceAll(' ', '');
                if (!RegExp(r'^\+266[0-9]{8}$').hasMatch(cleanedValue)) {
                  return 'Please enter a valid Lesotho number (+266XXXXXXXX)';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Text(
            'We will send a payment request to this number',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Additional Notes (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          decoration: InputDecoration(
            hintText: 'Any special instructions for the delivery...',
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildPaymentInstructions(String title, List<String> instructions, Color color) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...instructions.map((instruction) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        instruction, 
                        style: const TextStyle(fontSize: 14, height: 1.4),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildErrorSection(PaymentProvider paymentProvider) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              paymentProvider.error!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: paymentProvider.clearError,
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(
    BuildContext context,
    OrderProvider orderProvider,
    PaymentProvider paymentProvider,
    CartProvider cartProvider,
    double grandTotal,
    AppLocalizations appLocalizations,
  ) {
    return Column(
      children: [
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isProcessingOrder ? null : () => _processPayment(orderProvider, paymentProvider, cartProvider),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: _getPaymentMethodColor(),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: _isProcessingOrder
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _getPaymentButtonText(appLocalizations, grandTotal),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        if (_selectedPaymentMethod == 'cash')
          Text(
            'You will pay LSL ${grandTotal.toStringAsFixed(2)} when you receive your order',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
      ],
    );
  }

  Color _getPaymentMethodColor() {
    switch (_selectedPaymentMethod) {
      case 'mpesa':
        return Colors.green[700]!;
      case 'ecocash':
        return Colors.orange[700]!;
      case 'cash':
      default:
        return Theme.of(context).primaryColor;
    }
  }

  String _getPaymentButtonText(AppLocalizations appLocalizations, double grandTotal) {
    final amountText = 'LSL ${grandTotal.toStringAsFixed(2)}';
    
    switch (_selectedPaymentMethod) {
      case 'mpesa':
        return 'PAY WITH M-PESA - $amountText';
      case 'ecocash':
        return 'PAY WITH ECOCASH - $amountText';
      case 'cash':
      default:
        return 'CONFIRM ORDER - $amountText';
    }
  }

  void _selectFromContacts() {
    // TODO: Implement contact picker functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact picker coming soon')),
    );
  }

  Future<void> _processPayment(
    OrderProvider orderProvider, 
    PaymentProvider paymentProvider, 
    CartProvider cartProvider,
  ) async {
    final appLocalizations = AppLocalizations.of(context);
    
    // Validate form
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields correctly'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate phone number for mobile payments
    if (_selectedPaymentMethod != 'cash') {
      final phone = _phoneController.text.replaceAll(' ', '');
      if (!RegExp(r'^\+266[0-9]{8}$').hasMatch(phone)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid Lesotho phone number (+266XXXXXXXX)'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _isProcessingOrder = true;
    });

    try {
      bool allOrdersSuccessful = true;
      List<String> createdOrderIds = [];

      // Create orders for each vendor
      for (var entry in cartProvider.getCartByVendor().entries) {
        final vendorId = entry.key;
        final items = entry.value;
        
        final orderItems = items
            .map((item) => {
                  'productId': item.product.id,
                  'productName': {
                    'en': item.product.name.en,
                    'st': item.product.name.st,
                  },
                  'quantity': item.quantity,
                  'price': item.product.price,
                })
            .toList();

        // FIXED: Create the order with all required parameters
        final success = await orderProvider.createOrder(
          vendorId: vendorId,
          items: orderItems,
          destinationLatitude: widget.destinationLatitude,
          destinationLongitude: widget.destinationLongitude,
          paymentMethod: _selectedPaymentMethod,
          destinationAddress: 'Selected Location',
          pickupAddress: 'Vendor Location',
          destinationInstructions: widget.deliveryInstructions,
          phoneNumber: _selectedPaymentMethod != 'cash' ? _phoneController.text : null,
          isUrgent: widget.isUrgent,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          vendorName: 'Vendor', // Default vendor name
          vendorPhone: '+26600000000', // Default vendor phone
          passengerName: _passengerNameController.text,
          passengerPhone: _phoneController.text,
        );

        if (!success) {
          allOrdersSuccessful = false;
          print('❌ Order creation failed for vendor: $vendorId');
          if (orderProvider.error != null) {
            print('❌ Order error: ${orderProvider.error}');
          }
        } else {
          // Get the created order ID from the latest order
          if (orderProvider.orders.isNotEmpty) {
            final latestOrder = orderProvider.orders.last;
            createdOrderIds.add(latestOrder.id);
            print('✅ Order created successfully for vendor: $vendorId, Order ID: ${latestOrder.id}');
          }
        }
      }

      if (allOrdersSuccessful && createdOrderIds.isNotEmpty) {
        // Process mobile payments if needed
        if (_selectedPaymentMethod == 'mpesa' || _selectedPaymentMethod == 'ecocash') {
          final orderId = createdOrderIds.first; // Use first order ID for payment
          
          print('💳 Processing ${_selectedPaymentMethod.toUpperCase()} payment for order: $orderId');
          
          bool paymentSuccess;
          if (_selectedPaymentMethod == 'mpesa') {
            paymentSuccess = await paymentProvider.initiateMpesaPayment(
              orderId: orderId,
              phoneNumber: _phoneController.text.replaceAll(' ', ''),
            );
          } else {
            paymentSuccess = await paymentProvider.initiateEcocashPayment(
              orderId: orderId,
              phoneNumber: _phoneController.text.replaceAll(' ', ''),
            );
          }

          if (paymentSuccess) {
            print('✅ Payment initiated successfully for order: $orderId');
            _showSuccessMessage(appLocalizations, true);
            cartProvider.clearCart();
            _navigateToHome();
          } else {
            // Payment failed but orders were created
            print('❌ Payment failed for order: $orderId - ${paymentProvider.error}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Orders created but payment failed: ${paymentProvider.error}'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } else {
          // Cash payment - success
          print('✅ Cash order created successfully');
          _showSuccessMessage(appLocalizations, false);
          cartProvider.clearCart();
          _navigateToHome();
        }
      } else {
        print('❌ Some orders failed to process');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              appLocalizations.translate('payment.error') ?? 'Some orders failed to process. Please try again.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Order processing error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${appLocalizations.translate('payment.error') ?? 'Order failed'}: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessingOrder = false;
      });
    }
  }

  void _showSuccessMessage(AppLocalizations appLocalizations, bool isMobilePayment) {
    String message;
    Color color = Colors.green;

    if (isMobilePayment) {
      message = _selectedPaymentMethod == 'mpesa'
          ? 'Order placed! Check your phone for M-Pesa payment request.'
          : 'Order placed! Check your phone for EcoCash payment request.';
    } else {
      message = 'Order placed successfully! Pay with cash on delivery.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _navigateToHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _notesController.dispose();
    _passengerNameController.dispose();
    super.dispose();
  }
}