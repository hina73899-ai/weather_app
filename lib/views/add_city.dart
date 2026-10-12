import 'dart:async';
import 'package:flutter/material.dart';

import '../data/network/network_api_services.dart';

class AddCityView extends StatefulWidget {
  const AddCityView({super.key});

  @override
  State<AddCityView> createState() => _AddCityViewState();
}

class _AddCityViewState extends State<AddCityView> {
  final TextEditingController _searchController = TextEditingController();
  final NetworkApiServices _apiService = NetworkApiServices();

  Timer? _debounce;
  bool _isLoading = false;
  List<Map<String, dynamic>> _searchResults = [];

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isNotEmpty) {
        _fetchCitySuggestions(query.trim());
      } else {
        setState(() => _searchResults = []);
      }
    });
  }

  Future<void> _fetchCitySuggestions(String query) async {
    setState(() => _isLoading = true);

    try {
      final geoUrl = 'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=5';
      final geoData = await _apiService.getGetApiResponse(geoUrl);

      if (geoData != null && geoData['results'] != null) {
        List<Map<String, dynamic>> tempResults = [];

        for (var city in geoData['results']) {
          final lat = city['latitude'];
          final lon = city['longitude'];
          final cityName = city['name'] ?? '';
          final country = city['country'] ?? '';

          final weatherUrl = 'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true';
          final weatherData = await _apiService.getGetApiResponse(weatherUrl);

          tempResults.add({
            'city': cityName,
            'country': country,
            'weatherCode': weatherData?['current_weather']?['weathercode'] ?? 0,
          });
        }

        setState(() {
          _searchResults = tempResults;
          _isLoading = false;
        });
      } else {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _getWeatherIcon(int code) {
    if (code == 0) return "assets/images/sun.png";
    if (code >= 1 && code <= 3) return "assets/images/mix_cloud.png";
    return "assets/images/rain.png";
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF2C3258)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Add City",
          style: TextStyle(color: Color(0xFF2C3258), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.search, color: Color(0xFF2C3258)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Input TextField
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  hintText: "Enter cities",
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Results List / Loading State
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final item = _searchResults[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context, "${item['city']}, ${item['country']}");
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF3FC),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFF2C3258)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['city'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF2C3258),
                                  ),
                                ),
                                Text(
                                  item['country'],
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Image.asset(
                            _getWeatherIcon(item['weatherCode']),
                            width: 40,
                            height: 40,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.wb_sunny_rounded,
                              color: Colors.amber,
                              size: 36,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}