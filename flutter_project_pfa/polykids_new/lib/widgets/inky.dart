import 'package:flutter/material.dart';
import 'dart:math' as math;

// ─────────────────────────────────────────────
//  INKY — Mascotte LinguaKids
//  Usage : InkyMascot(mood: InkyMood.bonjour)
// ─────────────────────────────────────────────

enum InkyMood { bonjour, bravo, erreur, reflechit, serie, espiegle }

class InkyMascot extends StatefulWidget {
  final InkyMood mood;
  final double size;

  const InkyMascot({super.key, this.mood = InkyMood.bonjour, this.size = 200});

  @override
  State<InkyMascot> createState() => _InkyMascotState();
}

class _InkyMascotState extends State<InkyMascot> with TickerProviderStateMixin {
  late AnimationController _floatCtrl;
  late AnimationController _tentCtrl;
  late AnimationController _blinkCtrl;
  late AnimationController _hatCtrl;
  late AnimationController _sparkCtrl;

  late Animation<double> _floatAnim;
  late Animation<double> _tentAnim;
  late Animation<double> _blinkAnim;
  late Animation<double> _hatAnim;
  late Animation<double> _sparkAnim;

  static const _purple = Color(0xFF7C3AED);

  Map<InkyMood, _MoodData> get _moods => {
    InkyMood.bonjour: _MoodData(
      "Coucou ! Je suis Inky !\nJ'ai 6 bras pour t'aider ! 👋",
      _purple,
    ),
  };

