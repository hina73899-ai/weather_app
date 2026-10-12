import 'package:flutter/material.dart';

class WeatherViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String _currentCity = "Washington DC, USA";

  bool get isLoading => _isLoading;
  String get currentCity => _currentCity;

  void updateCity(String newCity) {
    _currentCity = newCity;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}