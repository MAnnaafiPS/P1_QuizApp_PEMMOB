import 'package:flutter/material.dart';

import 'confetti.dart';
import 'question_screen.dart';
import 'routes.dart';
import 'theme.dart';

class GameOverScreen extends StatefulWidget {
  final int score;
  final int total;
  final int bestStreak;

  const GameOverScreen({
    required this.score,
    required this.total,
    required this.bestStreak,
    super.key,
  });

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..forward();

  late final AnimationController _glow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  late final Animation<double> _trophyScale = CurvedAnimation(
    parent: _entrance,
    curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
  );
  late final Animation<double> _titleIn = staggered(_entrance, 0.12, 0.35);
  late final Animation<double> _ringProgress = CurvedAnimation(
    parent: _entrance,
    curve: const Interval(0.25, 0.75, curve: Curves.easeOutCubic),
  );
  late final Animation<double> _messageIn = staggered(_entrance, 0.6, 0.8);
  late final Animation<double> _chipsIn = staggered(_entrance, 0.68, 0.88);
  late final Animation<double> _buttonsIn = staggered(_entrance, 0.8, 1.0);

  double get _ratio => widget.total == 0 ? 0 : widget.score / widget.total;

  String get _message {
    if (_ratio == 1) return 'Sempurna! Kamu jagoan animasi Flutter 🚀';
    if (_ratio >= 0.75) return 'Keren! Hampir sempurna, pertahankan!';
    if (_ratio >= 0.5) return 'Lumayan! Terus berlatih ya 💪';
    return 'Jangan menyerah, coba lagi pasti lebih baik!';
  }

  @override
  void dispose() {
    _entrance.dispose();
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: GradientBackground(
        child: Stack(
          children: [
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: _trophyScale,
                        child: _buildTrophy(),
                      ),
                      const SizedBox(height: 20),
                      Reveal(
                        animation: _titleIn,
                        child: Text(
                          'Kuis Selesai!',
                          style: textTheme.headlineMedium!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildScoreRing(textTheme),
                      const SizedBox(height: 20),
                      Reveal(
                        animation: _messageIn,
                        child: Text(
                          _message,
                          textAlign: TextAlign.center,
                          style: textTheme.titleMedium!.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Reveal(
                        animation: _chipsIn,
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _StatChip(
                              icon: Icons.check_circle_rounded,
                              label: 'Benar',
                              value: '${widget.score}',
                            ),
                            _StatChip(
                              icon: Icons.cancel_rounded,
                              label: 'Salah',
                              value: '${widget.total - widget.score}',
                            ),
                            _StatChip(
                              icon: Icons.local_fire_department_rounded,
                              label: 'Beruntun terbaik',
                              value: 'x${widget.bestStreak}',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Reveal(
                        animation: _buttonsIn,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: () {
                                    // Buang QuestionScreen lama + rute OpenContainer.
                                    Navigator.of(context).pushAndRemoveUntil(
                                      sharedAxisRoute(const QuestionScreen()),
                                      (route) => route.isFirst,
                                    );
                                  },
                                  icon: const Icon(Icons.replay_rounded),
                                  label: const Text('Main Lagi'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.accent,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).popUntil((route) => route.isFirst);
                                  },
                                  icon: const Icon(Icons.home_rounded),
                                  label: const Text('Kembali ke Beranda'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white54),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Animasi tambahan: hujan confetti jika skor >= 50%.
            if (_ratio >= 0.5) const Positioned.fill(child: ConfettiOverlay()),
          ],
        ),
      ),
    );
  }

  Widget _buildTrophy() {
    return AnimatedBuilder(
      animation: _glow,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_glow.value);
        return Transform.translate(
          offset: Offset(0, -8 * t),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.accent, AppColors.magenta],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.35 + 0.3 * t),
                  blurRadius: 24 + 24 * t,
                  spreadRadius: 2 + 6 * t,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: const Icon(Icons.emoji_events_rounded, size: 64, color: Colors.white),
    );
  }

  Widget _buildScoreRing(TextTheme textTheme) {
    return AnimatedBuilder(
      animation: _ringProgress,
      builder: (context, child) {
        final p = _ringProgress.value;
        return SizedBox(
          width: 180,
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: p * _ratio,
                  strokeWidth: 14,
                  strokeCap: StrokeCap.round,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.cyan,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(p * widget.score).round()}',
                    style: textTheme.displayMedium!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'dari ${widget.total} soal',
                    style: textTheme.bodyMedium!.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.cyan, size: 20),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
