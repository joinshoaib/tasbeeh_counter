import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import '../models/dhikr_model.dart';
import '../models/stats_model.dart';
import 'package:intl/intl.dart';

class CounterProvider extends ChangeNotifier {
  int _count = 0;
  int _target = 33;
  int _totalCount = 0;
  bool _vibrationEnabled = true;
  bool _soundEnabled = false;
  DhikrModel _currentDhikr = defaultDhikrs[0];
  List<DailyStats> _stats = [];

  int get count => _count;
  int get target => _target;
  int get totalCount => _totalCount;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get soundEnabled => _soundEnabled;
  DhikrModel get currentDhikr => _currentDhikr;
  List<DailyStats> get stats => _stats;

  double get progress => _target > 0 ? _count / _target : 0;
  bool get isCompleted => _count >= _target && _target > 0;

  int get todayCount {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayStats = _stats.where((s) => s.date == today).toList();
    if (todayStats.isEmpty) return 0;
    return todayStats.first.totalCount;
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _count = prefs.getInt('count') ?? 0;
    _target = prefs.getInt('target') ?? 33;
    _totalCount = prefs.getInt('totalCount') ?? 0;
    _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
    _soundEnabled = prefs.getBool('soundEnabled') ?? false;

    final dhikrIndex = prefs.getInt('currentDhikrIndex') ?? 0;
    _currentDhikr = defaultDhikrs[dhikrIndex.clamp(0, defaultDhikrs.length - 1)];

    final statsJson = prefs.getString('stats');
    if (statsJson != null) {
      final List<dynamic> decoded = jsonDecode(statsJson);
      _stats = decoded.map((e) => DailyStats.fromJson(e)).toList();
    }

    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('count', _count);
    await prefs.setInt('target', _target);
    await prefs.setInt('totalCount', _totalCount);
    await prefs.setBool('vibrationEnabled', _vibrationEnabled);
    await prefs.setBool('soundEnabled', _soundEnabled);
    await prefs.setInt('currentDhikrIndex', defaultDhikrs.indexOf(_currentDhikr));
    await prefs.setString('stats', jsonEncode(_stats.map((e) => e.toJson()).toList()));
  }

  Future<void> increment() async {
    _count++;
    _totalCount++;

    // Update today's stats
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayIndex = _stats.indexWhere((s) => s.date == today);

    if (todayIndex >= 0) {
      final updatedCounts = Map<String, int>.from(_stats[todayIndex].dhikrCounts);
      updatedCounts[_currentDhikr.name] = (updatedCounts[_currentDhikr.name] ?? 0) + 1;
      _stats[todayIndex] = DailyStats(date: today, dhikrCounts: updatedCounts);
    } else {
      _stats.add(DailyStats(
        date: today,
        dhikrCounts: {_currentDhikr.name: 1},
      ));
    }

    // Keep only last 30 days
    if (_stats.length > 30) {
      _stats = _stats.sublist(_stats.length - 30);
    }

    if (_vibrationEnabled) {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 30);
      }
    }

    await _saveData();
    notifyListeners();
  }

  Future<void> reset() async {
    _count = 0;
    await _saveData();
    notifyListeners();
  }

  Future<void> setTarget(int newTarget) async {
    _target = newTarget;
    await _saveData();
    notifyListeners();
  }

  Future<void> setDhikr(DhikrModel dhikr) async {
    _currentDhikr = dhikr;
    _count = 0;
    _target = dhikr.defaultTarget;
    await _saveData();
    notifyListeners();
  }

  Future<void> toggleVibration() async {
    _vibrationEnabled = !_vibrationEnabled;
    await _saveData();
    notifyListeners();
  }

  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    await _saveData();
    notifyListeners();
  }

  Future<void> clearAllData() async {
    _count = 0;
    _totalCount = 0;
    _stats = [];
    await _saveData();
    notifyListeners();
  }
}
