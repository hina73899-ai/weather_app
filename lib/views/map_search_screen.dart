// lib/views/map_search_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class MapSearchScreen extends StatefulWidget {
  const MapSearchScreen({super.key});

  @override
  State<MapSearchScreen> createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends State<MapSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;

  // Initial Location: New York (as shown in design)
  LatLng _selectedLocation = const LatLng(40.7128, -74.0060);
  String _selectedCity = "Park Slope";
  String _selectedAddress = "New York, USA";
  bool _isGeocoding = false;

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _updateMarker(_selectedLocation);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // Update marker position on Map
  void _updateMarker(LatLng position) {
    setState(() {
      _selectedLocation = position;
      _markers = {
        Marker(
          markerId: const MarkerId("selected_target"),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      };
    });
  }

  // Reverse Geocoding: Converts LatLng coordinates to City & Country Name
  Future<void> _getAddressFromLatLng(LatLng position) async {
    setState(() => _isGeocoding = true);
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _selectedCity = place.locality ?? place.subLocality ?? "Selected Location";
          _selectedAddress = "${place.administrativeArea ?? ''}, ${place.country ?? ''}".trim();
        });
      }
    } catch (e) {
      debugPrint("Geocoding Error: $e");
    } finally {
      setState(() => _isGeocoding = false);
    }
  }

  // Search location from Text Input
  Future<void> _searchAndMoveToCity(String cityName) async {
    if (cityName.trim().isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(cityName);
      if (locations.isNotEmpty) {
        LatLng newTarget = LatLng(locations.first.latitude, locations.first.longitude);

        _updateMarker(newTarget);
        _getAddressFromLatLng(newTarget);

        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(newTarget, 13.0),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location not found. Try another city.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Search",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Search Input Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Enter cities",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400),
                filled: true,
                fillColor: const Color(0xFFF5F6F9),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: _searchAndMoveToCity,
            ),
          ),

          // Google Map Section
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedLocation,
                zoom: 12.0,
              ),
              markers: _markers,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              onMapCreated: (controller) => _mapController = controller,
              onTap: (LatLng tappedPoint) {
                _updateMarker(tappedPoint);
                _getAddressFromLatLng(tappedPoint);
              },
            ),
          ),

          // Bottom Detail Card & Selection Button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFF3C6FD1), size: 28),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isGeocoding ? "Fetching location..." : _selectedCity,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  _selectedAddress,
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: const [
                        Icon(Icons.wb_cloudy_rounded, color: Colors.orange, size: 28),
                        SizedBox(width: 8),
                        Text("72°", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Longitude and latitude", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        const SizedBox(height: 4),
                        Text(
                          "${_selectedLocation.latitude.toStringAsFixed(6)}, ${_selectedLocation.longitude.toStringAsFixed(6)}",
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3C6FD1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: () {
                        // Return selected city name back to HomeScreen
                        Navigator.pop(context, _selectedCity);
                      },
                      child: const Text("Select City", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}