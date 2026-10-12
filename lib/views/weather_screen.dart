import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:weather_app/constants/padding.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final PageController _pageController = PageController(viewportFraction: 0.85);
  bool isDrawerOpen = false;

  // Local static values (No API used)
  final String chanceOfRain = "60%";
  final String condition = "Partly Cloudy";
  final String temp = "28";
  final String humidity = "10%";
  final String uvIndex = "0.5";
  final String windSpeed = "12 m/s";

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

  final List<CalendarDayData> calendarDays = const [
    CalendarDayData(
      day: "Monday",
      temp: "28°",
      icon: Icons.wb_sunny_rounded,
      iconColor: Color(0xFFFFB020),
    ),
    CalendarDayData(
      day: "Tuesday",
      temp: "27°",
      icon: Icons.wb_cloudy_rounded,
      iconColor: Color(0xFFFFB020),
    ),
    CalendarDayData(
      day: "Wednesday",
      temp: "26°",
      icon: Icons.cloud_rounded,
      iconColor: Color(0xFFB0BEC5),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.drawerGradientStart,
      body: Stack(
        children: [
          AppDrawer(onClose: toggleDrawer, onAddLocationTap: () {  },),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            transform: Matrix4.translationValues(
              isDrawerOpen ? 230 : 0,
              isDrawerOpen ? 50 : 0,
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
                  title: const Text(
                    "Berlin, Germany.",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  actions: const [
                    Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(Icons.search_rounded, size: 24, color: AppColors.darkText),
                    ),
                  ],
                ),
                body: SafeArea(
                  child: CustomScrollView(
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
                ),
              ),
            ),
          ),
        ],
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
        padEnds: false,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: _WeatherCard(
              chanceOfRain: chanceOfRain,
              condition: condition,
              temp: temp,
              humidity: humidity,
              uvIndex: uvIndex,
              windSpeed: windSpeed,
            ),
          );
        },
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
                  padding: AppPaddings.newsContent,
                  color: AppColors.darkText,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.cloud_rounded, color: Colors.white, size: 26),
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
                                  text: temp,
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const TextSpan(
                                  text: " °C",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: const [
                              Icon(Icons.location_on_rounded, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                "Berlin, Germany",
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
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
                        "Here's what to expect from today's weather forecast",
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
                            "Just now",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
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
            for (final day in calendarDays) ...[
              _buildCalendarRow(day),
            ],
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
                      colors: [
                        Color(0xFF3C6FD1),
                        Color(0xFF7CA9FF),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    );
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

  Widget _buildCalendarRow(CalendarDayData day) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day.day,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.darkText,
            ),
          ),
          Row(
            children: [
              Text(
                day.temp,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(width: 10),
              Icon(day.icon, color: day.iconColor, size: 22),
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
// WEATHER CARD WIDGET
// ============================================================
class _WeatherCard extends StatelessWidget {
  final String chanceOfRain;
  final String condition;
  final String temp;
  final String humidity;
  final String uvIndex;
  final String windSpeed;

  const _WeatherCard({
    required this.chanceOfRain,
    required this.condition,
    required this.temp,
    required this.humidity,
    required this.uvIndex,
    required this.windSpeed,
  });

  @override
  Widget build(BuildContext context) {
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
                child: Stack(
                  children: const [
                    Positioned(
                      top: 8,
                      right: 45,
                      child: Icon(
                        Icons.wb_sunny_rounded,
                        size: 32,
                        color: Colors.amber,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Icon(
                        Icons.cloud_rounded,
                        size: 46,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.location_on_rounded, color: Colors.white, size: 15),
                  SizedBox(width: 4),
                  Text(
                    "Berlin, Germany",
                    style: TextStyle(color: Colors.white, fontSize: 13),
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
                          text: temp,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const TextSpan(
                          text: " °C",
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

// ============================================================
// CALENDAR DAY DATA MODEL CLASS
// ============================================================
class CalendarDayData {
  final String day;
  final String temp;
  final IconData icon;
  final Color iconColor;

  const CalendarDayData({
    required this.day,
    required this.temp,
    required this.icon,
    required this.iconColor,
  });
}