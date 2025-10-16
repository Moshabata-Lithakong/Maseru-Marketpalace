import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  _EarningsScreenState createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  bool _isLoading = false;
  double _previousEarnings = 0.0;
  bool _showEarningsUpdate = false;

  @override
  void initState() {
    super.initState();
    // Load earnings when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final orderProvider = context.read<OrderProvider>();
    _previousEarnings = orderProvider.driverEarnings;
    await orderProvider.getDriverDeliveryEarnings();
    await orderProvider.loadDriverAssignedDeliveries();
  }

  void _showEarningsAnimation() {
    setState(() {
      _showEarningsUpdate = true;
    });
    
    // Hide animation after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showEarningsUpdate = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Earnings'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Earnings',
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          final currentEarnings = orderProvider.driverEarnings;
          final earningsIncreased = currentEarnings > _previousEarnings;

          // Show animation when earnings increase
          if (earningsIncreased && !_showEarningsUpdate) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showEarningsAnimation();
              _previousEarnings = currentEarnings;
            });
          }

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Earnings Summary Card
                      _buildEarningsSummary(orderProvider),
                      
                      const SizedBox(height: 24),
                      
                      // Earnings Breakdown
                      _buildEarningsBreakdown(orderProvider),
                      
                      const SizedBox(height: 24),
                      
                      // Active Deliveries Section
                      _buildActiveDeliveries(orderProvider),

                      const SizedBox(height: 24),
                      
                      // Recent Completed Deliveries
                      _buildRecentCompletedDeliveries(orderProvider),
                    ],
                  ),
                ),
              ),

              // Earnings Update Animation
              if (_showEarningsUpdate)
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: _buildEarningsUpdateBanner(),
                ),

              // Loading Overlay
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEarningsSummary(OrderProvider orderProvider) {
    final totalEarnings = orderProvider.driverEarnings;
    final completedDeliveries = orderProvider.completedOrdersCount;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Earnings', 
                    style: TextStyle(fontSize: 18, color: Colors.grey)),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.attach_money, color: Colors.green[700]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                'LSL ${totalEarnings.toStringAsFixed(2)}',
                key: ValueKey(totalEarnings),
                style: const TextStyle(
                  fontSize: 32, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.green
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$completedDeliveries Completed Deliveries',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Today', 'LSL ${_calculateTodayEarnings(orderProvider)}'),
                _buildStatItem('This Week', 'LSL ${totalEarnings.toStringAsFixed(2)}'),
                _buildStatItem('Avg/Delivery', 'LSL ${_calculateAverageEarnings(orderProvider)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsBreakdown(OrderProvider orderProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Earnings Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildBreakdownItem('Standard Deliveries', _getStandardDeliveriesCount(orderProvider), 15.0),
            _buildBreakdownItem('Urgent Deliveries', _getUrgentDeliveriesCount(orderProvider), 25.0),
            _buildBreakdownItem('Bonus Earnings', _getBonusEarningsCount(orderProvider), 5.0),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownItem(String type, int count, double rate) {
    final total = count * rate;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(type, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            flex: 1,
            child: Text('$count', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'LSL ${total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 14, color: Colors.green),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveDeliveries(OrderProvider orderProvider) {
    final activeOrders = orderProvider.acceptedOrders
        .where((order) => order.isActiveForDriver)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Deliveries (${activeOrders.length})',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (activeOrders.isEmpty)
          _buildEmptyState(
            icon: Icons.delivery_dining,
            title: 'No active deliveries',
            subtitle: 'Accepted orders will appear here',
          )
        else
          Column(
            children: activeOrders.map((order) => _buildOrderCard(order, orderProvider)).toList(),
          ),
      ],
    );
  }

  Widget _buildRecentCompletedDeliveries(OrderProvider orderProvider) {
    final recentCompleted = _getCompletedOrders(orderProvider).take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Completed Deliveries',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (recentCompleted.isEmpty)
          _buildEmptyState(
            icon: Icons.history,
            title: 'No completed deliveries',
            subtitle: 'Completed deliveries will appear here',
          )
        else
          Column(
            children: recentCompleted.map((order) => _buildCompletedOrderItem(order)).toList(),
          ),
      ],
    );
  }

  Widget _buildCompletedOrderItem(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.id.substring(order.id.length - 6)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'LSL ${order.deliveryFee.toStringAsFixed(2)} • ${_formatDate(order.updatedAt)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Text(
              'LSL ${order.deliveryFee.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order, OrderProvider orderProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id.substring(order.id.length - 6)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(
                    order.status,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: _getStatusColor(order.status),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildLocationRow('Pickup', order.pickupLocation.address),
            const SizedBox(height: 8),
            _buildLocationRow('Delivery', order.destination.address),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fee: LSL ${order.deliveryFee.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (order.status == 'delivering')
                  ElevatedButton.icon(
                    onPressed: () => _completeDelivery(context, order, orderProvider),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Complete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(String label, String address) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        Expanded(
          child: Text(
            address,
            style: const TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value, 
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsUpdateBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.celebration, color: Colors.white),
          const SizedBox(width: 8),
          const Text(
            'Earnings Updated!',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ready':
        return Colors.orange;
      case 'delivering':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _completeDelivery(BuildContext context, Order order, OrderProvider orderProvider) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Delivery'),
        content: Text('Have you successfully delivered this order to ${order.destination.address}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Yes, Complete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Store previous earnings before completion
        _previousEarnings = orderProvider.driverEarnings;
        
        await orderProvider.completeDelivery(order.id);
        
        // Refresh earnings data
        await orderProvider.getDriverDeliveryEarnings();
        await orderProvider.loadDriverAssignedDeliveries();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery completed! Earnings updated.'),
            backgroundColor: Colors.green,
          ),
        );

        // Show earnings update animation
        _showEarningsAnimation();

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete delivery: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orderProvider = context.read<OrderProvider>();
      _previousEarnings = orderProvider.driverEarnings;
      await orderProvider.getDriverDeliveryEarnings();
      await orderProvider.loadDriverAssignedDeliveries();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper methods for calculations
  String _calculateTodayEarnings(OrderProvider orderProvider) {
    // You can implement actual today's earnings logic here
    // For now, return a portion of total earnings
    return (orderProvider.driverEarnings * 0.3).toStringAsFixed(2);
  }

  String _calculateAverageEarnings(OrderProvider orderProvider) {
    final completedCount = orderProvider.completedOrdersCount;
    if (completedCount == 0) return '0.00';
    return (orderProvider.driverEarnings / completedCount).toStringAsFixed(2);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }

  // Helper methods to replace missing properties
  int _getStandardDeliveriesCount(OrderProvider orderProvider) {
    final completedOrders = _getCompletedOrders(orderProvider);
    return completedOrders.where((order) => !order.isUrgent).length;
  }

  int _getUrgentDeliveriesCount(OrderProvider orderProvider) {
    final completedOrders = _getCompletedOrders(orderProvider);
    return completedOrders.where((order) => order.isUrgent).length;
  }

  int _getBonusEarningsCount(OrderProvider orderProvider) {
    // Calculate bonus based on some criteria
    final completedOrders = _getCompletedOrders(orderProvider);
    return completedOrders.where((order) => order.deliveryFee > 20.0).length;
  }

  List<Order> _getCompletedOrders(OrderProvider orderProvider) {
    return orderProvider.acceptedOrders.where((order) => order.isCompleted).toList();
  }
}