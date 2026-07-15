import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/counter_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'widgets/single_counter_widget.dart';
import 'widgets/daily_stats_widget.dart';
import 'utils/sound_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SingleCounterWidget.init();
  await DailyStatsWidget.init();
  await SoundService.init();

  await NotificationService.init();

  final counterProvider = CounterProvider();
  final themeProvider = ThemeProvider();

  await counterProvider.loadData();
  await themeProvider.loadTheme();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: counterProvider),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: const TasbeehApp(),
    ),
  );
}

class TasbeehApp extends StatelessWidget {
  const TasbeehApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Tasbeeh Counter',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.themeData,
      home: const HomeScreen(),
    );
  }
}
