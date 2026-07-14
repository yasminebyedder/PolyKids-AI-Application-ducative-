import 'package:flutter/material.dart';

class InkyReading extends StatefulWidget {
  final double size;
  const InkyReading({super.key, this.size = 200});

  @override
  State<InkyReading> createState() => _InkyReadingState();
}

class _InkyReadingState extends State<InkyReading>
    with TickerProviderStateMixin {
  late AnimationController _floatCtrl;
  late AnimationController _blinkCtrl;
  late AnimationController _pageCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();
    _pageCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _blinkCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatCtrl, _blinkCtrl, _pageCtrl]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatCtrl.value * -8),
          child: CustomPaint(
            size: Size(widget.size, widget.size * 1.1),
            painter: _InkyPainter(
              blinkValue: _blinkCtrl.value,
              pageAngle: _pageCtrl.value,
              size: widget.size,
            ),
          ),
        );
      },
    );
  }
}

class _InkyPainter extends CustomPainter {
  final double blinkValue;
  final double pageAngle;
  final double size;

  const _InkyPainter({
    required this.blinkValue,
    required this.pageAngle,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size _) {
    final scale = size / 200;

    // ✅ CORRECTION : num accepte int et double
    Offset p(num x, num y) =>
        Offset(x.toDouble() * scale, y.toDouble() * scale);
    double r(double v) => v * scale;

    Paint paint(Color c, {double opacity = 1.0}) => Paint()
      // ignore: deprecated_member_use
      ..color = c.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    Paint stroke(Color c, double width) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * scale
      ..strokeCap = StrokeCap.round;

    // Corps principal
    canvas.drawOval(
      Rect.fromCenter(center: p(100, 118), width: r(108), height: r(90)),
      paint(const Color(0xFF8B5CF6)),
    );

    // Tête
    canvas.drawOval(
      Rect.fromCenter(center: p(100, 72), width: r(90), height: r(96)),
      paint(const Color(0xFF7C3AED)),
    );

    // Yeux avec clignement
    final eyeHeight = 18 * (blinkValue < 0.1 ? 0.1 : blinkValue);
    canvas.drawOval(
      Rect.fromCenter(center: p(82, 80), width: r(28), height: r(eyeHeight)),
      paint(Colors.white),
    );
    if (blinkValue > 0.1) {
      canvas.drawCircle(p(85, 81), r(8), paint(const Color(0xFF1E1B2E)));
      canvas.drawCircle(p(88, 78), r(3), paint(Colors.white));
    }

    canvas.drawOval(
      Rect.fromCenter(center: p(118, 80), width: r(28), height: r(eyeHeight)),
      paint(Colors.white),
    );
    if (blinkValue > 0.1) {
      canvas.drawCircle(p(121, 81), r(8), paint(const Color(0xFF1E1B2E)));
      canvas.drawCircle(p(124, 78), r(3), paint(Colors.white));
    }

    // Sourcils
    canvas.drawLine(p(70, 65), p(95, 60), stroke(const Color(0xFF3730A3), 3.5));
    canvas.drawLine(
      p(105, 60),
      p(130, 65),
      stroke(const Color(0xFF3730A3), 3.5),
    );

    // Bouche
    final mouthPath = Path()
      ..moveTo(p(88, 96).dx, p(88, 96).dy)
      ..quadraticBezierTo(
        p(100, 102).dx,
        p(100, 102).dy,
        p(112, 96).dx,
        p(112, 96).dy,
      );
    canvas.drawPath(mouthPath, stroke(const Color(0xFF3730A3), 3));

    // Joues
    canvas.drawOval(
      Rect.fromCenter(center: p(66, 90), width: r(18), height: r(11)),
      paint(const Color(0xFFF9A8D4), opacity: 0.5),
    );
    canvas.drawOval(
      Rect.fromCenter(center: p(134, 90), width: r(18), height: r(11)),
      paint(const Color(0xFFF9A8D4), opacity: 0.5),
    );

    // Livre simplifié
    canvas.save();
    canvas.translate(p(100, 148).dx, p(100, 148).dy);

    // Page gauche
    canvas.save();
    canvas.rotate(-0.12 + pageAngle * 0.3);
    canvas.drawRect(
      Rect.fromLTWH(-r(38), -r(28), r(38), r(52)),
      paint(const Color(0xFF3730A3)),
    );
    for (int i = 0; i < 4; i++) {
      canvas.drawRect(
        Rect.fromLTWH(-r(34), -r(20) + (i * r(7)), r(28), r(3)),
        paint(const Color(0xFFA78BFA), opacity: 0.7),
      );
    }
    canvas.restore();

    // Page droite
    canvas.save();
    canvas.rotate(0.12 + pageAngle * 0.3);
    canvas.drawRect(
      Rect.fromLTWH(0, -r(28), r(38), r(52)),
      paint(const Color(0xFF4C1D95)),
    );
    for (int i = 0; i < 4; i++) {
      canvas.drawRect(
        Rect.fromLTWH(r(6), -r(20) + (i * r(7)), r(26 - (i * 2)), r(3)),
        paint(const Color(0xFFA78BFA), opacity: 0.7),
      );
    }
    canvas.restore();

    canvas.restore();

    // ✅ CORRECTION : List<List<num>> pour éviter int/double mismatch
    final List<List<num>> tentacles = [
      [70, 148, 55, 190, 47, 208],
      [88, 154, 76, 198, 72, 212],
      [112, 156, 118, 198, 120, 213],
      [128, 154, 138, 195, 142, 210],
    ];

    for (var t in tentacles) {
      final path = Path()
        ..moveTo(p(t[0], t[1]).dx, p(t[0], t[1]).dy)
        ..quadraticBezierTo(
          p(t[2], t[3]).dx,
          p(t[2], t[3]).dy,
          p(t[4], t[5]).dx,
          p(t[4], t[5]).dy,
        );
      canvas.drawPath(path, stroke(const Color(0xFF6D28D9), 10));
      canvas.drawOval(
        Rect.fromCenter(center: p(t[4], t[5] + 5), width: r(13), height: r(9)),
        paint(const Color(0xFFA78BFA)),
      );
    }
  }

  @override
  bool shouldRepaint(_InkyPainter old) {
    return old.blinkValue != blinkValue || old.pageAngle != pageAngle;
  }
}
