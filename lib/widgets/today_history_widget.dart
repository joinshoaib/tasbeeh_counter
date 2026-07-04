import 'package:home_widget/home_widget.dart';

class TodayHistoryWidget {
  static const String appGroupId = 'group.tasbeeh.counter';
  static const String androidName = 'TodayHistoryWidget';
  static const String iOSName = 'TodayHistoryWidget';

  static Future<void> init() async {
    await HomeWidget.setAppGroupId(appGroupId);
  }

  static Future<void> update({required Map<String, int> todayDhikrs}) async {
    // Save each dhikr count as separate key
    todayDhikrs.forEach((name, count) {
      HomeWidget.saveWidgetData('dhikr_$name', count.toString());
    });

    // Save total dhikr count
    HomeWidget.saveWidgetData('history_count', todayDhikrs.length.toString());

    await HomeWidget.updateWidget(name: androidName, iOSName: iOSName);
  }
}
