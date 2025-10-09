import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maseru_marketplace/src/localization/app_localizations.dart';
import 'package:maseru_marketplace/src/providers/order_provider.dart';
import 'package:maseru_marketplace/src/providers/theme_provider.dart';
import 'package:maseru_marketplace/src/widgets/common/loading_indicator.dart';

class DeliveryRequestScreen extends StatefulWidget {
  const DeliveryRequestScreen({super.key});

  @override
  State<DeliveryRequestScreen> createState() => _DeliveryRequestScreenState();
}

class _DeliveryRequestScreenState extends State<DeliveryRequestScreen> {
  final List<String> _requestTypes = ['all', 'delivery', 'taxi', 'urgent'];
  String _selectedType = 'all';
  bool _isLoading = true;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    try {
      await orderProvider.loadDriverOrders();
    } catch (e) {
      print('Error loading delivery requests: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<dynamic> _getAvailableRequests(List<dynamic> orders) {
    return orders.where((order) {
      final orderMap = order as Map<String, dynamic>;
      final status = orderMap['status']?.toString() ?? '';
      final taxiDriverId = orderMap['taxiDriverId'];
      
      return (status == 'ready' || status == 'pending') && taxiDriverId == null;
    }).toList();
  }

  List<dynamic> _getFilteredRequests(List<dynamic> orders) {
    final availableRequests = _getAvailableRequests(orders);
    
    if (_selectedType == 'all') return availableRequests;
    if (_selectedType == 'urgent') {
      return availableRequests.where((order) {
        final orderMap = order as Map<String, dynamic>;
        return orderMap['isUrgent'] as bool? ?? false;
      }).toList();
    }
    return availableRequests;
  }

  void _acceptDelivery(Map<String, dynamic> order) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final orderId = order['_id']?.toString() ?? order['id']?.toString() ?? '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Delivery?'),
        content: const Text('Do you want to accept this delivery request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              orderProvider.updateOrderStatus(orderId, 'delivering');
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delivery accepted successfully!')),
              );
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _viewRequestDetails(Map<String, dynamic> order) {
    final orderId = order['_id']?.toString() ?? order['id']?.toString() ?? '';
    final orderStatus = order['status']?.toString() ?? 'pending';
    final deliveryFee = (order['deliveryFee'] as num?)?.toDouble() ?? 0.0;
    final isUrgent = order['isUrgent'] as bool? ?? false;
    final pickupLocation = order['pickupLocation']?.toString() ?? 'Vendor Location';
    final destination = order['destination']?.toString() ?? 'Customer Location';
    final items = order['items'] as List<dynamic>? ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Delivery Request Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Request Info
                    _buildDetailRow('Request ID', '#${orderId.substring(0, 8)}'),
                    _buildDetailRow('Type', 'Product Delivery'),
                    _buildDetailRow('Status', orderStatus.toUpperCase()),
                    _buildDetailRow('Delivery Fee', 'LSL ${deliveryFee.toStringAsFixed(2)}'),
                    
                    const SizedBox(height: 20),
                    
                    // Pickup Information
                    const Text(
                      'Pickup Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildLocationCard(
                      icon: Icons.store,
                      title: 'Vendor Location',
                      subtitle: pickupLocation,
                      color: Colors.blue,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Delivery Information
                    const Text(
                      'Delivery Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildLocationCard(
                      icon: Icons.location_on,
                      title: 'Customer Location',
                      subtitle: destination,
                      color: Colors.green,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Items
                    const Text(
                      'Items to Deliver',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...items.map((item) {
                      final itemMap = item as Map<String, dynamic>;
                      final productName = itemMap['productName'] as Map<String, dynamic>? ?? {};
                      final quantity = itemMap['quantity'] as int? ?? 1;
                      final price = (itemMap['price'] as num?)?.toDouble() ?? 0.0;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.shopping_bag, color: Colors.grey[600]),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(productName['en']?.toString() ?? 'Product'),
                                  Text(
                                    '$quantity x LSL ${price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 30),
                    
                    // Actions
                    if (orderStatus == 'ready' || orderStatus == 'pending')
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _acceptDelivery(order);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Accept Delivery',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 12),
                    
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _contactVendor(order),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Contact Vendor'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.directions, color: color),
            onPressed: () {
              // Open directions
            },
          ),
        ],
      ),
    );
  }

  void _contactVendor(Map<String, dynamic> order) {
    // Implement vendor contact functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contacting vendor...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final appLocalizations = AppLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final filteredRequests = _getFilteredRequests(orderProvider.driverOrders);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(appLocalizations.translate('delivery_requests.title') ?? 'Delivery Requests'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Switch(
            value: _isOnline,
            onChanged: (value) {
              setState(() {
                _isOnline = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value ? 
                    'You are now online and available for requests' : 
                    'You are now offline'
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Online Status Banner
          if (_isOnline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.green,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.circle, color: Colors.white, size: 8),
                  const SizedBox(width: 8),
                  const Text(
                    'ONLINE - Available for deliveries',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _requestTypes.map((type) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        type == 'all' ? 'All' : 
                        type == 'delivery' ? 'Deliveries' :
                        type == 'taxi' ? 'Taxi Rides' : 'Urgent',
                      ),
                      selected: _selectedType == type,
                      onSelected: (selected) {
                        setState(() {
                          _selectedType = type;
                        });
                      },
                      backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
                      selectedColor: Theme.of(context).primaryColor,
                      labelStyle: TextStyle(
                        color: _selectedType == type ? Colors.white : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Requests List
          Expanded(
            child: !_isOnline
                ? _buildOfflineState()
                : _isLoading
                    ? const Center(child: LoadingIndicator())
                    : filteredRequests.isEmpty
                        ? _buildEmptyState(appLocalizations)
                        : RefreshIndicator(
                            onRefresh: _loadRequests,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: filteredRequests.length,
                              itemBuilder: (context, index) {
                                final request = filteredRequests[index];
                                return _buildRequestCard(context, request);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, dynamic request) {
    final requestMap = request as Map<String, dynamic>;
    final isUrgent = requestMap['isUrgent'] as bool? ?? false;
    final deliveryFee = (requestMap['deliveryFee'] as num?)?.toDouble() ?? 0.0;
    final orderId = requestMap['_id']?.toString() ?? requestMap['id']?.toString() ?? '';
    final items = requestMap['items'] as List<dynamic>? ?? [];
    final pickupLocation = requestMap['pickupLocation']?.toString() ?? 'Vendor Location';
    final destination = requestMap['destination']?.toString() ?? 'Customer Location';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isUrgent ? Border.all(color: Colors.red, width: 2) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _viewRequestDetails(requestMap),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Delivery #${orderId.substring(0, 8)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isUrgent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'URGENT',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$pickupLocation to $destination',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.shopping_bag, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      '${items.length} items',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LSL ${deliveryFee.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _acceptDelivery(requestMap),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Accept'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          const Text(
            'You are Offline',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Go online to see delivery requests',
            style: TextStyle(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isOnline = true;
              });
            },
            child: const Text('Go Online'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations appLocalizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delivery_dining_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            appLocalizations.translate('delivery_requests.no_requests') ?? 'No Delivery Requests',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            appLocalizations.translate('delivery_requests.no_requests_status') ?? 'New delivery requests will appear here',
            style: const TextStyle(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadRequests,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}