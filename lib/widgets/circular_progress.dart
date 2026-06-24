import 'package:flutter/material.dart';
import 'dart:math' as math;

class CircularProgress extends StatelessWidget {
  final double progress;
  final int count;
  final int target;
  final bool isCompleted;

  const CircularProgress({
    super.key,
    required this.progress,
    required this.count,
    required this.target,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    // Use parent container size instead of MediaQuery
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final clampedProgress = progress.clamp(0.0, 1.0);

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _ProgressPainter(
                  progress: 1.0,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  strokeWidth: size * 0.04,
                ),
              ),
              CustomPaint(
                size: Size(size, size),
                painter: _ProgressPainter(
                  progress: clampedProgress,
                  color: isCompleted
                      ? Colors.green
                      : Theme.of(context).colorScheme.primary,
                  strokeWidth: size * 0.04,
                  isAnimated: true,
                ),
              ),
              if (isCompleted)
                Container(
                  width: size * 0.85,
                  height: size * 0.85,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(0.1),
                  ),
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: size * 0.22,
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                          ? Colors.green
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '/ $target',
                    style: TextStyle(
                      fontSize: size * 0.09,
                      color: Colors.grey.withOpacity(0.7),
                    ),
                  ),
                  if (isCompleted)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Completed!',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final bool isAnimated;

  _ProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    this.isAnimated = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromCircle(center: center, radius: radius);

    if (isAnimated && progress > 0) {
      final gradient = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + (2 * math.pi * progress),
        colors: [color.withOpacity(0.5), color],
      );

      paint.shader = gradient.createShader(rect);
    }

    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, paint);
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
