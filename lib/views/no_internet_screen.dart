import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'splash_screen.dart';

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({super.key});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  bool isChecking = false;

  Future<void> _checkAndRetry() async {
    setState(() => isChecking = true);

    bool connected = await LocationFlow.checkInternetConnection();

    if (!mounted) return;

    if (connected) {
      // Internet active hote hi direct Home Flow chalega.
      // Splash screen pe dobara bilkul nahi jayega.
      await LocationFlow.resolveAndGoHome(context);
    } else {
      _showSnackBar("Abhi tak internet connectivity nahi hai.");
      setState(() => isChecking = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Wurly Logo (WiFi Icon ke Top par)
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFF508AE7),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF508AE7).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/icons/w.svg",
                      height: 40,
                      width: 40,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // WiFi Off Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF508AE7).withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.wifi_off_rounded,
                    size: 60,
                    color: Color(0xFF508AE7),
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  "No Internet Connection",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: "Poppins",
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Wurly app live weather aur GPS data fetch karne ke liye active internet connection use karti hai.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontFamily: "Poppins",
                    height: 1.5,
                  ),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF508AE7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: isChecking ? null : _checkAndRetry,
                    icon: isChecking
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : const Icon(Icons.refresh_rounded, color: Colors.white),
                    label: Text(
                      isChecking ? "Checking Network..." : "Try Again",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}