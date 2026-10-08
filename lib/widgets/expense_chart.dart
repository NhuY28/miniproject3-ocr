import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ExpenseChart extends StatelessWidget {
  const ExpenseChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: CustomPaint(
        painter: ChartPainter(),
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintBar = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final paintBackgroundBar = Paint()
      ..color = AppColors.primaryLight
      ..style = PaintingStyle.fill;

    List<double> values = [0.4, 0.7, 0.3, 0.9, 0.5, 0.8, 0.6];
    double barWidth = 24.0;
    double space = (size.width - (values.length * barWidth)) / (values.length - 1);

    for (int i = 0; i < values.length; i++) {
      double x = i * (barWidth + space);
      double barHeight = size.height * values[i];
      double y = size.height - barHeight;

      // Draw background rounded track
      RRect bgRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 0, barWidth, size.height),
        const Radius.circular(8),
      );
      canvas.drawRRect(bgRRect, paintBackgroundBar);

      // Draw filled bar
      RRect barRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(8),
      );
      canvas.drawRRect(barRRect, paintBar);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}