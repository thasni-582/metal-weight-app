import 'package:flutter/material.dart';
import 'package:metal_weight/core/localization/app_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSyncPayload {
  final String material;
  final String shape;
  final String size;
  final String thickness;
  final String variant;
  final double lengthInM;
  final int quantity;
  final double weightPerM;
  final double sectionArea;

  const ProfileSyncPayload({
    required this.material,
    required this.shape,
    required this.size,
    required this.thickness,
    required this.variant,
    required this.lengthInM,
    required this.quantity,
    required this.weightPerM,
    required this.sectionArea,
  });
}

class AppSettingsProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  static const String _langKey = 'app_language_code';

  bool _isDarkMode = false;
  String _languageCode = 'en'; // 'en' or 'ar'

  ProfileSyncPayload? _syncedProfileFromHome;
  int _syncVersion = 0;

  ProfileSyncPayload? get syncedProfileFromHome => _syncedProfileFromHome;
  int get syncVersion => _syncVersion;

  void syncProfileFromHome({
    required String material,
    required String shape,
    required String size,
    required String thickness,
    required String variant,
    required double lengthInM,
    required int quantity,
    required double weightPerM,
    required double sectionArea,
  }) {
    _syncedProfileFromHome = ProfileSyncPayload(
      material: material,
      shape: shape,
      size: size,
      thickness: thickness,
      variant: variant,
      lengthInM: lengthInM,
      quantity: quantity,
      weightPerM: weightPerM,
      sectionArea: sectionArea,
    );
    _syncVersion++;
    notifyListeners();
  }

  bool get isDarkMode => _isDarkMode;
  String get languageCode => _languageCode;
  Locale get locale => Locale(_languageCode);
  bool get isArabic => _languageCode == 'ar';
  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  AppStrings get strings => AppStrings(_languageCode);

  AppSettingsProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_themeKey) ?? false;
      _languageCode = prefs.getString(_langKey) ?? 'en';
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggleDarkMode(bool val) async {
    _isDarkMode = val;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, val);
    } catch (_) {}
  }

  Future<void> setLanguage(String code) async {
    if (_languageCode == code) return;
    _languageCode = code;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_langKey, code);
    } catch (_) {}
  }
}
