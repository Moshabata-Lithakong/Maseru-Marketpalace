import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maseru_marketplace/src/localization/app_localizations.dart';
import 'package:maseru_marketplace/src/providers/order_provider.dart';
import 'package:maseru_marketplace/src/widgets/common/loading_indicator.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _orderStatuses = const ['all', 'pending', 'confirmed', 'delivering', 'completed', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _orderStatuses.length, vsync: this);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.loadPassengerOrders();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.teal;
      case 'delivering':
        return Colors.indigo;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'preparing':
        return Icons.restaurant;
      case 'ready':
        return Icons.check_circle;
      case 'delivering':
        return Icons.delivery_dining;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.shopping_bag;
    }
  }

  List<dynamic> _getFilteredOrders(String status, List<dynamic> orders) {
    if (status == 'all') return orders;
    
    return orders.where((order) {
      final orderMap = order as Map<String, dynamic>;
      return orderMap['status']?.toLowerCase() == status.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.translate('orders.history')),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _orderStatuses.map((status) {
            return Tab(
              text: status == 'all' 
                  ? appLocalizations.translate('orders.all') 
                  : appLocalizations.translate('orders.$status') ?? status,
            );
          }).toList(),
        ),
      ),
      body: orderProvider.isLoading
          ? const Center(child: LoadingIndicator())
          : TabBarView(
              controller: _tabController,
              children: _orderStatuses.map((status) {
                final filteredOrders = _getFilteredOrders(status, orderProvider.orders);

                return filteredOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              appLocalizations.translate('orders.no_orders'),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              appLocalizations.translate('orders.no_orders_status') ?? 'No orders found for this status',
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          final orderMap = order as Map<String, dynamic>;
                          final orderStatus = orderMap['status']?.toString() ?? 'pending';
                          final orderId = orderMap['_id']?.toString() ?? orderMap['id']?.toString() ?? '';
                          final createdAt = orderMap['createdAt']?.toString() ?? '';
                          final totalAmount = (orderMap['totalAmount'] as num?)?.toDouble() ?? 0.0;
                          final items = orderMap['items'] as List<dynamic>? ?? [];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${appLocalizations.translate('orders.order')} #${orderId.substring(0, 8)}',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Chip(
                                        avatar: Icon(_getStatusIcon(orderStatus), color: Colors.white),
                                        label: Text(
                                          orderStatus.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                        backgroundColor: _getStatusColor(orderStatus),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('${appLocalizations.translate('orders.date')}: ${_formatDate(createdAt)}'),
                                  Text('${appLocalizations.translate('orders.total')}: LSL ${totalAmount.toStringAsFixed(2)}'),
                                  Text('${appLocalizations.translate('orders.items')}: ${items.length} ${appLocalizations.translate('orders.products')}'),
                                  const SizedBox(height: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: items.take(2).map((item) {
                                      final itemMap = item as Map<String, dynamic>;
                                      final productName = itemMap['productName'] as Map<String, dynamic>? ?? {};
                                      final quantity = itemMap['quantity'] as int? ?? 0;
                                      
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                                        child: Text(
                                          '• ${productName['en']?.toString() ?? 'Product'} x$quantity',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  if (items.length > 2)
                                    Text(
                                      '+ ${items.length - 2} ${appLocalizations.translate('orders.more_items') ?? 'more items'}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey,
                                          ),
                                    ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            _viewOrderDetails(context, orderMap);
                                          },
                                          child: Text(appLocalizations.translate('orders.view_details') ?? 'View Details'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (orderStatus == 'pending' || orderStatus == 'confirmed')
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              _cancelOrder(context, orderId);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            child: Text(appLocalizations.translate('orders.cancel') ?? 'Cancel'),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
              }).toList(),
            ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  void _viewOrderDetails(BuildContext context, Map<String, dynamic> order) {
    final appLocalizations = AppLocalizations.of(context);
    final items = order['items'] as List<dynamic>? ?? [];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appLocalizations.translate('orders.details') ?? 'Order Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${appLocalizations.translate('orders.id') ?? 'ID'}: ${order['_id'] ?? order['id']}'),
              Text('${appLocalizations.translate('orders.status') ?? 'Status'}: ${order['status']}'),
              Text('${appLocalizations.translate('orders.total') ?? 'Total'}: LSL ${(order['totalAmount'] as num?)?.toDouble() ?? 0.0}'),
              Text('${appLocalizations.translate('orders.date') ?? 'Date'}: ${_formatDate(order['createdAt']?.toString() ?? '')}'),
              const SizedBox(height: 16),
              Text(
                appLocalizations.translate('orders.items') ?? 'Items',
                style: const TextStyle(fontWeight: FontWeight.bold)
              ),
              ...items.map((item) {
                final itemMap = item as Map<String, dynamic>;
                final productName = itemMap['productName'] as Map<String, dynamic>? ?? {};
                final quantity = itemMap['quantity'] as int? ?? 0;
                final price = (itemMap['price'] as num?)?.toDouble() ?? 0.0;
                
                return Text(
                  '• ${productName['en']?.toString() ?? 'Product'} x$quantity - LSL ${price.toStringAsFixed(2)}'
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appLocalizations.translate('common.close') ?? 'Close'),
          ),
        ],
      ),
    );
  }

  void _cancelOrder(BuildContext context, String orderId) {
    final appLocalizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appLocalizations.translate('orders.cancel_title') ?? 'Cancel Order'),
        content: Text(appLocalizations.translate('orders.cancel_confirm') ?? 'Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appLocalizations.translate('common.cancel') ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmCancelOrder(context, orderId);
            },
            child: Text(appLocalizations.translate('orders.cancel_yes') ?? 'Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _confirmCancelOrder(BuildContext context, String orderId) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final appLocalizations = AppLocalizations.of(context);
    
    final success = await orderProvider.updateOrderStatus(orderId, 'cancelled');
    
    if (!context.mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.translate('orders.cancel_success') ?? 'Order cancelled successfully'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${appLocalizations.translate('common.error') ?? 'Error'}: ${orderProvider.error}'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}