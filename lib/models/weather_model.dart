import 'package:flutter/material.dart';

class WeatherCardData {
  final String chanceOfRain;
  final String condition;
  final String location;
  final String temp;
  final String humidity;
  final String uvIndex;
  final String windSpeed;
  final IconData icon;

  const WeatherCardData({
    required this.chanceOfRain,
    required this.condition,
    required this.location,
    required this.temp,
    required this.humidity,
    required this.uvIndex,
    required this.windSpeed,
    required this.icon,
  });
}

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