// lib/services/geo_search_service.dart
import 'package:geocoding/geocoding.dart';

class GeoSearchService {
  /// City name input lene par City, Country return karta hai
  static Future<String?> getCountryFromCity(String query) async {
    try {
      if (query.trim().isEmpty) return null;

      List<Location> locations = await locationFromAddress(query);

      if (locations.isNotEmpty) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          locations.first.latitude,
          locations.first.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;

          String city = place.locality ?? place.subAdministrativeArea ?? query;
          String country = place.country ?? "";

          if (country.isNotEmpty) {
            return "$city, $country";
          }
          return city;
        }
      }
    } catch (e) {
      // Direct Query Return if geocoding fails or offline
      return query;
    }
    return query;
  }
}