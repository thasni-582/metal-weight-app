import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:metal_weight/models/calculation_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting metal weight calculation history using Hive local database.
/// Provides high-performance binary storage compatible with Android, iOS, and Web.
class HistoryService {
  static const String _boxName = 'calculation_history_box';
  static const String _legacyPrefsKey = 'calculation_history';

  static Box<String>? _box;

  /// Initialize Hive box and migrate legacy prefs if needed.
  static Future<void> init() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        _box = await Hive.openBox<String>(_boxName);
      } else {
        _box = Hive.box<String>(_boxName);
      }
      await _migrateFromLegacyPrefs();
    } catch (_) {
      // In case of any initialization issue, box will be opened on demand
    }
  }

  /// One-time automatic migration of any legacy SharedPreferences JSON array into Hive.
  static Future<void> _migrateFromLegacyPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? legacyList = prefs.getStringList(_legacyPrefsKey);
      if (legacyList != null && legacyList.isNotEmpty && _box != null) {
        for (final itemStr in legacyList) {
          try {
            final json = jsonDecode(itemStr) as Map<String, dynamic>;
            final model = CalculationModel.fromJson(json);
            if (!_box!.containsKey(model.id)) {
              await _box!.put(model.id, itemStr);
            }
          } catch (_) {}
        }
        await prefs.remove(_legacyPrefsKey);
      }
    } catch (_) {}
  }

  Future<Box<String>> _getBox() async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    if (Hive.isBoxOpen(_boxName)) {
      _box = Hive.box<String>(_boxName);
      return _box!;
    }
    _box = await Hive.openBox<String>(_boxName);
    return _box!;
  }

  /// Expose the underlying Hive box for live stream watching.
  Future<Box<String>> getBox() async => _getBox();

  /// Retrieve all calculations sorted newest-first.
  Future<List<CalculationModel>> loadHistory() async {
    try {
      final box = await _getBox();
      final List<CalculationModel> list = [];
      for (final key in box.keys) {
        final val = box.get(key);
        if (val != null) {
          try {
            list.add(CalculationModel.fromJson(jsonDecode(val)));
          } catch (_) {}
        }
      }
      // Sort newest-first (descending by timestamp ID)
      list.sort((a, b) => b.id.compareTo(a.id));
      return list;
    } catch (_) {
      return [];
    }
  }

  /// Add a new calculation record (O(1) write operation).
  Future<void> addCalculation(CalculationModel calculation) async {
    try {
      final box = await _getBox();
      await box.put(calculation.id, jsonEncode(calculation.toJson()));
    } catch (_) {}
  }

  /// Delete a calculation record by its unique ID (O(1) delete).
  Future<void> deleteById(String id) async {
    try {
      final box = await _getBox();
      await box.delete(id);
    } catch (_) {}
  }

  /// Delete a calculation at a specific index from the sorted list.
  Future<void> deleteCalculation(int index) async {
    try {
      final list = await loadHistory();
      if (index >= 0 && index < list.length) {
        await deleteById(list[index].id);
      }
    } catch (_) {}
  }

  /// Overwrite the entire history box with a new list.
  Future<void> saveHistory(List<CalculationModel> history) async {
    try {
      final box = await _getBox();
      await box.clear();
      for (final item in history) {
        await box.put(item.id, jsonEncode(item.toJson()));
      }
    } catch (_) {}
  }

  /// Clear all stored calculation records.
  Future<void> clearHistory() async {
    try {
      final box = await _getBox();
      await box.clear();
    } catch (_) {}
  }
}
