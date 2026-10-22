import 'package:flutter/material.dart';

/// Palet warna kustom (berbeda dari codelab: tanpa biru & kuning).
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF7C3AED); // violet
  static const Color deep = Color(0xFF2E1065); // ungu tua
  static const Color mid = Color(0xFF5B21B6);
  static const Color magenta = Color(0xFFC026D3);
  static const Color accent = Color(0xFFFF4D8D); // pink
  static const Color cyan = Color(0xFF22D3EE);
  static const Color mint = Color(0xFF10B981);
  static const Color mintBg = Color(0xFFD1FAE5);
  static const Color coral = Color(0xFFF43F5E);
  static const Color coralBg = Color(0xFFFFE4E8);
  static const Color ink = Color(0xFF1E1B4B);
  static const Color emptyBolt = Color(0xFFE5E7EB);

  static const LinearGradient background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deep, mid, magenta],
  );
}

/// Latar gradient untuk semua layar.
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.background),
        child: child,
      ),
    );
  }
}

/// Membuat animasi bertahap (staggered) dari satu controller.
Animation<double> staggered(
  AnimationController controller,
  double begin,
  double end, [
  Curve curve = Curves.easeOutCubic,
]) {
  return CurvedAnimation(
    parent: controller,
    curve: Interval(begin, end, curve: curve),
  );
}

/// Muncul dengan efek fade + slide naik.
class Reveal extends StatelessWidget {
  final Animation<double> animation;
  final Offset offset;
  final Widget child;

  const Reveal({
    required this.animation,
    required this.child,
    this.offset = const Offset(0, 0.25),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: offset, end: Offset.zero)
            .animate(animation),
        child: child,
      ),
    );
  }
}
