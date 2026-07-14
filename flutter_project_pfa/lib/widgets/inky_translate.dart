import 'package:flutter/material.dart';

class InkyLanguages extends StatefulWidget {
  final double size;
  const InkyLanguages({super.key, this.size = 200});

  @override
  State<InkyLanguages> createState() => _InkyLanguagesState();
}

class _InkyLanguagesState extends State<InkyLanguages>
    with TickerProviderStateMixin {
  late AnimationController _floatCtrl;
  late AnimationController _blinkCtrl;
  late AnimationController _bubbleTopCtrl;
  late AnimationController _bubbleRightCtrl;
  late AnimationController _bubbleLeftCtrl;

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
    _bubbleTopCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _bubbleRightCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _bubbleLeftCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _blinkCtrl.dispose();
    _bubbleTopCtrl.dispose();
    _bubbleRightCtrl.dispose();
    _bubbleLeftCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _floatCtrl,
        _blinkCtrl,
        _bubbleTopCtrl,
        _bubbleRightCtrl,
        _bubbleLeftCtrl,
      ]),
      builder: (context, child) {
        final floatY = _floatCtrl.value * -8;

        return Transform.translate(
          offset: Offset(0, floatY),
          child: SizedBox(
            width: widget.size * 1.8,
            height: widget.size * 1.6,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // ── Inky au centre ──────────────────────────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: CustomPaint(
                    size: Size(widget.size, widget.size * 1.1),
                    painter: _InkyPainter(
                      blinkValue: _blinkCtrl.value,
                      size: widget.size,
                    ),
                  ),
                ),

                // ── Bulle ARABE — au dessus de la tête ──────────
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Transform.translate(
                    offset: Offset(0, _bubbleTopCtrl.value * -5),
                    child: Center(
                      child: _SmallBubble(
                        flag: '🇸🇦',
                        language: 'العربية',
                        reminder: 'تذكّر!',
                        bgColor: const Color(0xFF065F46),
                        accentColor: const Color(0xFF34D399),
                        textDir: TextDirection.rtl,
                        tailSide: TailSide.bottom,
                      ),
                    ),
                  ),
                ),

                // ── Bulle ANGLAIS — à gauche ─────────────────────
                Positioned(
                  top: widget.size * 0.18,
                  left: 0,
                  child: Transform.translate(
                    offset: Offset(_bubbleLeftCtrl.value * -5, 0),
                    child: _SmallBubble(
                      flag: '🇬🇧',
                      language: 'English',
                      reminder: 'Remember!',
                      bgColor: const Color(0xFF1E3A8A),
                      accentColor: const Color(0xFF60A5FA),
                      textDir: TextDirection.ltr,
                      tailSide: TailSide.right,
                    ),
                  ),
                ),

                // ── Bulle FRANÇAIS — à droite ────────────────────
                Positioned(
                  top: widget.size * 0.18,
                  right: 0,
                  child: Transform.translate(
                    offset: Offset(_bubbleRightCtrl.value * 5, 0),
                    child: _SmallBubble(
                      flag: '🇫🇷',
                      language: 'Français',
                      reminder: 'Rappel !',
                      bgColor: const Color(0xFF78350F),
                      accentColor: const Color(0xFFFBBF24),
                      textDir: TextDirection.ltr,
                      tailSide: TailSide.left,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum TailSide { bottom, left, right }

class _SmallBubble extends StatelessWidget {
  final String flag;
  final String language;
  final String reminder;
  final Color bgColor;
  final Color accentColor;
  final TextDirection textDir;
  final TailSide tailSide;

  const _SmallBubble({
    required this.flag,
    required this.language,
    required this.reminder,
    required this.bgColor,
    required this.accentColor,
    required this.textDir,
    required this.tailSide,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BubblePainter(
        bgColor: bgColor,
        accentColor: accentColor,
        tailSide: tailSide,
      ),
      child: Container(
        width: 110,
        padding: EdgeInsets.only(
          left: tailSide == TailSide.right ? 20 : 10,
          right: tailSide == TailSide.left ? 20 : 10,
          top: 10,
          bottom: tailSide == TailSide.bottom ? 22 : 10,
        ),
        child: Directionality(
          textDirection: textDir,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Flag + langue
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(flag, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 5),
                  Text(
                    language,
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Texte rappel
              Text(
                reminder,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  final Color bgColor;
  final Color accentColor;
  final TailSide tailSide;

  const _BubblePainter({
    required this.bgColor,
    required this.accentColor,
    required this.tailSide,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const tailSize = 14.0;
    const rad = Radius.circular(14);

    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Ombre
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    late RRect bubbleRect;
    late Path tailPath;

    switch (tailSide) {
      case TailSide.bottom:
        // Queue vers le bas (pointe vers la tête d'Inky en dessous)
        bubbleRect = RRect.fromLTRBR(
          0,
          0,
          size.width,
          size.height - tailSize,
          rad,
        );
        tailPath = Path()
          ..moveTo(size.width / 2 - 10, size.height - tailSize)
          ..lineTo(size.width / 2, size.height)
          ..lineTo(size.width / 2 + 10, size.height - tailSize)
          ..close();
        break;
      case TailSide.right:
        // Queue vers la droite (pointe vers Inky à droite)
        bubbleRect = RRect.fromLTRBR(
          0,
          0,
          size.width - tailSize,
          size.height,
          rad,
        );
        tailPath = Path()
          ..moveTo(size.width - tailSize, size.height / 2 - 10)
          ..lineTo(size.width, size.height / 2)
          ..lineTo(size.width - tailSize, size.height / 2 + 10)
          ..close();
        break;
      case TailSide.left:
        // Queue vers la gauche (pointe vers Inky à gauche)
        bubbleRect = RRect.fromLTRBR(tailSize, 0, size.width, size.height, rad);
        tailPath = Path()
          ..moveTo(tailSize, size.height / 2 - 10)
          ..lineTo(0, size.height / 2)
          ..lineTo(tailSize, size.height / 2 + 10)
          ..close();
        break;
    }

    // Ombre
    canvas.drawRRect(bubbleRect.shift(const Offset(2, 4)), shadowPaint);

    // Fond
    canvas.drawPath(
      Path()
        ..addRRect(bubbleRect)
        ..addPath(tailPath, Offset.zero),
      bgPaint,
    );

    // Bordure
    canvas.drawRRect(bubbleRect, borderPaint);
    canvas.drawPath(tailPath, borderPaint);
  }

  @override
  bool shouldRepaint(_BubblePainter old) => false;
}

class _InkyPainter extends CustomPainter {
  final double blinkValue;
  final double size;

  const _InkyPainter({required this.blinkValue, required this.size});

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

    // Corps
    canvas.drawOval(
      Rect.fromCenter(center: p(100, 118), width: r(108), height: r(90)),
      fill(const Color(0xFF8B5CF6)),
    );

    // Tête
    canvas.drawOval(
      Rect.fromCenter(center: p(100, 72), width: r(90), height: r(96)),
      fill(const Color(0xFF7C3AED)),
    );

    // Yeux
    final eyeHeight = 18 * (blinkValue < 0.1 ? 0.1 : blinkValue);
    canvas.drawOval(
      Rect.fromCenter(center: p(82, 80), width: r(28), height: r(eyeHeight)),
      fill(Colors.white),
    );
    if (blinkValue > 0.1) {
      canvas.drawCircle(p(85, 81), r(8), fill(const Color(0xFF1E1B2E)));
      canvas.drawCircle(p(88, 78), r(3), fill(Colors.white));
    }
    canvas.drawOval(
      Rect.fromCenter(center: p(118, 80), width: r(28), height: r(eyeHeight)),
      fill(Colors.white),
    );
    if (blinkValue > 0.1) {
      canvas.drawCircle(p(121, 81), r(8), fill(const Color(0xFF1E1B2E)));
      canvas.drawCircle(p(124, 78), r(3), fill(Colors.white));
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
        p(100, 104).dx,
        p(100, 104).dy,
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

    // Tentacules
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
  bool shouldRepaint(_InkyPainter old) => old.blinkValue != blinkValue;
}
