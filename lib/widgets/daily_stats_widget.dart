import 'package:home_widget/home_widget.dart';

class DailyStatsWidget {
  static const String appGroupId = 'group.tasbeeh.counter';
  static const String androidName = 'DailyStatsWidget';
  static const String iOSName = 'DailyStatsWidget';

  static Future<void> init() async {
    await HomeWidget.setAppGroupId(appGroupId);
  }

  static Future<void> update({
    required int todayCount,
    required int dailyGoal,
  }) async {
    await HomeWidget.saveWidgetData('today_count', todayCount.toString());
    await HomeWidget.saveWidgetData('daily_goal', dailyGoal.toString());

    await HomeWidget.updateWidget(name: androidName, iOSName: iOSName);
  }
}
