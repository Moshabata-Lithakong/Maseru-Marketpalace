import 'package:geolocator/geolocator.dart';
import 'package:maseru_marketplace/src/models/simple_location.dart';

class LocationService {
  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  static Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get current position with error handling
  static Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.best,
    Duration timeLimit = const Duration(seconds: 15),
  }) async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: timeLimit,
      );
    } catch (e) {
      print('❌ LocationService: Failed to get current position: $e');
      return null;
    }
  }

  /// Get last known position
  static Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      print('❌ LocationService: Failed to get last known position: $e');
      return null;
    }
  }

  /// Calculate distance between two points
  static double calculateDistance(
    double startLat, 
    double startLng, 
    double endLat, 
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Calculate distance between two SimpleLocation objects
  static double calculateDistanceBetween(
    SimpleLocation start, 
    SimpleLocation end,
  ) {
    return calculateDistance(
      start.latitude, 
      start.longitude, 
      end.latitude, 
      end.longitude,
    );
  }

  /// Check if permission is granted
  static bool isPermissionGranted(LocationPermission permission) {
    return permission == LocationPermission.whileInUse || 
           permission == LocationPermission.always;
  }

  /// Get permission status message
  static String getPermissionStatusMessage(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.denied:
        return 'Location permission denied';
      case LocationPermission.deniedForever:
        return 'Location permission permanently denied. Please enable in app settings.';
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return 'Location permission granted';
      case LocationPermission.unableToDetermine:
        return 'Unable to determine location permission status';
    }
  }
}