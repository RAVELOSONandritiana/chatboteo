import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DroidLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const DroidLogo({
    super.key,
    this.size = 120,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoColor = color ?? (isDark ? AppTheme.primaryColor : AppTheme.primaryColor);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DroidPainter(color: logoColor),
      ),
    );
  }
}

class _DroidPainter extends CustomPainter {
  final Color color;

  _DroidPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Head
    final headRadius = size.width * 0.35;
    final headPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(centerX, centerY - headRadius * 0.3),
      headRadius,
      headPaint,
    );

    // Eyes
    final eyeRadius = headRadius * 0.18;
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    // Left eye
    canvas.drawCircle(
      Offset(centerX - headRadius * 0.35, centerY - headRadius * 0.4),
      eyeRadius,
      eyePaint,
    );
    
    // Right eye
    canvas.drawCircle(
      Offset(centerX + headRadius * 0.35, centerY - headRadius * 0.4),
      eyeRadius,
      eyePaint,
    );

    // Inner eyes (pupils)
    final pupilRadius = eyeRadius * 0.5;
    final pupilPaint = Paint()
      ..color = const Color(0xFF0F0F23)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(centerX - headRadius * 0.35, centerY - headRadius * 0.4),
      pupilRadius,
      pupilPaint,
    );
    
    canvas.drawCircle(
      Offset(centerX + headRadius * 0.35, centerY - headRadius * 0.4),
      pupilRadius,
      pupilPaint,
    );

    // Antenna
    final antennaPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Left antenna
    canvas.drawLine(
      Offset(centerX - headRadius * 0.5, centerY - headRadius * 1.1),
      Offset(centerX - headRadius * 0.3, centerY - headRadius * 0.6),
      antennaPaint,
    );

    // Right antenna
    canvas.drawLine(
      Offset(centerX + headRadius * 0.5, centerY - headRadius * 1.1),
      Offset(centerX + headRadius * 0.3, centerY - headRadius * 0.6),
      antennaPaint,
    );

    // Smile
    final smilePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final smilePath = Path();
    smilePath.moveTo(centerX - headRadius * 0.4, centerY);
    smilePath.quadraticBezierTo(
      centerX,
      centerY + headRadius * 0.3,
      centerX + headRadius * 0.4,
      centerY,
    );

    canvas.drawPath(smilePath, smilePaint);

    // Glow effect around head
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawCircle(
      Offset(centerX, centerY - headRadius * 0.3),
      headRadius + 10,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