  @override
  void initState() {
    super.initState();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _tentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();
    _hatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _sparkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(
      begin: 0,
      end: -14,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _tentAnim = Tween<double>(
      begin: 0,
      end: 14 * math.pi / 180,
    ).animate(CurvedAnimation(parent: _tentCtrl, curve: Curves.easeInOut));
    _blinkAnim = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 86),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.07), weight: 2),
      TweenSequenceItem(tween: ConstantTween(0.07), weight: 4),
      TweenSequenceItem(tween: Tween(begin: 0.07, end: 1.0), weight: 2),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 6),
    ]).animate(_blinkCtrl);
    _hatAnim = Tween<double>(
      begin: -3 * math.pi / 180,
      end: 5 * math.pi / 180,
    ).animate(CurvedAnimation(parent: _hatCtrl, curve: Curves.easeInOut));
    _sparkAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _sparkCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _tentCtrl.dispose();
    _blinkCtrl.dispose();
    _hatCtrl.dispose();
    _sparkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moodData = _moods[widget.mood]!;
    final scale = widget.size / 260;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size * 280 / 260,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _floatCtrl,
              _tentCtrl,
              _blinkCtrl,
              _hatCtrl,
              _sparkCtrl,
            ]),
            builder: (context, _) {
              return CustomPaint(
                painter: _InkyPainter(
                  floatOffset: _floatAnim.value,
                  tentAngle: _tentAnim.value,
                  blinkScale: _blinkAnim.value,
                  hatAngle: _hatAnim.value,
                  sparkOpacity: _sparkAnim.value,
                  scale: scale,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Speech bubble
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Container(
            key: ValueKey(widget.mood),
            constraints: BoxConstraints(maxWidth: widget.size),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: moodData.color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Text(
              moodData.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MoodData {
  final String text;
  final Color color;
  const _MoodData(this.text, this.color);
}

// ─── PAINTER ──────────────────────────────────

class _InkyPainter extends CustomPainter {
  final double floatOffset;
  final double tentAngle;
  final double blinkScale;
  final double hatAngle;
  final double sparkOpacity;
  final double scale;

  static const _purple = Color(0xFF7C3AED);
  static const _purpleDark = Color(0xFF6D28D9);
  static const _purpleLight = Color(0xFF8B5CF6);
  static const _purplePale = Color(0xFFA78BFA);
  static const _purpleFaint = Color(0xFFC4B5FD);
  static const _navy = Color(0xFF3730A3);
  static const _deepNavy = Color(0xFF4C1D95);
  static const _ink = Color(0xFF1E1B2E);
  static const _pink = Color(0xFFF9A8D4);
  static const _yellow = Color(0xFFFCD34D);
  static const _coral = Color(0xFFFB7185);
  static const _mint = Color(0xFF34D399);

  _InkyPainter({
    required this.floatOffset,
    required this.tentAngle,
    required this.blinkScale,
    required this.hatAngle,
    required this.sparkOpacity,
    required this.scale,
  });

  Paint _p(
    Color c, {
    double opacity = 1.0,
    PaintingStyle style = PaintingStyle.fill,
    double strokeWidth = 1,
  }) {
    return Paint()
      ..color = c.withOpacity(opacity)
      ..style = style
      ..strokeWidth = strokeWidth * scale
      ..strokeCap = StrokeCap.round;
  }

  Offset _s(double x, double y) => Offset(x * scale, y * scale);

  double _r(double r) => r * scale;

  void _drawTentacle(
    Canvas canvas,
    double startX,
    double startY,
    double cp1x,
    double cp1y,
    double endX,
    double endY,
    double tipX,
    double tipY,
    double delay,
  ) {
    final angle = tentAngle * math.sin(delay);
    canvas.save();
    canvas.translate(_s(startX, startY).dx, _s(startX, startY).dy);
    canvas.rotate(angle);
    canvas.translate(-_s(startX, startY).dx, -_s(startX, startY).dy);

    final path = Path()
      ..moveTo(_s(startX, startY).dx, _s(startY, startY).dy)
      ..quadraticBezierTo(
        _s(cp1x, cp1y).dx,
        _s(cp1x, cp1y).dy,
        _s(endX, endY).dx,
        _s(endX, endY).dy,
      );

    canvas.drawPath(
      path,
      _p(_purpleDark, strokeWidth: 13, style: PaintingStyle.stroke),
    );
    canvas.drawOval(
      Rect.fromCenter(center: _s(tipX, tipY), width: _r(16), height: _r(12)),
      _p(_purplePale),
    );
    // suction cups
    canvas.drawCircle(
      _s(startX + (cp1x - startX) * 0.4, startY + (cp1y - startY) * 0.4),
      _r(5),
      _p(_purpleFaint, opacity: 0.8),
    );
    canvas.drawCircle(
      _s(startX + (cp1x - startX) * 0.8, startY + (cp1y - startY) * 0.8),
      _r(4),
      _p(_purpleFaint, opacity: 0.7),
    );
    canvas.restore();
  }

  void _drawStar(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    Color color,
    double opacity,
  ) {
    final paint = _p(color, opacity: opacity);
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final angle = (i * math.pi / 5) - math.pi / 2;
      final radius = i.isEven ? r : r * 0.45;
      final x = cx * scale + math.cos(angle) * radius * scale;
      final y = cy * scale + math.sin(angle) * radius * scale;
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // SPARKLES
    _drawStar(canvas, 30, 78, 12, _yellow, sparkOpacity * 0.9);
    _drawStar(
      canvas,
      228,
      68,
      12,
      _coral,
      (sparkOpacity - 0.3).clamp(0, 1) * 0.85,
    );
    _drawStar(
      canvas,
      215,
      222,
      8,
      _mint,
      (sparkOpacity - 0.6).clamp(0, 1) * 0.9,
    );

    canvas.save();
    canvas.translate(0, floatOffset * scale);

    // TENTACLES (6)
    _drawTentacle(canvas, 72, 192, 50, 215, 55, 238, 49, 266, 0.0);
    _drawTentacle(canvas, 92, 198, 80, 225, 85, 245, 81, 268, 0.5);
    _drawTentacle(canvas, 112, 200, 108, 228, 112, 248, 109, 271, 1.0);
    _drawTentacle(canvas, 148, 200, 152, 228, 148, 248, 151, 271, 1.5);
    _drawTentacle(canvas, 168, 198, 180, 225, 175, 245, 179, 268, 2.0);
    _drawTentacle(canvas, 188, 192, 210, 215, 205, 238, 211, 266, 2.5);

    // BODY
    canvas.drawOval(
      Rect.fromCenter(center: _s(130, 155), width: _r(136), height: _r(116)),
      _p(_purpleLight),
    );
    // HEAD DOME
    canvas.drawOval(
      Rect.fromCenter(center: _s(130, 105), width: _r(112), height: _r(120)),
      _p(_purple),
    );
    // HIGHLIGHT
    canvas.drawOval(
      Rect.fromCenter(center: _s(112, 78), width: _r(40), height: _r(28)),
      _p(_purplePale, opacity: 0.35),
    );

    // HAT
    canvas.save();
    canvas.translate(_s(130, 52).dx, _s(130, 52).dy);
    canvas.rotate(hatAngle);
    canvas.translate(-_s(130, 52).dx, -_s(130, 52).dy);
    final hatRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(_s(88, 52).dx, _s(52, 52).dy, _r(84), _r(14)),
      Radius.circular(_r(5)),
    );
    canvas.drawRRect(hatRect, _p(_deepNavy));
    canvas.drawOval(
      Rect.fromCenter(center: _s(130, 52), width: _r(92), height: _r(16)),
      _p(_navy),
    );
    canvas.drawLine(
      _s(130, 44),
      _s(130, 30),
      _p(_yellow, strokeWidth: 3, style: PaintingStyle.stroke),
    );
    canvas.drawCircle(_s(130, 28), _r(6), _p(_yellow));
    canvas.restore();

    // BODY SPOTS
    canvas.drawOval(
      Rect.fromCenter(center: _s(108, 120), width: _r(22), height: _r(16)),
      _p(_purplePale, opacity: 0.45),
    );
    canvas.drawOval(
      Rect.fromCenter(center: _s(152, 115), width: _r(18), height: _r(12)),
      _p(_purpleFaint, opacity: 0.4),
    );
    canvas.drawOval(
      Rect.fromCenter(center: _s(138, 140), width: _r(14), height: _r(10)),
      _p(_purpleFaint, opacity: 0.35),
    );

    // MINI ARM LEFT (book)
    final armPath = Path()
      ..moveTo(_s(62, 135).dx, _s(62, 135).dy)
      ..quadraticBezierTo(
        _s(40, 122).dx,
        _s(40, 122).dy,
        _s(36, 108).dx,
        _s(36, 108).dy,
      );
    canvas.drawPath(
      armPath,
      _p(_purple, strokeWidth: 10, style: PaintingStyle.stroke),
    );
    final bookRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: _s(34, 105), width: _r(24), height: _r(20)),
      Radius.circular(_r(4)),
    );
    canvas.drawRRect(bookRect, _p(const Color(0xFFFDE68A)));
    canvas.drawRRect(
      bookRect,
      _p(const Color(0xFFF59E0B), style: PaintingStyle.stroke, strokeWidth: 2),
    );
    canvas.drawLine(
      _s(34, 95),
      _s(34, 115),
      _p(
        const Color(0xFFF59E0B),
        strokeWidth: 1.5,
        style: PaintingStyle.stroke,
      ),
    );

    // MINI ARM RIGHT (star)
    final armPath2 = Path()
      ..moveTo(_s(198, 135).dx, _s(198, 135).dy)
      ..quadraticBezierTo(
        _s(220, 122).dx,
        _s(220, 122).dy,
        _s(224, 108).dx,
        _s(224, 108).dy,
      );
    canvas.drawPath(
      armPath2,
      _p(_purple, strokeWidth: 10, style: PaintingStyle.stroke),
    );
    final triPath = Path()
      ..moveTo(_s(224, 95).dx, _s(224, 95).dy)
      ..lineTo(_s(236, 105).dx, _s(236, 105).dy)
      ..lineTo(_s(224, 115).dx, _s(224, 115).dy)
      ..close();
    canvas.drawPath(triPath, _p(_coral));

    // EYES
    // Left eye
    canvas.save();
    canvas.translate(_s(108, 128).dx, _s(108, 128).dy);
    canvas.scale(1, blinkScale);
    canvas.translate(-_s(108, 128).dx, -_s(108, 128).dy);
    canvas.drawCircle(_s(108, 128), _r(20), _p(Colors.white));
    canvas.drawCircle(_s(113, 124), _r(12), _p(_ink));
    canvas.drawCircle(_s(117, 120), _r(4.5), _p(Colors.white));
    canvas.drawOval(
      Rect.fromCenter(center: _s(108, 134), width: _r(10), height: _r(6)),
      _p(_purpleFaint, opacity: 0.5),
    );
    canvas.restore();
    // Right eye
    canvas.save();
    canvas.translate(_s(152, 128).dx, _s(152, 128).dy);
    canvas.scale(1, blinkScale);
    canvas.translate(-_s(152, 128).dx, -_s(152, 128).dy);
    canvas.drawCircle(_s(152, 128), _r(20), _p(Colors.white));
    canvas.drawCircle(_s(157, 124), _r(12), _p(_ink));
    canvas.drawCircle(_s(161, 120), _r(4.5), _p(Colors.white));
    canvas.drawOval(
      Rect.fromCenter(center: _s(152, 134), width: _r(10), height: _r(6)),
      _p(_purpleFaint, opacity: 0.5),
    );
    canvas.restore();

    // EYEBROWS
    final browPaint = _p(_navy, strokeWidth: 4, style: PaintingStyle.stroke);
    final browL = Path()
      ..moveTo(_s(92, 110).dx, _s(92, 110).dy)
      ..quadraticBezierTo(
        _s(108, 102).dx,
        _s(108, 102).dy,
        _s(122, 110).dx,
        _s(122, 110).dy,
      );
    canvas.drawPath(browL, browPaint);
    final browR = Path()
      ..moveTo(_s(138, 110).dx, _s(138, 110).dy)
      ..quadraticBezierTo(
        _s(152, 102).dx,
        _s(152, 102).dy,
        _s(168, 110).dx,
        _s(168, 110).dy,
      );
    canvas.drawPath(
      browR,
      _p(_navy, strokeWidth: 4.5, style: PaintingStyle.stroke),
    );

    // SMILE
    final smilePath = Path()
      ..moveTo(_s(106, 148).dx, _s(106, 148).dy)
      ..quadraticBezierTo(
        _s(130, 168).dx,
        _s(130, 168).dy,
        _s(154, 148).dx,
        _s(154, 148).dy,
      );
    canvas.drawPath(
      smilePath,
      _p(_navy, strokeWidth: 4, style: PaintingStyle.stroke),
    );

    // BLUSH
    canvas.drawOval(
      Rect.fromCenter(center: _s(88, 140), width: _r(22), height: _r(14)),
      _p(_pink, opacity: 0.5),
    );
    canvas.drawOval(
      Rect.fromCenter(center: _s(172, 140), width: _r(22), height: _r(14)),
      _p(_pink, opacity: 0.5),
    );

    // BELLY STAR
    _drawStar(canvas, 130, 160, 12, _yellow, 0.9);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_InkyPainter old) => true;
}
