import 'package:home_widget/home_widget.dart';

class SingleCounterWidget {
  static const String appGroupId = 'group.tasbeeh.counter';
  static const String androidName = 'SingleCounterWidget';
  static const String iOSName = 'SingleCounterWidget';

  static Future<void> init() async {
    await HomeWidget.setAppGroupId(appGroupId);
  }

  static Future<void> update({
    required String dhikrName,
    required int count,
    required int target,
    required String arabicName,
  }) async {
    await HomeWidget.saveWidgetData('dhikr_name', dhikrName);
    await HomeWidget.saveWidgetData('count', count.toString());
    await HomeWidget.saveWidgetData('target', target.toString());
    await HomeWidget.saveWidgetData('arabic_name', arabicName.toString());

    await HomeWidget.updateWidget(name: androidName, iOSName: iOSName);
  }
}
