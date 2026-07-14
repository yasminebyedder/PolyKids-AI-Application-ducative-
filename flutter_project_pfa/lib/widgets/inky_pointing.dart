import 'package:flutter/material.dart';

class InkyPointing extends StatefulWidget {
  final double size;
  const InkyPointing({super.key, this.size = 200});

  @override
  State<InkyPointing> createState() => _InkyPointingState();
}

class _InkyPointingState extends State<InkyPointing>
    with TickerProviderStateMixin {
  late AnimationController _floatCtrl;
  late AnimationController _blinkCtrl;
  late AnimationController _armCtrl;

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
    _armCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _blinkCtrl.dispose();
    _armCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatCtrl, _blinkCtrl, _armCtrl]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatCtrl.value * -8),
          child: CustomPaint(
            size: Size(widget.size, widget.size * 1.1),
            painter: _InkyPainter(
              blinkValue: _blinkCtrl.value,
              armValue: _armCtrl.value,
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
  final double armValue;
  final double size;

  const _InkyPainter({
    required this.blinkValue,
    required this.armValue,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size _) {
    final scale = size / 200;

    Offset p(num x, num y) =>
        Offset(x.toDouble() * scale, y.toDouble() * scale);
    double r(double v) => v * scale;

    Paint fill(Color c, {double opacity = 1.0}) => Paint()
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
      fill(const Color(0xFF8B5CF6)),
    );

    // Tête
    canvas.drawOval(
      Rect.fromCenter(center: p(100, 72), width: r(90), height: r(96)),
      fill(const Color(0xFF7C3AED)),
    );

    // Yeux qui regardent vers la droite
    final eyeHeight = 18 * (blinkValue < 0.1 ? 0.1 : blinkValue);

    // Œil gauche
    canvas.drawOval(
      Rect.fromCenter(center: p(82, 80), width: r(28), height: r(eyeHeight)),
      fill(Colors.white),
    );
    if (blinkValue > 0.1) {
      canvas.drawCircle(p(87, 81), r(8), fill(const Color(0xFF1E1B2E)));
      canvas.drawCircle(p(90, 78), r(3), fill(Colors.white));
    }

    // Œil droit
    canvas.drawOval(
      Rect.fromCenter(center: p(118, 80), width: r(28), height: r(eyeHeight)),
      fill(Colors.white),
    );
    if (blinkValue > 0.1) {
      canvas.drawCircle(p(123, 81), r(8), fill(const Color(0xFF1E1B2E)));
      canvas.drawCircle(p(126, 78), r(3), fill(Colors.white));
    }

    // Sourcils levés (enthousiaste)
    canvas.drawLine(p(70, 62), p(95, 58), stroke(const Color(0xFF3730A3), 3.5));
    canvas.drawLine(
      p(105, 58),
      p(130, 62),
      stroke(const Color(0xFF3730A3), 3.5),
    );

    // Bouche souriante
    final mouthPath = Path()
      ..moveTo(p(88, 96).dx, p(88, 96).dy)
      ..quadraticBezierTo(
        p(100, 105).dx,
        p(100, 105).dy,
        p(112, 96).dx,
        p(112, 96).dy,
      );
    canvas.drawPath(mouthPath, stroke(const Color(0xFF3730A3), 3));

    // Joues
    canvas.drawOval(
      Rect.fromCenter(center: p(66, 90), width: r(18), height: r(11)),
      fill(const Color(0xFFF9A8D4), opacity: 0.5),
    );
    canvas.drawOval(
      Rect.fromCenter(center: p(134, 90), width: r(18), height: r(11)),
      fill(const Color(0xFFF9A8D4), opacity: 0.5),
    );

    // ── TENTACULE BRAS DROIT qui pointe vers la droite ───────────
    // La pointe pulse légèrement pour attirer l'attention
    final tipX = 190.0 + armValue * 6;
    final tipY = 92.0 - armValue * 4;

    final armPath = Path()
      ..moveTo(p(138, 112).dx, p(138, 112).dy)
      ..quadraticBezierTo(
        p(165, 100).dx,
        p(165, 100).dy,
        p(tipX, tipY).dx,
        p(tipX, tipY).dy,
      );
    canvas.drawPath(armPath, stroke(const Color(0xFF6D28D9), 11));

    // Ventouse bout du tentacule
    canvas.drawOval(
      Rect.fromCenter(center: p(tipX, tipY), width: r(14), height: r(10)),
      fill(const Color(0xFFA78BFA)),
    );

    // Flèche jaune au bout (indique clairement la direction)
    final arrowPath = Path()
      ..moveTo(p(tipX + 6, tipY - 7).dx, p(tipX + 6, tipY - 7).dy)
      ..lineTo(p(tipX + 17, tipY).dx, p(tipX + 17, tipY).dy)
      ..lineTo(p(tipX + 6, tipY + 7).dx, p(tipX + 6, tipY + 7).dy);
    canvas.drawPath(arrowPath, stroke(const Color(0xFFFBBF24), 3.5));

    // ── TENTACULES DU BAS ────────────────────────────────────────
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
        fill(const Color(0xFFA78BFA)),
      );
    }
  }

  @override
  bool shouldRepaint(_InkyPainter old) {
    return old.blinkValue != blinkValue || old.armValue != armValue;
  }
}
