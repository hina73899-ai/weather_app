// lib/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/constants/padding.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'location_picker_sheet.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback onClose;
  final String currentCity;
  final Function(String)? onLocationSelected;
  final VoidCallback? onLiveLocationTap;
  final VoidCallback onAddLocationTap; // 1. Correct variable declaration

  const AppDrawer({
    super.key,
    required this.onClose,
    this.currentCity = "Washington DC, USA",
    this.onLocationSelected,
    this.onLiveLocationTap,
    required this.onAddLocationTap, // 2. Updated parameter
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.drawerGradientStart,
            AppColors.drawerGradientEnd,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, bottom: 20, right: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppPaddings.spaceS,
              Text(
                'Current location',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  showLocationPicker(
                    context,
                    onLocationSelected: (selectedCity) {
                      if (onLocationSelected != null) {
                        onLocationSelected!(selectedCity);
                      }
                      context.read<WeatherViewModel>().updateCity(selectedCity);
                    },
                    onLiveLocationTap: onLiveLocationTap,
                  );
                },
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        currentCity,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),

              // 3. UPDATED: Connected to onAddLocationTap
              InkWell(
                onTap: () {
                  onClose(); // Drawer close karne ke liye
                  onAddLocationTap(); // AddCity view open karne ke liye
                },
                child: const Row(
                  children: [
                    Icon(Icons.add_location_alt_rounded, color: Colors.amber, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Add location',
                      style: TextStyle(
                        color: Colors.amber, // Highlighted text color
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Spacer(),
              _buildTextItem('Settings'),
              _buildTextItem('Share this app'),
              _buildTextItem('Rate this app'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextItem(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: InkWell(
        onTap: () {},
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}