import 'package:flutter/material.dart';

import 'model.dart';
import 'question_screen.dart';
import 'routes.dart';
import 'theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Animasi masuk (sekali jalan, bertahap).
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..forward();

  // Animasi looping: roket melayang, bubble bergerak, tombol berdenyut.
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);

  late final Animation<double> _iconScale = CurvedAnimation(
    parent: _entrance,
    curve: const Interval(0.0, 0.45, curve: Curves.elasticOut),
  );
  late final Animation<double> _titleIn = staggered(_entrance, 0.25, 0.6);
  late final Animation<double> _subtitleIn = staggered(_entrance, 0.4, 0.75);
  late final Animation<double> _chipsIn = staggered(_entrance, 0.5, 0.85);
  late final Animation<double> _buttonScale = CurvedAnimation(
    parent: _entrance,
    curve: const Interval(0.65, 1.0, curve: Curves.easeOutBack),
  );

  late final int _total = QuestionBank().remainingQuestions;

  @override
  void dispose() {
    _entrance.dispose();
    _float.dispose();
    super.dispose();
  }

  void _startGame() {
    Navigator.of(context).push(sharedAxisRoute(const QuestionScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: GradientBackground(
        child: Stack(
          children: [
            Positioned.fill(child: _buildBubbles()),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: _iconScale,
                        child: _buildFloatingRocket(),
                      ),
                      const SizedBox(height: 28),
                      Reveal(
                        animation: _titleIn,
                        child: Text(
                          'Kuis Animasi\nFlutter',
                          textAlign: TextAlign.center,
                          style: textTheme.displaySmall!.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Reveal(
                        animation: _subtitleIn,
                        child: Text(
                          'Uji pemahamanmu tentang animasi di Flutter!',
                          textAlign: TextAlign.center,
                          style: textTheme.titleMedium!.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Reveal(
                        animation: _chipsIn,
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _InfoChip(
                              icon: Icons.quiz_rounded,
                              label: '$_total Soal',
                            ),
                            const _InfoChip(
                              icon: Icons.bolt_rounded,
                              label: 'Skor & Beruntun',
                            ),
                            const _InfoChip(
                              icon: Icons.animation_rounded,
                              label: 'Penuh Animasi',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),
                      ScaleTransition(
                        scale: _buttonScale,
                        child: _buildPulsingButton(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingRocket() {
    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_float.value);
        return Transform.translate(
          offset: Offset(0, -14 * t),
          child: Transform.rotate(angle: -0.12 + 0.24 * t, child: child),
        );
      },
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.accent, AppColors.magenta],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.5),
              blurRadius: 40,
              spreadRadius: 4,
            ),
          ],
        ),
        child: const Icon(
          Icons.rocket_launch_rounded,
          size: 88,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPulsingButton() {
    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_float.value);
        return Transform.scale(
          scale: 1 + 0.04 * t,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cyan.withValues(alpha: 0.25 + 0.25 * t),
                  blurRadius: 16 + 16 * t,
                  spreadRadius: 1 + 3 * t,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: ElevatedButton.icon(
        onPressed: _startGame,
        icon: const Icon(Icons.play_arrow_rounded, size: 30),
        label: const Text('Mulai Main'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.deep,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          shape: const StadiumBorder(),
        ),
      ),
    );
  }

  Widget _buildBubbles() {
    Widget circle(double size, double alpha) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: alpha),
        ),
      );
    }

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _float,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(_float.value);
          return Stack(
            children: [
              Positioned(left: -50, top: 70 + 30 * t, child: circle(170, 0.08)),
              Positioned(
                right: -30,
                top: 240 - 40 * t,
                child: circle(110, 0.10),
              ),
              Positioned(
                left: 40,
                bottom: 50 + 25 * t,
                child: circle(90, 0.07),
              ),
              Positioned(
                right: 60,
                bottom: 120 - 20 * t,
                child: circle(50, 0.12),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.cyan),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
