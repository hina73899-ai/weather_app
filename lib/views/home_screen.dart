// lib/views/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:weather_app/constants/padding.dart';
import '../services/geo_search_service.dart';
import '../services/location_service.dart';
import '../widgets/app_drawer.dart';
import 'add_city.dart';

class HomeScreen extends StatefulWidget {
  final String? initialCity;
  const HomeScreen({super.key, this.initialCity});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  bool isDrawerOpen = false;
  bool isLoadingLocation = false;

  late String currentCity;

  final String chanceOfRain = "60%";
  final String condition = "Partly Cloudy";
  final String temp = "72°";
  final String humidity = "10%";
  final String uvIndex = "0.5";
  final String windSpeed = "124 mp/h";
  final IconData mainIcon = Icons.wb_cloudy_rounded;

  @override
  void initState() {
    super.initState();
    if (widget.initialCity != null && widget.initialCity!.trim().isNotEmpty) {
      currentCity = widget.initialCity!;
    } else {
      currentCity = "Locating...";
      fetchLiveLocation();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void toggleDrawer() {
    setState(() {
      isDrawerOpen = !isDrawerOpen;
    });
  }

  /// Geocodes city search input to formatted location string
  void updateLocation(String searchInput) async {
    if (searchInput.trim().isEmpty) return;

    setState(() {
      isLoadingLocation = true;
    });

    String? formattedLocation = await GeoSearchService.getCountryFromCity(searchInput);

    setState(() {
      currentCity = formattedLocation ?? searchInput;
      isLoadingLocation = false;
    });
  }

  /// Fetches live GPS location
  void fetchLiveLocation() async {
    setState(() {
      isLoadingLocation = true;
    });

    String liveLocation = await LocationService.getCurrentLocationName();

    setState(() {
      currentCity = liveLocation;
      isLoadingLocation = false;
    });
  }

  void _showSearchDialog() {
    final TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Search Location",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: TextField(
            controller: searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Enter city name (e.g. Lahore, Tokyo)",
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (value) {
              Navigator.pop(context);
              updateLocation(value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                updateLocation(searchController.text);
              },
              child: const Text("Select"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.drawerGradientStart,
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 100 && !isDrawerOpen) {
            toggleDrawer();
          } else if (details.primaryVelocity! < -100 && isDrawerOpen) {
            toggleDrawer();
          }
        },
        child: Stack(
          children: [
            // AppDrawer Integration with onAddLocationTap
            AppDrawer(
              onClose: toggleDrawer,
              currentCity: currentCity,
              onLocationSelected: (selectedCity) {
                updateLocation(selectedCity);
              },
              onLiveLocationTap: fetchLiveLocation,
              onAddLocationTap: () async {
                final selectedCity = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddCityView(),
                  ),
                );

                if (selectedCity != null && selectedCity is String) {
                  updateLocation(selectedCity);
                }
              },
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              transform: Matrix4.translationValues(
                isDrawerOpen ? 270 : 0,
                isDrawerOpen ? 110 : 0,
                0,
              )..scale(isDrawerOpen ? 0.88 : 1.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isDrawerOpen ? 28 : 0),
                child: Scaffold(
                  backgroundColor: AppColors.background,
                    appBar: AppBar(
                      backgroundColor: AppColors.background,
                      elevation: 0,
                      centerTitle: true,
                      leading: IconButton(
                        icon: Icon(
                          isDrawerOpen ? Icons.arrow_back : Icons.menu_rounded,
                          color: AppColors.darkText,
                        ),
                        onPressed: toggleDrawer,
                      ),
                      title: GestureDetector(
                        onTap: () async {
                          final selectedCity = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddCityView(),
                            ),
                          );

                          if (selectedCity != null && selectedCity is String) {
                            updateLocation(selectedCity);
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isLoadingLocation)
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.darkText,
                                ),
                              )
                            else ...[
                              Flexible(
                                child: Text(
                                  currentCity,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkText,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: AppColors.darkText,
                              ),
                            ],
                          ],
                        ),
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: IconButton(
                            icon: const Icon(
                              Icons.search_rounded,
                              size: 24,
                              color: AppColors.darkText,
                            ),
                            onPressed: _showSearchDialog,
                          ),
                        ),
                      ],
                    ),
                  body: SafeArea(
                    child: Stack(
                      children: [
                        CustomScrollView(
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppPaddings.spaceS,
                                  _buildWeatherCardCarousel(),
                                  AppPaddings.spaceL,
                                  _buildSectionTitle("News weather"),
                                  AppPaddings.spaceS,
                                  _buildNewsWeatherCard(),
                                  AppPaddings.spaceL,
                                  _buildSectionTitle("Calendar"),
                                  AppPaddings.spaceS,
                                  _buildCalendarCard(),
                                  AppPaddings.spaceM,
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (isDrawerOpen)
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: toggleDrawer,
                              behavior: HitTestBehavior.opaque,
                              child: Container(color: Colors.transparent),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- WEATHER CARD CAROUSEL ----------------
  Widget _buildWeatherCardCarousel() {
    return SizedBox(
      height: 195,
      child: PageView.builder(
        controller: _pageController,
        itemCount: 1,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildWeatherCard(),
          );
        },
      ),
    );
  }

  // ---------------- WEATHER CARD WIDGET ----------------
  Widget _buildWeatherCard() {
    return Container(
      width: double.infinity,
      padding: AppPaddings.cardContent,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cardGradientStart, AppColors.cardGradientEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Chance of rain $chanceOfRain",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      condition,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 70,
                height: 60,
                child: Center(
                  child: Transform.scale(
                    scale: 1.8,
                    child: Image.asset(
                      "assets/images/mix_cloud.png",
                      height: 90,
                      width: 90,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: Colors.white, size: 15),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      currentCity,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: temp.replaceAll('°', ''),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const TextSpan(
                          text: " °F",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _MiniStat(
                    icon: "assets/icons/wind.svg",
                    label: humidity,
                    light: true,
                  ),
                  const SizedBox(width: 10),
                  _MiniStat(
                    icon: "assets/icons/sun.svg",
                    label: uvIndex,
                    light: true,
                  ),
                  const SizedBox(width: 10),
                  _MiniStat(
                    icon: "assets/icons/air.svg",
                    label: windSpeed,
                    light: true,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- NEWS WEATHER CARD ----------------
  Widget _buildNewsWeatherCard() {
    return Padding(
      padding: AppPaddings.screenHorizontal,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 130,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/cloud_sun.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.25),
                              Colors.black.withOpacity(0.45),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: AppPaddings.newsContent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  mainIcon,
                                  color: Colors.white,
                                  size: 26,
                                ),
                                Row(
                                  children: [
                                    _MiniStat(
                                      icon: "assets/icons/wind.svg",
                                      label: humidity,
                                      light: true,
                                    ),
                                    const SizedBox(width: 14),
                                    _MiniStat(
                                      icon: "assets/icons/sun.svg",
                                      label: uvIndex,
                                      light: true,
                                    ),
                                    const SizedBox(width: 14),
                                    _MiniStat(
                                      icon: "assets/icons/air.svg",
                                      label: windSpeed,
                                      light: true,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: temp.replaceAll('°', ''),
                                        style: const TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: " °F",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.location_on_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          currentCity,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: AppPaddings.newsContent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Here's what to expect from Tuesday weather forecast",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "14 minutes ago",
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                          const Text(
                            "WC Channel",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- CALENDAR CARD ----------------
  Widget _buildCalendarCard() {
    return Padding(
      padding: AppPaddings.screenHorizontal,
      child: Container(
        padding: AppPaddings.calendarPadding,
        decoration: BoxDecoration(
          color: AppColors.calendarBg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            _buildCalendarRow("Monday", "28°", Icons.wb_sunny_rounded, const Color(0xFFFFB020)),
            _buildCalendarRow("Tuesday", "27°", Icons.wb_cloudy_rounded, const Color(0xFFFFB020)),
            _buildCalendarRow("Wednesday", "26°", Icons.cloud_rounded, const Color(0xFFB0BEC5)),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {},
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      colors: [Color(0xFF3C6FD1), Color(0xFF7CA9FF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
                  },
                  child: const Text(
                    "See all",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarRow(String day, String temp, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.darkText,
            ),
          ),
          Row(
            children: [
              Text(
                temp,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(width: 10),
              Icon(icon, color: iconColor, size: 22),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: AppPaddings.screenHorizontal,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.darkText,
        ),
      ),
    );
  }
}

// ============================================================
// MINI STAT WIDGET
// ============================================================
class _MiniStat extends StatelessWidget {
  final String icon;
  final String label;
  final bool light;

  const _MiniStat({
    required this.icon,
    required this.label,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          icon,
          width: 16,
          height: 16,
          colorFilter: ColorFilter.mode(
            light ? Colors.white : Colors.black,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: light ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}