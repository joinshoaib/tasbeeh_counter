import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasbeeh_counter/utils/sound_service.dart';
import 'package:vibration/vibration.dart';
import '../models/dhikr_model.dart';
import '../models/stats_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../widgets/single_counter_widget.dart';
import '../widgets/daily_stats_widget.dart';
import '../widgets/today_history_widget.dart';
import '../services/notification_service.dart';

class CounterProvider extends ChangeNotifier {
  int _count = 0;
  int _target = 33;
  int _totalCount = 0;
  int _dailyGoal = 100;
  bool _vibrationEnabled = true;
  bool _soundEnabled = false;
  bool _notificationsEnabled = true;
  DhikrModel _currentDhikr = defaultDhikrs[0];
  List<DailyStats> _stats = [];

  int get count => _count;
  int get target => _target;
  int get totalCount => _totalCount;
  int get dailyGoal => _dailyGoal;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get soundEnabled => _soundEnabled;
  DhikrModel get currentDhikr => _currentDhikr;
  List<DailyStats> get stats => _stats;

  bool get notificationsEnabled => _notificationsEnabled;
  //

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
    _dailyGoal = prefs.getInt('dailyGoal') ?? 100;
    _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
    _soundEnabled = prefs.getBool('soundEnabled') ?? false;
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? false;

    final dhikrIndex = prefs.getInt('currentDhikrIndex') ?? 0;
    _currentDhikr =
        defaultDhikrs[dhikrIndex.clamp(0, defaultDhikrs.length - 1)];

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
    await prefs.setInt('dailyGoal', _dailyGoal); // <-- ADD THIS
    await prefs.setBool('vibrationEnabled', _vibrationEnabled);
    await prefs.setBool('soundEnabled', _soundEnabled);
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setInt(
      'currentDhikrIndex',
      defaultDhikrs.indexOf(_currentDhikr),
    );
    await prefs.setString(
      'stats',
      jsonEncode(_stats.map((e) => e.toJson()).toList()),
    );

    await SingleCounterWidget.update(
      dhikrName: _currentDhikr.name,
      count: _count,
      target: _target,
      arabicName: _currentDhikr.arabic,
    );

    // In increment(), after _saveData():
    await DailyStatsWidget.update(
      todayCount: todayCount,
      dailyGoal: _dailyGoal,
    );
  }

  Future<void> increment() async {
    _count++;
    _totalCount++;

    // Update today's stats
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayIndex = _stats.indexWhere((s) => s.date == today);

    if (todayIndex >= 0) {
      final updatedCounts = Map<String, int>.from(
        _stats[todayIndex].dhikrCounts,
      );
      updatedCounts[_currentDhikr.name] =
          (updatedCounts[_currentDhikr.name] ?? 0) + 1;
      _stats[todayIndex] = DailyStats(date: today, dhikrCounts: updatedCounts);
    } else {
      _stats.add(DailyStats(date: today, dhikrCounts: {_currentDhikr.name: 1}));
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

    if (_soundEnabled) {
      //SystemSound.play(SystemSoundType.click);
      SoundService.playClick();
    }

    await _saveData();

    // Update daily stats widget
    await DailyStatsWidget.update(
      todayCount: todayCount,
      dailyGoal: _dailyGoal,
    );

    // In increment(), after _saveData():
    //final today1 = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayStats = _stats.where((s) => s.date == today).toList();
    final currentTodayStats = todayStats.isNotEmpty ? todayStats.first : null;

    final targets = <String, int>{};
    for (final dhikr in defaultDhikrs) {
      targets[dhikr.name] = dhikr.defaultTarget;
    }

    await TodayHistoryWidget.update(
      todayStats: currentTodayStats,
      dhikrTargets: targets,
    );

    if (_count == _target) {
      await NotificationService.showNotification(
        title: 'Mashallah! 🎉',
        body: '${_currentDhikr.name} $_count/$_target completed',
      );
    }

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
    TodayHistoryWidget.clear();
    await _saveData();
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await _saveData();
    notifyListeners();
  }

  Future<void> setDailyGoal(int newGoal) async {
    _dailyGoal = newGoal;
    await _saveData();

    // Update widget with new goal
    await DailyStatsWidget.update(
      todayCount: todayCount,
      dailyGoal: _dailyGoal,
    );

    notifyListeners();
  }
}
