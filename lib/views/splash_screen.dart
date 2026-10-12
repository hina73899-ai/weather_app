import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/views/home_screen.dart';
import 'package:weather_app/views/no_internet_screen.dart';
import '../services/location_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String statusMessage = "Initializing...";

  @override
  void initState() {
    super.initState();
    // Guarantee for Splash Render before code execution
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _executeAppFlow();
    });
  }

  void _updateStatus(String message) {
    if (mounted) {
      setState(() => statusMessage = message);
    }
  }

  Future<void> _executeAppFlow() async {
    // STEP 1: Mandatory 2.5 seconds Splash view delay
    _updateStatus("Starting app...");
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    // STEP 2: Network check
    _updateStatus("Checking internet...");
    bool hasInternet = await LocationFlow.checkInternetConnection();
    if (!mounted) return;

    if (!hasInternet) {
      // Direct jump to NoInternetScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NoInternetScreen()),
      );
      return;
    }

    // STEP 3: Internet exists -> Proceed with GPS logic
    _updateStatus("Detecting location...");
    await LocationFlow.resolveAndGoHome(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2AAEFE), Color(0xFF508AE7)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(36),
                ),
                child: Center(
                  child: SvgPicture.asset("assets/icons/w.svg", height: 44, width: 44),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                "Wurly",
                style: TextStyle(
                  fontSize: 54,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: "Poppins",
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "We track weather",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white70,
                  fontFamily: "Poppins",
                ),
              ),
              const Spacer(),
              const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              const SizedBox(height: 16),
              Text(
                statusMessage,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: "Poppins"),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

// Global Navigation Flow Helper
class LocationFlow {
  static Future<bool> checkInternetConnection() async {
    const hosts = ['google.com', 'cloudflare.com', 'one.one.one.one'];
    for (final host in hosts) {
      try {
        final result = await InternetAddress.lookup(host)
            .timeout(const Duration(seconds: 3));
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          return true;
        }
      } catch (_) {
        continue;
      }
    }
    return false;
  }

  static Future<void> resolveAndGoHome(BuildContext context) async {
    // 1. GPS Check
    bool isGpsEnabled = await Geolocator.isLocationServiceEnabled();
    if (!context.mounted) return;

    if (!isGpsEnabled) {
      _showGpsDisabledDialog(context);
      return;
    }

    // 2. Permission Check
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (!context.mounted) return;
      if (permission == LocationPermission.denied) {
        _showPermissionDeniedDialog(context);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!context.mounted) return;
      _showSettingsDialog(context);
      return;
    }

    // 3. Location Fetch & Navigating DIRECT TO HOME
    try {
      String locationName = await LocationService.getCurrentLocationName()
          .timeout(const Duration(seconds: 10));

      if (!context.mounted) return;

      if (!locationName.toLowerCase().contains("error") &&
          !locationName.toLowerCase().contains("unavailable")) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(initialCity: locationName),
          ),
              (route) => false,
        );
      } else {
        _showRetrySnackbar(context, "Location fetch failed. Dobara try karein.");
      }
    } catch (_) {
      if (context.mounted) {
        _showRetrySnackbar(context, "Location request timed out.");
      }
    }
  }

  static void _showRetrySnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  static void _showGpsDisabledDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("GPS Disabled"),
        content: const Text("Device GPS turn on karein taakay live weather track ho sake."),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF508AE7)),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await Geolocator.openLocationSettings();
              if (context.mounted) resolveAndGoHome(context);
            },
            child: const Text("Turn On GPS", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  static void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Location Permission Needed"),
        content: const Text("Live weather track karne ke liye location permission zaroori hai."),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF508AE7)),
            onPressed: () {
              Navigator.pop(dialogContext);
              if (context.mounted) resolveAndGoHome(context);
            },
            child: const Text("Try Again", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  static void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Permission Denied"),
        content: const Text("Location permission permanently off hai. App Settings se enable karein."),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF508AE7)),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await Geolocator.openAppSettings();
              if (context.mounted) resolveAndGoHome(context);
            },
            child: const Text("Open Settings", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}