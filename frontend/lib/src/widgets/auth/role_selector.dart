import 'package:flutter/material.dart';
import 'package:maseru_marketplace/src/localization/app_localizations.dart';

class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final Function(String) onRoleChanged;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Your Role',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildRoleCard(
              context,
              role: 'passenger',
              title: 'Passenger',
              subtitle: 'Order products',
              icon: Icons.person,
              isSelected: selectedRole == 'passenger',
            ),
            _buildRoleCard(
              context,
              role: 'vendor',
              title: 'Vendor',
              subtitle: 'Sell products',
              icon: Icons.store,
              isSelected: selectedRole == 'vendor',
            ),
            _buildRoleCard(
              context,
              role: 'taxi_driver',
              title: 'Taxi Driver',
              subtitle: 'Deliver orders',
              icon: Icons.directions_car,
              isSelected: selectedRole == 'taxi_driver',
            ),
            _buildRoleCard(
              context,
              role: 'admin',
              title: 'Admin',
              subtitle: 'Manage platform',
              icon: Icons.admin_panel_settings,
              isSelected: selectedRole == 'admin',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String role,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onRoleChanged(role),
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.grey[50],
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey[400],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey[500],
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}