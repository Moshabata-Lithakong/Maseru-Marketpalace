import 'package:flutter/material.dart';
import 'package:maseru_marketplace/src/localization/app_localizations.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final List<Map<String, dynamic>> _users = [
    {
      'id': '1',
      'name': 'John Doe',
      'email': 'john@example.com',
      'role': 'passenger',
      'status': 'active',
      'joinDate': '2024-01-15',
      'orders': 12,
    },
    {
      'id': '2',
      'name': 'Sarah Wilson',
      'email': 'sarah@example.com',
      'role': 'vendor',
      'status': 'active',
      'joinDate': '2024-01-10',
      'orders': 45,
    },
    {
      'id': '3',
      'name': 'Mike Johnson',
      'email': 'mike@example.com',
      'role': 'taxi_driver',
      'status': 'pending',
      'joinDate': '2024-01-20',
      'orders': 8,
    },
    {
      'id': '4',
      'name': 'Emily Davis',
      'email': 'emily@example.com',
      'role': 'passenger',
      'status': 'suspended',
      'joinDate': '2024-01-05',
      'orders': 3,
    },
  ];

  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          appLocalizations.translate('admin.user_management'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header Stats
          _buildHeaderStats(),
          
          // Search and Filters
          _buildSearchAndFilters(),
          
          // Users List
          Expanded(
            child: _buildUsersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total Users', '1,234', Colors.blue),
          _buildStatItem('Active Today', '156', Colors.green),
          _buildStatItem('Pending', '23', Colors.orange),
          _buildStatItem('Suspended', '12', Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: _selectedFilter,
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Users')),
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedFilter = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    final filteredUsers = _users.where((user) {
      final matchesSearch = user['name'].toString().toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          user['email'].toString().toLowerCase().contains(
                _searchController.text.toLowerCase(),
              );
      
      final matchesFilter = _selectedFilter == 'all' || 
          user['status'] == _selectedFilter;
      
      return matchesSearch && matchesFilter;
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(user['role']),
          child: Text(
            user['name'][0],
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          user['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user['email']),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatusChip(user['status']),
                const SizedBox(width: 8),
                _buildRoleChip(user['role']),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit User')),
            const PopupMenuItem(value: 'view', child: Text('View Details')),
            const PopupMenuItem(value: 'suspend', child: Text('Suspend')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
          onSelected: (value) {
            _handleUserAction(value, user);
          },
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'active':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'suspended':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildRoleChip(String role) {
    return Chip(
      label: Text(
        role.toUpperCase(),
        style: const TextStyle(fontSize: 10),
      ),
      backgroundColor: _getRoleColor(role).withOpacity(0.1),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'vendor':
        return Colors.blue;
      case 'taxi_driver':
        return Colors.orange;
      case 'admin':
        return Colors.purple;
      default:
        return Colors.green;
    }
  }

  void _handleUserAction(String action, Map<String, dynamic> user) {
    switch (action) {
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'view':
        _showUserDetails(user);
        break;
      case 'suspend':
        _showSuspendDialog(user);
        break;
      case 'delete':
        _showDeleteDialog(user);
        break;
    }
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: const Text('User edit functionality to be implemented'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details - ${user['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user['email']}'),
            Text('Role: ${user['role']}'),
            Text('Status: ${user['status']}'),
            Text('Join Date: ${user['joinDate']}'),
            Text('Total Orders: ${user['orders']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSuspendDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspend User'),
        content: Text('Are you sure you want to suspend ${user['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement suspend logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user['name']} has been suspended')),
              );
            },
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user['name']}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement delete logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user['name']} has been deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}