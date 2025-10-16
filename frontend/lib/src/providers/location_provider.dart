import 'dart:math';
import 'package:flutter/foundation.dart';

class LocationProvider with ChangeNotifier {
  double? _currentLatitude;
  double? _currentLongitude;
  String? _error;
  bool _isLoading = false;
  bool _permissionGranted = false;
  bool _serviceEnabled = false;
  String? _currentAddress;
  String? _selectedArea;
  String? _manualAddress;

  double? get currentLatitude => _currentLatitude;
  double? get currentLongitude => _currentLongitude;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get permissionGranted => _permissionGranted;
  bool get serviceEnabled => _serviceEnabled;
  bool get hasLocation => _currentLatitude != null && _currentLongitude != null;
  String? get currentAddress => _currentAddress;
  String? get selectedArea => _selectedArea;
  String? get manualAddress => _manualAddress;

  // Common areas in Maseru with coordinates
  final Map<String, Map<String, double>> _maseruAreas = {
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

  List<String> get availableAreas => _maseruAreas.keys.toList();

  Future<bool> checkLocationServices() async {
    try {
      // Simulate location service check
      _serviceEnabled = true; // Assume enabled for web
      notifyListeners();
      return _serviceEnabled;
    } catch (e) {
      _error = 'Location service check failed: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkPermission() async {
    try {
      _serviceEnabled = true; // Assume enabled for web
      if (!_serviceEnabled) {
        _error = 'Location services are disabled. Please enable them.';
        notifyListeners();
        return false;
      }

      // Simulate permission check for web
      _permissionGranted = true; // Assume granted for web
      
      if (!_permissionGranted) {
        _error = 'Location permission is required to use this feature.';
      }
      
      notifyListeners();
      return _permissionGranted;
    } catch (e) {
      _error = 'Permission check failed: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!await checkLocationServices()) {
        _error = 'Please enable location services and try again.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (!await checkPermission()) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Use default Maseru coordinates for web
      _currentLatitude = -29.3100;
      _currentLongitude = 27.4800;
      
      // Set current address based on coordinates
      _currentAddress = _getAddressFromCoordinates(
        _currentLatitude!, 
        _currentLongitude!
      );
      
      // Auto-detect area based on coordinates
      _selectedArea = _detectAreaFromCoordinates(
        _currentLatitude!, 
        _currentLongitude!
      );
      
      print('📍 Current location: $_currentLatitude, $_currentLongitude');
      print('📍 Address: $_currentAddress');
      print('📍 Area: $_selectedArea');
    } catch (e) {
      _error = 'Failed to get location: $e';
      print('❌ Location error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set manual location with area selection
  void setManualLocation({
    required String area,
    required String address,
    String? landmark,
    String? instructions,
  }) {
    if (_maseruAreas.containsKey(area)) {
      final coordinates = _maseruAreas[area]!;
      
      _currentLatitude = coordinates['latitude'];
      _currentLongitude = coordinates['longitude'];
      
      _selectedArea = area;
      _manualAddress = address;
      _currentAddress = _buildFullAddress(area, address, landmark);
      _error = null;
      
      print('📍 Manual location set: $area - $address');
      print('📍 Coordinates: ${coordinates['latitude']}, ${coordinates['longitude']}');
      
      notifyListeners();
    }
  }

  // Set area only (for quick selection)
  void setArea(String area) {
    if (_maseruAreas.containsKey(area)) {
      final coordinates = _maseruAreas[area]!;
      
      _currentLatitude = coordinates['latitude'];
      _currentLongitude = coordinates['longitude'];
      
      _selectedArea = area;
      _currentAddress = area;
      _error = null;
      
      notifyListeners();
    }
  }

  String _getAddressFromCoordinates(double latitude, double longitude) {
    // Simple coordinate-based address
    return 'Lat: ${latitude.toStringAsFixed(4)}, Long: ${longitude.toStringAsFixed(4)}';
  }

  String? _detectAreaFromCoordinates(double latitude, double longitude) {
    // Simple area detection based on coordinate ranges
    for (var area in _maseruAreas.keys) {
      final coords = _maseruAreas[area]!;
      final distance = calculateDistance(
        latitude, longitude, 
        coords['latitude']!, coords['longitude']!
      );
      
      // If within 10km of area center, consider it that area
      if (distance < 10000) { // 10km in meters
        return area;
      }
    }
    return 'Maseru Central'; // Default
  }

  String _buildFullAddress(String area, String address, String? landmark) {
    String fullAddress = '$area, $address';
    if (landmark != null && landmark.isNotEmpty) {
      fullAddress += ' (Near $landmark)';
    }
    return fullAddress;
  }

  Map<String, double>? getAreaCoordinates(String area) {
    return _maseruAreas[area];
  }

  Future<Map<String, double>?> getLocationOnce() async {
    if (_currentLatitude != null && _currentLongitude != null) {
      return {'latitude': _currentLatitude!, 'longitude': _currentLongitude!};
    }

    await getCurrentLocation();
    if (_currentLatitude != null && _currentLongitude != null) {
      return {'latitude': _currentLatitude!, 'longitude': _currentLongitude!};
    }
    return null;
  }

  Future<Map<String, double>?> getLastKnownPosition() async {
    try {
      // Return current position if available
      if (_currentLatitude != null && _currentLongitude != null) {
        return {'latitude': _currentLatitude!, 'longitude': _currentLongitude!};
      }
      return null;
    } catch (e) {
      print('❌ Last known position error: $e');
      return null;
    }
  }

  double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    // Haversine formula to calculate distance between two coordinates
    const double earthRadius = 6371000; // meters
    
    double dLat = _toRadians(endLat - startLat);
    double dLng = _toRadians(endLng - startLng);
    
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(startLat)) * cos(_toRadians(endLat)) *
        sin(dLng / 2) * sin(dLng / 2);
    
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  // Calculate delivery distance and estimate time
  Map<String, dynamic> calculateDeliveryInfo(
    double startLat, 
    double startLng, 
    double endLat, 
    double endLng
  ) {
    final distance = calculateDistance(startLat, startLng, endLat, endLng);
    final distanceKm = distance / 1000;
    
    // Estimate delivery time (assuming average speed of 30km/h in urban areas)
    final estimatedMinutes = (distanceKm / 30 * 60).ceil();
    
    return {
      'distance': distanceKm,
      'distanceMeters': distance,
      'estimatedMinutes': estimatedMinutes,
      'deliveryFee': _calculateDeliveryFee(distanceKm),
    };
  }

  double _calculateDeliveryFee(double distanceKm) {
    // Base fee for first 5km
    double baseFee = 15.0;
    
    // Additional fee for longer distances
    if (distanceKm > 5) {
      baseFee += (distanceKm - 5) * 2.0; // LSL 2 per additional km
    }
    
    // Maximum fee cap
    return baseFee.clamp(15.0, 50.0);
  }

  // Check if location is within delivery range
  bool isWithinDeliveryRange(double vendorLat, double vendorLon, {double maxDistance = 50.0}) {
    if (_currentLatitude == null || _currentLongitude == null) return false;
    
    final distance = calculateDistance(
      _currentLatitude!, 
      _currentLongitude!, 
      vendorLat, 
      vendorLon
    ) / 1000; // Convert to km
    
    return distance <= maxDistance;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _currentLatitude = null;
    _currentLongitude = null;
    _currentAddress = null;
    _selectedArea = null;
    _manualAddress = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // Get display text for current location
  String get displayLocation {
    if (_currentAddress != null) {
      return _currentAddress!;
    }
    if (_selectedArea != null) {
      return _selectedArea!;
    }
    return 'Location not set';
  }

  // Check if we have sufficient location info
  bool get hasSufficientLocation {
    return _currentLatitude != null && 
           _currentLongitude != null && 
           _selectedArea != null && 
           _currentAddress != null;
  }
}