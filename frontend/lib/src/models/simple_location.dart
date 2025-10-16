import 'dart:math';

class SimpleLocation {
  final double latitude;
  final double longitude;
  final String? address;
  final String? placeName;
  final DateTime? timestamp;

  const SimpleLocation({
    required this.latitude,
    required this.longitude,
    this.address,
    this.placeName,
    this.timestamp,
  });

  /// Create with default Maseru location
  factory SimpleLocation.maseruDefault() {
    return const SimpleLocation(
      latitude: -29.3100,
      longitude: 27.4800,
      address: 'Maseru, Lesotho',
      placeName: 'Maseru City Center',
    );
  }

  /// Check if location coordinates are valid
  bool get isValid {
    return latitude >= -90 && 
           latitude <= 90 && 
           longitude >= -180 && 
           longitude <= 180;
  }

  /// Check if location has address information
  bool get hasAddress => address != null && address!.isNotEmpty;

  /// Get display address (prefers placeName > address > coordinates)
  String get displayAddress {
    if (placeName != null && placeName!.isNotEmpty) return placeName!;
    if (address != null && address!.isNotEmpty) return address!;
    return coordinatesString;
  }

  /// Get formatted coordinates string
  String get coordinatesString {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  /// Get short coordinates for display
  String get shortCoordinates {
    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }

  /// Calculate distance to another location in meters
  double distanceTo(SimpleLocation other) {
    const double earthRadius = 6371000; // meters
    
    final double dLat = _toRadians(other.latitude - latitude);
    final double dLng = _toRadians(other.longitude - longitude);
    
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(latitude)) *
            cos(_toRadians(other.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  /// Calculate distance in kilometers
  double distanceToInKm(SimpleLocation other) {
    return distanceTo(other) / 1000;
  }

  /// Check if this location is near another location (within tolerance)
  bool isNear(SimpleLocation other, {double toleranceMeters = 100}) {
    return distanceTo(other) <= toleranceMeters;
  }

  /// Convert degrees to radians
  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// Create a copy with updated fields
  SimpleLocation copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? placeName,
    DateTime? timestamp,
  }) {
    return SimpleLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      placeName: placeName ?? this.placeName,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'placeName': placeName,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory SimpleLocation.fromJson(Map<String, dynamic> json) {
    return SimpleLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'],
      placeName: json['placeName'],
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
    );
  }

  @override
  String toString() {
    return 'SimpleLocation(lat: $latitude, lng: $longitude, address: $address, placeName: $placeName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SimpleLocation &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}