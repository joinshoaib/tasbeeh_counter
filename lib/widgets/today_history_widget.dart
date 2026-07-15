import 'package:home_widget/home_widget.dart';
import '../models/stats_model.dart';

class TodayHistoryWidget {
  static const String appGroupId = 'group.tasbeeh.counter';
  static const String androidName = 'TodayHistoryWidget';
  static const String iOSName = 'TodayHistoryWidget';

  static Future<void> init() async {
    await HomeWidget.setAppGroupId(appGroupId);
  }

  // Pass today's stats directly from _stats list
  static Future<void> update({
    required DailyStats? todayStats,
    required Map<String, int> dhikrTargets,
  }) async {
    // Clear old data first
    await HomeWidget.saveWidgetData('dhikr_count', '0');

    if (todayStats != null) {
      // Save each dhikr from today's stats
      todayStats.dhikrCounts.forEach((name, count) {
        HomeWidget.saveWidgetData('dhikr_$name', count.toString());
      });
    }

    // Save targets
    dhikrTargets.forEach((name, target) {
      HomeWidget.saveWidgetData('target_$name', target.toString());
    });

    await HomeWidget.updateWidget(name: androidName, iOSName: iOSName);
  }

  static Future<void> clear() async {
    await HomeWidget.saveWidgetData('dhikr_count', '0');
    await HomeWidget.updateWidget(name: androidName, iOSName: iOSName);
  }
}
