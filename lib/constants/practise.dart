import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/views/home_screen.dart';
import '../services/location_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initAppWithLocation();
  }

  void _initAppWithLocation() async {
    // 1. Wait 2 seconds for splash feel
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // 2. Direct navigate to HomeScreen (No Freeze)
    _navigateToHome();
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _showLocationRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.location_off, color: Color(0xFF508AE7)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "Location Required",
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: const Text(
          "Plz, add your location to access Wurly App, click now, and access it",
          style: TextStyle(fontFamily: "Poppins"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openLocationSettings();
            },
            child: const Text("Settings"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF508AE7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _navigateToHome();
            },
            child: const Text("Skip", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2AAEFE),
              Color(0xFF508AE7),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(36),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    "assets/icons/w.svg",
                    height: 20,
                    width: 20,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                "Wurly",
                style: TextStyle(
                  fontSize: 54,
                  fontWeight: FontWeight.w600,
                  color: Color(0XFFFFFFFF),
                  fontFamily: "Poppins",
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "We track weather",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: Color(0XFFFFFFFF),
                  fontFamily: "Poppins",
                ),
              ),
              if (isLoading) ...[
                const SizedBox(height: 30),
                const CircularProgressIndicator(
                  color: Colors.white,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}