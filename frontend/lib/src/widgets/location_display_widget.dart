import 'package:flutter/material.dart';
import 'package:maseru_marketplace/src/localization/app_localizations.dart';

class LocationDisplayWidget extends StatelessWidget {
  final String address;
  final String? landmark;
  final String? instructions;
  final String? contactName;
  final String? contactPhone;
  final bool isPickupLocation;
  final VoidCallback? onEdit;

  const LocationDisplayWidget({
    Key? key,
    required this.address,
    this.landmark,
    this.instructions,
    this.contactName,
    this.contactPhone,
    this.isPickupLocation = false,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isPickupLocation
                      ? appLocalizations.translate('location.pickup_location') ?? 'Pickup Location'
                      : appLocalizations.translate('location.delivery_location') ?? 'Delivery Location',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    icon: Icon(Icons.edit, size: 20),
                    onPressed: onEdit,
                  ),
              ],
            ),
            SizedBox(height: 12),
            
            // Address
            _buildInfoRow(
              Icons.location_on,
              address,
            ),
            
            // Landmark
            if (landmark != null && landmark!.isNotEmpty)
              _buildInfoRow(
                Icons.place,
                'Near $landmark',
                isSecondary: true,
              ),
            
            // Contact Information (for delivery)
            if (!isPickupLocation && contactName != null && contactName!.isNotEmpty)
              _buildInfoRow(
                Icons.person,
                'Contact: $contactName',
                isSecondary: true,
              ),
            
            if (!isPickupLocation && contactPhone != null && contactPhone!.isNotEmpty)
              _buildInfoRow(
                Icons.phone,
                'Phone: $contactPhone',
                isSecondary: true,
              ),
            
            // Instructions
            if (instructions != null && instructions!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(
                    isPickupLocation
                        ? appLocalizations.translate('location.pickup_instructions') ?? 'Pickup Instructions:'
                        : appLocalizations.translate('location.delivery_instructions') ?? 'Delivery Instructions:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    instructions!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {bool isSecondary = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSecondary ? Colors.grey : Colors.blue,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isSecondary ? Colors.grey[600] : Colors.black87,
                fontSize: isSecondary ? 14 : 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}