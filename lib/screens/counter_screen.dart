import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/counter_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/circular_progress.dart';
import '../widgets/dhikr_selector.dart';
import '../widgets/target_selector.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTap() {
    final provider = Provider.of<CounterProvider>(context, listen: false);
    provider.increment();
    _scaleController.forward().then((_) => _scaleController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final counterProvider = Provider.of<CounterProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasbeeh Counter'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;
            final isSmallScreen = availableHeight < 700;

            // Fixed heights for each widget section
            final dhikrHeight = 100.0;
            final targetHeight = 90.0;
            final resetButtonHeight = 50.0;
            final tapButtonSize = isSmallScreen ? 130.0 : 160.0;
            final spacing = isSmallScreen ? 8.0 : 12.0;

            // Calculate remaining space for progress circle
            final reservedHeight =
                dhikrHeight +
                targetHeight +
                resetButtonHeight +
                tapButtonSize +
                (spacing * 4);
            final progressSize = (availableHeight - reservedHeight).clamp(
              180.0,
              280.0,
            );

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: availableHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(height: 8),

                    // Dhikr Selector - FIXED height, no expansion
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const SizedBox(
                        height: 100,
                        child: DhikrSelector(),
                      ),
                    ),

                    SizedBox(height: spacing),

                    // Target Selector
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const SizedBox(
                        height: 90,
                        child: TargetSelector(),
                      ),
                    ),

                    SizedBox(height: spacing),

                    // Progress Circle - EXPLICIT size, no overlap
                    GestureDetector(
                          onTap: _onTap,
                          child: AnimatedBuilder(
                            animation: _scaleController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1 - (_scaleController.value * 0.05),
                                child: child,
                              );
                            },
                            child: SizedBox(
                              width: progressSize,
                              height: progressSize,
                              child: CircularProgress(
                                progress: counterProvider.progress,
                                count: counterProvider.count,
                                target: counterProvider.target,
                                isCompleted: counterProvider.isCompleted,
                              ),
                            ),
                          ),
                        )
                        .animate(target: counterProvider.isCompleted ? 1 : 0)
                        .shake(
                          duration: const Duration(milliseconds: 500),
                          hz: 3,
                        ),

                    SizedBox(height: spacing),

                    // Tap Button
                    GestureDetector(
                          onTap: _onTap,
                          child: Container(
                            width: tapButtonSize,
                            height: tapButtonSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.7),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.4),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.touch_app,
                                    size: isSmallScreen ? 36 : 44,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'TAP',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 14 : 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white.withOpacity(0.9),
                                      letterSpacing: 3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true),
                        )
                        .scale(
                          duration: const Duration(seconds: 2),
                          begin: const Offset(1, 1),
                          end: const Offset(1.03, 1.03),
                        ),

                    const SizedBox(height: 8),

                    // Reset Button
                    TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Reset Counter?'),
                            content: const Text(
                              'Are you sure you want to reset the current counter?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  counterProvider.reset();
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Reset',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Reset'),
                      style: TextButton.styleFrom(foregroundColor: Colors.grey),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
