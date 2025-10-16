import 'dart:convert';

class User {
  final String id;
  final String email;
  final String role;
  final UserProfile profile;
  final VendorInfo? vendorInfo;
  final TaxiDriverInfo? taxiDriverInfo;
  final UserPreferences preferences;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.profile,
    this.vendorInfo,
    this.taxiDriverInfo,
    required this.preferences,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'passenger',
      profile: UserProfile.fromJson(json['profile'] ?? {}),
      vendorInfo: json['vendorInfo'] != null ? VendorInfo.fromJson(json['vendorInfo']) : null,
      taxiDriverInfo: json['taxiDriverInfo'] != null ? TaxiDriverInfo.fromJson(json['taxiDriverInfo']) : null,
      preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'role': role,
      'profile': profile.toJson(),
      'vendorInfo': vendorInfo?.toJson(),
      'taxiDriverInfo': taxiDriverInfo?.toJson(),
      'preferences': preferences.toJson(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get fullName => '${profile.firstName} ${profile.lastName}';
  bool get isVendor => role == 'vendor';
  bool get isTaxiDriver => role == 'taxi_driver';
  bool get isAdmin => role == 'admin';
  bool get isPassenger => role == 'passenger';
}

class UserProfile {
  final String firstName;
  final String lastName;
  final String phone;
  final String? avatar;

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.avatar,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final phone = json['phone'] as String? ?? '';
    if (phone.isNotEmpty && !RegExp(r'^\+266\d{8}$').hasMatch(phone)) {
      throw FormatException('Invalid phone number format. Expected +266 followed by 8 digits');
    }

    return UserProfile(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: phone,
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'avatar': avatar,
    };
  }
}

class VendorInfo {
  final String shopName;
  final ShopLocation shopLocation;
  final String? taxNumber;
  final bool verified;

  VendorInfo({
    required this.shopName,
    required this.shopLocation,
    this.taxNumber,
    required this.verified,
  });

  factory VendorInfo.fromJson(Map<String, dynamic> json) {
    return VendorInfo(
      shopName: json['shopName'] ?? '',
      shopLocation: ShopLocation.fromJson(json['shopLocation'] ?? {}),
      taxNumber: json['taxNumber'],
      verified: json['verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shopName': shopName,
      'shopLocation': shopLocation.toJson(),
      'taxNumber': taxNumber,
      'verified': verified,
    };
  }
}

class ShopLocation {
  final String address;
  final LocationCoordinates? coordinates;

  ShopLocation({
    required this.address,
    this.coordinates,
  });

  factory ShopLocation.fromJson(Map<String, dynamic> json) {
    return ShopLocation(
      address: json['address'] ?? '',
      coordinates: json['coordinates'] != null
          ? LocationCoordinates.fromJson(json['coordinates'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'coordinates': coordinates?.toJson(),
    };
  }
}

class TaxiDriverInfo {
  final String licenseNumber;
  final String vehicleType;
  final String vehiclePlate;
  final bool available;
  final DriverLocation? currentLocation;

  TaxiDriverInfo({
    required this.licenseNumber,
    required this.vehicleType,
    required this.vehiclePlate,
    required this.available,
    this.currentLocation,
  });

  factory TaxiDriverInfo.fromJson(Map<String, dynamic> json) {
    return TaxiDriverInfo(
      licenseNumber: json['licenseNumber'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
      vehiclePlate: json['vehiclePlate'] ?? '',
      available: json['available'] ?? false,
      currentLocation: json['currentLocation'] != null
          ? DriverLocation.fromJson(json['currentLocation'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'licenseNumber': licenseNumber,
      'vehicleType': vehicleType,
      'vehiclePlate': vehiclePlate,
      'available': available,
      'currentLocation': currentLocation?.toJson(),
    };
  }
}

class DriverLocation {
  final LocationCoordinates? coordinates;

  DriverLocation({this.coordinates});

  factory DriverLocation.fromJson(Map<String, dynamic> json) {
    return DriverLocation(
      coordinates: json['coordinates'] != null
          ? LocationCoordinates.fromJson(json['coordinates'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coordinates': coordinates?.toJson(),
    };
  }
}

class LocationCoordinates {
  final double latitude;
  final double longitude;

  LocationCoordinates({
    required this.latitude,
    required this.longitude,
  });

  factory LocationCoordinates.fromJson(Map<String, dynamic> json) {
    return LocationCoordinates(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class UserPreferences {
  final String language;
  final String theme;

  UserPreferences({
    required this.language,
    required this.theme,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      language: json['language'] ?? 'en',
      theme: json['theme'] ?? 'light',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'theme': theme,
    };
  }
}