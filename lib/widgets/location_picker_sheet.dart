import 'package:flutter/material.dart';
import '../services/location_service.dart';

void showLocationPicker(
    BuildContext context, {
      Function(String)? onLocationSelected,
      VoidCallback? onLiveLocationTap,
    }) {
  showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => LocationPickerSheet(onLiveLocationTap: onLiveLocationTap),
  ).then((selectedCity) {
    if (selectedCity != null && selectedCity.isNotEmpty && onLocationSelected != null) {
      onLocationSelected(selectedCity);
    }
  });
}

class LocationPickerSheet extends StatefulWidget {
  final VoidCallback? onLiveLocationTap;

  const LocationPickerSheet({super.key, this.onLiveLocationTap});

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isSearching = false;
  bool _isFetchingLiveLocation = false;
  String? _errorText;

  void _handleSearch() async {
    final cityName = _controller.text.trim();

    if (cityName.isEmpty) {
      setState(() {
        _errorText = "Please type a location name";
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorText = null;
    });

    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;

    Navigator.pop(context, cityName);
  }

  void _handleLiveLocation() async {
    if (widget.onLiveLocationTap != null) {
      Navigator.pop(context);
      widget.onLiveLocationTap!();
      return;
    }

    setState(() {
      _isFetchingLiveLocation = true;
      _errorText = null;
    });

    String liveCityName = await LocationService.getCurrentLocationName();

    if (!mounted) return;

    setState(() {
      _isFetchingLiveLocation = false;
    });

    if (liveCityName.contains("unavailable") ||
        liveCityName.contains("denied") ||
        liveCityName.contains("error")) {
      setState(() {
        _errorText = liveCityName;
      });
    } else {
      Navigator.pop(context, liveCityName);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Search location",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          InkWell(
            onTap: (_isFetchingLiveLocation || _isSearching) ? null : _handleLiveLocation,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  if (_isFetchingLiveLocation)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                    )
                  else
                    const Icon(Icons.my_location_rounded, color: Colors.blue, size: 22),
                  const SizedBox(width: 12),
                  const Text(
                    "Use Current Live Location",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _controller,
            autofocus: false,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _handleSearch(),
            decoration: InputDecoration(
              hintText: "Type city or country name...",
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFFF2F4F7),
            ),
          ),

          if (_errorText != null) ...[
            const SizedBox(height: 10),
            Text(_errorText!, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ],

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_isSearching || _isFetchingLiveLocation) ? null : _handleSearch,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isSearching
                  ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Text("Search"),
            ),
          ),
        ],
      ),
    );
  }
}