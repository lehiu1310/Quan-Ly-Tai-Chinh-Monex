import 'package:flutter/material.dart';
import 'package:monex/theme/app_theme.dart';

class MonexBackground extends StatelessWidget {
  const MonexBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      color: isDark ? MonexColors.darkBackground : MonexColors.background,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _MonexPainter(isDark))),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _MonexPainter extends CustomPainter {
  const _MonexPainter(this.isDark);

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : MonexColors.primary).withValues(
        alpha: isDark ? 0.035 : 0.045,
      )
      ..strokeWidth = 1;
    final accentPaint = Paint()
      ..color = MonexColors.accent.withValues(alpha: isDark ? 0.06 : 0.08)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final chartPaint = Paint()
      ..color = (isDark ? Colors.white : MonexColors.primary).withValues(
        alpha: isDark ? 0.055 : 0.08,
      )
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (double x = -size.height; x < size.width; x += 48) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        gridPaint,
      );
    }

    for (double y = 120; y < size.height; y += 110) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y + 34),
        Paint()
          ..color = MonexColors.ink.withValues(alpha: 0.018)
          ..strokeWidth = 1,
      );
    }

    final topChart = Path()
      ..moveTo(size.width * 0.58, 88)
      ..lineTo(size.width * 0.68, 54)
      ..lineTo(size.width * 0.76, 76)
      ..lineTo(size.width * 0.88, 34)
      ..lineTo(size.width * 0.96, 48);
    canvas.drawPath(topChart, chartPaint);

    final bottomChart = Path()
      ..moveTo(26, size.height - 170)
      ..lineTo(size.width * 0.18, size.height - 202)
      ..lineTo(size.width * 0.32, size.height - 176)
      ..lineTo(size.width * 0.48, size.height - 230);
    canvas.drawPath(bottomChart, chartPaint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 92, size.height * 0.35, 128, 76),
        const Radius.circular(22),
      ),
      accentPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-46, size.height * 0.62, 120, 70),
        const Radius.circular(20),
      ),
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
