import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maseru_marketplace/src/providers/location_provider.dart';
import 'package:maseru_marketplace/src/localization/app_localizations.dart';

class LocationInputScreen extends StatefulWidget {
  final Function(String, String, String, String, double, double) onLocationSelected;
  final bool isPickupLocation;

  const LocationInputScreen({
    Key? key,
    required this.onLocationSelected,
    this.isPickupLocation = false,
  }) : super(key: key);

  @override
  _LocationInputScreenState createState() => _LocationInputScreenState();
}

class _LocationInputScreenState extends State<LocationInputScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  
  String? _selectedArea;
  bool _isLoading = false;

  // Common areas in Maseru
  final List<String> _maseruAreas = [
    'Maseru Central',
    'Thetsane',
    'Mazenod',
    'Ha Thetsane',
    'Ha Hlalefane',
    'Ha Foso',
    'Ha Leqele',
    'Roma',
    'Morija',
    'Teyateyaneng',
    'Mafeteng',
    'Leribe',
    'Berea',
    'Mokhotlong',
    'Thaba-Tseka',
    'Quthing',
    'Qacha\'s Nek',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final appLocalizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isPickupLocation 
            ? appLocalizations.translate('location.select_pickup') ?? 'Select Pickup Location'
            : appLocalizations.translate('location.select_delivery') ?? 'Select Delivery Location',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.colorScheme.onBackground,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon
            _buildHeader(context, appLocalizations, theme),
            
            SizedBox(height: 24),
            
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Location Section
                    _buildCurrentLocationCard(context, locationProvider, appLocalizations, theme),
                    
                    SizedBox(height: 24),
                    
                    // Divider with "OR"
                    _buildDividerWithText(
                      context,
                      appLocalizations.translate('location.or_enter_manually') ?? 'Or enter location manually',
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Manual Location Input Form
                    _buildLocationForm(context, appLocalizations, theme),
                  ],
                ),
              ),
            ),
            
            // Submit Button
            _buildSubmitButton(context, appLocalizations, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations? appLocalizations, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            widget.isPickupLocation ? Icons.store : Icons.local_shipping,
            color: theme.colorScheme.primary,
            size: 28,
          ),
        ),
        SizedBox(height: 12),
        Text(
          widget.isPickupLocation 
            ? appLocalizations?.translate('location.select_pickup') ?? 'Select Pickup Location'
            : appLocalizations?.translate('location.select_delivery') ?? 'Select Delivery Location',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
          ),
        ),
        SizedBox(height: 8),
        Text(
          widget.isPickupLocation
            ? 'Choose where customers can pick up their orders'
            : 'Enter your delivery address and contact information',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentLocationCard(BuildContext context, LocationProvider locationProvider, AppLocalizations? appLocalizations, ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.05),
            theme.colorScheme.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.my_location,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appLocalizations?.translate('location.use_current') ?? 'Use Current Location',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        locationProvider.currentAddress ?? 
                        appLocalizations?.translate('location.location_not_available') ?? 'Location not available',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                _isLoading 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.refresh,
                          color: theme.colorScheme.primary,
                        ),
                        onPressed: _getCurrentLocation,
                        tooltip: 'Refresh location',
                      ),
              ],
            ),
            if (locationProvider.currentAddress != null) ...[
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () => _useCurrentLocation(locationProvider),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    foregroundColor: theme.colorScheme.primary,
                  ),
                  child: Text(
                    appLocalizations?.translate('location.select_current') ?? 'Select Current Location',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDividerWithText(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationForm(BuildContext context, AppLocalizations? appLocalizations, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Area Selection
        _buildFormFieldLabel('Select Area *'),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedArea,
              isExpanded: true,
              icon: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(Icons.arrow_drop_down, color: theme.colorScheme.onSurface),
              ),
              hint: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  'Choose your area',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
              items: _maseruAreas.map((area) {
                return DropdownMenuItem(
                  value: area,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      area,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedArea = value;
                });
              },
            ),
          ),
        ),

        SizedBox(height: 20),

        // Address Details
        _buildFormFieldLabel('Street Address *'),
        SizedBox(height: 8),
        TextFormField(
          controller: _addressController,
          decoration: InputDecoration(
            hintText: appLocalizations?.translate('location.street_hint') ?? 'e.g., House No, Street Name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          maxLines: 2,
          style: theme.textTheme.bodyMedium,
        ),

        SizedBox(height: 20),

        // Landmark
        _buildFormFieldLabel('Landmark (Optional)'),
        SizedBox(height: 8),
        TextFormField(
          controller: _landmarkController,
          decoration: InputDecoration(
            hintText: appLocalizations?.translate('location.landmark_hint') ?? 'e.g., Near Shoprite, Next to Post Office',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: theme.textTheme.bodyMedium,
        ),

        if (!widget.isPickupLocation) ...[
          SizedBox(height: 24),
          _buildContactSection(context, appLocalizations, theme),
        ],

        SizedBox(height: 20),

        // Delivery Instructions
        _buildFormFieldLabel(
          widget.isPickupLocation
              ? 'Pickup Instructions (Optional)'
              : 'Delivery Instructions (Optional)'
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _instructionsController,
          decoration: InputDecoration(
            hintText: widget.isPickupLocation
                ? (appLocalizations?.translate('location.pickup_instructions_hint') ?? 'e.g., Ring bell, Ask for manager')
                : (appLocalizations?.translate('location.delivery_instructions_hint') ?? 'e.g., Leave at gate, Call upon arrival'),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          maxLines: 2,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context, AppLocalizations? appLocalizations, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.contact_phone,
                color: theme.colorScheme.secondary,
                size: 18,
              ),
            ),
            SizedBox(width: 12),
            Text(
              appLocalizations?.translate('location.contact_info') ?? 'Contact Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: appLocalizations?.translate('location.your_name') ?? 'Your Name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: theme.textTheme.bodyMedium,
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: appLocalizations?.translate('location.phone_number') ?? 'Phone Number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          keyboardType: TextInputType.phone,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildFormFieldLabel(String text) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, AppLocalizations? appLocalizations, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _validateAndSubmit,
        style: FilledButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        child: Text(
          appLocalizations?.translate('location.confirm_location') ?? 'Confirm Location',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      await locationProvider.getCurrentLocation();
      
      // Auto-fill the address field with current location
      if (locationProvider.currentAddress != null) {
        _addressController.text = locationProvider.currentAddress!;
        
        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Location updated successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Error getting location: $e'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _useCurrentLocation(LocationProvider locationProvider) {
    if (locationProvider.currentAddress != null) {
      final address = locationProvider.currentAddress!;
      
      // FIXED: Pass all required parameters including name and phone
      widget.onLocationSelected(
        address,
        'Current Location',
        '',
        _phoneController.text.isNotEmpty ? _phoneController.text : '+266',
        locationProvider.currentLatitude ?? -29.3100,
        locationProvider.currentLongitude ?? 27.4800,
      );
      
      Navigator.pop(context);
    }
  }

  void _validateAndSubmit() {
    if (_selectedArea == null) {
      _showErrorSnackBar('Please select an area');
      return;
    }

    if (_addressController.text.isEmpty) {
      _showErrorSnackBar('Please enter your address');
      return;
    }

    if (!widget.isPickupLocation && (_nameController.text.isEmpty || _phoneController.text.isEmpty)) {
      _showErrorSnackBar('Please enter your name and phone number for delivery');
      return;
    }

    // Construct full address
    String fullAddress = '$_selectedArea, ${_addressController.text}';
    if (_landmarkController.text.isNotEmpty) {
      fullAddress += ' (Near ${_landmarkController.text})';
    }

    // Get coordinates for the selected area
    final coordinates = _getCoordinatesForArea(_selectedArea!);

    // FIXED: Ensure all required parameters are passed
    widget.onLocationSelected(
      fullAddress,
      _landmarkController.text,
      _instructionsController.text,
      _phoneController.text.isNotEmpty ? _phoneController.text : '+266',
      coordinates['latitude']!,
      coordinates['longitude']!,
    );

    Navigator.pop(context);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Map<String, double> _getCoordinatesForArea(String area) {
    final Map<String, Map<String, double>> areaCoordinates = {
      'Maseru Central': {'latitude': -29.3100, 'longitude': 27.4800},
      'Thetsane': {'latitude': -29.3500, 'longitude': 27.5200},
      'Mazenod': {'latitude': -29.4000, 'longitude': 27.5100},
      'Ha Thetsane': {'latitude': -29.3600, 'longitude': 27.5300},
      'Ha Hlalefane': {'latitude': -29.3300, 'longitude': 27.4900},
      'Ha Foso': {'latitude': -29.3200, 'longitude': 27.4700},
      'Ha Leqele': {'latitude': -29.3800, 'longitude': 27.5000},
      'Roma': {'latitude': -29.4500, 'longitude': 27.7100},
      'Morija': {'latitude': -29.6200, 'longitude': 27.4800},
      'Teyateyaneng': {'latitude': -29.1500, 'longitude': 27.7500},
      'Mafeteng': {'latitude': -29.8200, 'longitude': 27.2500},
      'Leribe': {'latitude': -28.8700, 'longitude': 28.0500},
      'Berea': {'latitude': -29.2000, 'longitude': 27.4500},
      'Mokhotlong': {'latitude': -29.2900, 'longitude': 29.0700},
      'Thaba-Tseka': {'latitude': -29.5200, 'longitude': 28.6000},
      'Quthing': {'latitude': -30.4000, 'longitude': 27.7000},
      'Qacha\'s Nek': {'latitude': -30.1200, 'longitude': 28.6800},
      'Other': {'latitude': -29.3100, 'longitude': 27.4800},
    };

    return areaCoordinates[area] ?? areaCoordinates['Other']!;
  }

  @override
  void dispose() {
    _addressController.dispose();
    _landmarkController.dispose();
    _instructionsController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}