// lib/services/location_service.dart
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// 1. Check permissions and fetch current Position (Lat / Long)
  static Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled on device
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null; // Location disabled
    }

    // Check permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null; // Permission denied by user
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null; // Permission permanently denied
    }

    // Get current latitude and longitude
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// 2. Fetch live GPS coordinates and return formatted "City, Country"
  static Future<String> getCurrentLocationName() async {
    try {
      Position? position = await getCurrentPosition();

      if (position == null) {
        return "Location unavailable";
      }

      // Convert coordinates (latitude, longitude) to address placemarks
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String city = place.locality ?? place.subAdministrativeArea ?? "Unknown City";
        String country = place.country ?? "Unknown Country";

        return "$city, $country";
      }
    } catch (e) {
      return "Location error";
    }

    return "Location not found";
  }
}