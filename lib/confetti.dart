import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';

class _Particle {
  final double x; // posisi horizontal (0..1)
  final double delay; // jeda mulai (0..0.5)
  final double drift; // simpangan kiri-kanan
  final double freq; // frekuensi goyangan
  final double size;
  final double rotation;
  final double spin;
  final Color color;
  final bool isCircle;

  _Particle({
    required this.x,
    required this.delay,
    required this.drift,
    required this.freq,
    required this.size,
    required this.rotation,
    required this.spin,
    required this.color,
    required this.isCircle,
  });

  factory _Particle.random(math.Random r) {
    const colors = [
      AppColors.accent,
      AppColors.cyan,
      AppColors.mint,
      Colors.white,
      Color(0xFFE879F9),
      Color(0xFFA78BFA),
    ];
    return _Particle(
      x: r.nextDouble(),
      delay: r.nextDouble() * 0.5,
      drift: 10 + r.nextDouble() * 30,
      freq: 1 + r.nextDouble() * 3,
      size: 6 + r.nextDouble() * 8,
      rotation: r.nextDouble() * math.pi * 2,
      spin: (r.nextDouble() - 0.5) * math.pi * 8,
      color: colors[r.nextInt(colors.length)],
      isCircle: r.nextBool(),
    );
  }
}

/// Animasi kustom: hujan confetti memakai AnimationController + CustomPainter.
class ConfettiOverlay extends StatefulWidget {
  final int count;

  const ConfettiOverlay({this.count = 70, super.key});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  )..forward();

  late final List<_Particle> _particles = () {
    final random = math.Random();
    return List.generate(widget.count, (_) => _Particle.random(random));
  }();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size.infinite,
            painter: _ConfettiPainter(_particles, _controller.value),
          );
        },
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ConfettiPainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = (progress - p.delay) / (1 - p.delay);
      if (t <= 0 || t >= 1) continue;

      final y = -p.size + t * (size.height + p.size * 2);
      final x = p.x * size.width + math.sin(t * p.freq * math.pi * 2) * p.drift;
      final opacity = t > 0.85 ? (1 - t) / 0.15 : 1.0;

      final paint = Paint()..color = p.color.withValues(alpha: opacity);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + t * p.spin);
      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.6,
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
