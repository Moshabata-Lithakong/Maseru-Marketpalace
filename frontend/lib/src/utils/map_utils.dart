import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'simple_location.dart';

class MapUtils {
  // Calculate distance between two points in meters
  static double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  // Calculate delivery fee based on distance
  static double calculateDeliveryFee(double distanceInMeters, {bool isUrgent = false}) {
    const double baseFee = 15.0; // LSL
    const double perKmRate = 5.0; // LSL per km
    const double urgentSurcharge = 10.0; // LSL
    
    double distanceInKm = distanceInMeters / 1000;
    double fee = baseFee + (distanceInKm * perKmRate);
    
    if (isUrgent) {
      fee += urgentSurcharge;
    }
    
    // Cap the fee at reasonable amount
    return fee.clamp(15.0, 100.0);
  }

  // Check if location is within service area (Maseru area)
  static bool isWithinServiceArea(LatLng location) {
    // Maseru approximate bounds
    const LatLng maseruCenter = LatLng(-29.3100, 27.4800);
    const double serviceRadius = 15000; // 15km radius
    
    double distance = calculateDistance(location, maseruCenter);
    return distance <= serviceRadius;
  }

  // Get bounds for multiple locations
  static LatLngBounds getBounds(List<LatLng> locations) {
    if (locations.isEmpty) {
      return LatLngBounds(
        southwest: const LatLng(-29.5, 27.3),
        northeast: const LatLng(-29.1, 27.6),
      );
    }

    double minLat = locations.first.latitude;
    double maxLat = locations.first.latitude;
    double minLng = locations.first.longitude;
    double maxLng = locations.first.longitude;

    for (final location in locations) {
      minLat = minLat < location.latitude ? minLat : location.latitude;
      maxLat = maxLat > location.latitude ? maxLat : location.latitude;
      minLng = minLng < location.longitude ? minLng : location.longitude;
      maxLng = maxLng > location.longitude ? maxLng : location.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  // Format distance for display
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
    }
  }

  // Format coordinates for display
  static String formatCoordinates(LatLng location) {
    return '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
  }

  // Get camera position for a location
  static CameraPosition getCameraPosition(LatLng location, {double zoom = 15.0}) {
    return CameraPosition(
      target: location,
      zoom: zoom,
      bearing: 0,
      tilt: 0,
    );
  }
}