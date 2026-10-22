import 'dart:math' as math;

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game_over_screen.dart';
import 'theme.dart';
import 'view_model.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  late final QuizViewModel viewModel = QuizViewModel(
    onGameOver: _handleGameOver,
  );

  // Diisi oleh OpenContainer; dipanggil saat kuis selesai.
  VoidCallback? _openGameOver;

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        final question = viewModel.currentQuestion;
        final completed =
            viewModel.answeredQuestionCount -
            (viewModel.didAnswerQuestion ? 0 : 1);

        return Scaffold(
          body: GradientBackground(
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    children: [
                      _Header(
                        progress: completed / viewModel.totalQuestions,
                        onClose: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(height: 8),
                      StatusBar(viewModel: viewModel),
                      const SizedBox(height: 16),
                      // Animasi pergantian soal: SharedAxis (horizontal).
                      PageTransitionSwitcher(
                        duration: const Duration(milliseconds: 550),
                        transitionBuilder: (child, primary, secondary) {
                          return SharedAxisTransition(
                            animation: primary,
                            secondaryAnimation: secondary,
                            transitionType: SharedAxisTransitionType.horizontal,
                            fillColor: Colors.transparent,
                            child: child,
                          );
                        },
                        // OpenContainer: kartu soal "mekar" menjadi
                        // GameOverScreen ketika soal terakhir selesai dijawab.
                        child: OpenContainer<void>(
                          key: ValueKey<int>(viewModel.answeredQuestionCount),
                          tappable: false,
                          transitionType: ContainerTransitionType.fadeThrough,
                          transitionDuration:
                              const Duration(milliseconds: 800),
                          closedElevation: 8,
                          closedColor: Colors.white,
                          closedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          middleColor: AppColors.magenta,
                          openColor: AppColors.deep,
                          openElevation: 0,
                          openBuilder: (context, close) => GameOverScreen(
                            score: viewModel.score,
                            total: viewModel.totalQuestions,
                            bestStreak: viewModel.bestStreak,
                          ),
                          closedBuilder: (context, openContainer) {
                            _openGameOver = openContainer;
                            return QuestionCard(
                              number: viewModel.answeredQuestionCount,
                              question: question?.question,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      AnswerCards(
                        questionNumber: viewModel.answeredQuestionCount,
                        answers: question?.possibleAnswers ?? const <String>[],
                        selectedAnswer: viewModel.selectedAnswer,
                        correctAnswer: viewModel.didAnswerQuestion
                            ? question?.correctAnswer
                            : null,
                        onTapped: _onAnswerTapped,
                      ),
                      const SizedBox(height: 8),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.topCenter,
                        child: viewModel.didAnswerQuestion
                            ? FeedbackCard(
                                key: ValueKey<int>(
                                  viewModel.answeredQuestionCount,
                                ),
                                correct: viewModel.lastAnswerCorrect,
                                explanation: question?.explanation ?? '',
                                streak: viewModel.streak,
                                isLast: !viewModel.hasNextQuestion,
                                onNext: viewModel.hasNextQuestion
                                    ? viewModel.getNextQuestion
                                    : null,
                              )
                            : const SizedBox(width: double.infinity),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onAnswerTapped(int index) {
    if (viewModel.didAnswerQuestion) return;
    viewModel.checkAnswer(index);
    if (viewModel.lastAnswerCorrect) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  void _handleGameOver() {
    // Beri waktu untuk melihat animasi jawaban terakhir, lalu "mekarkan"
    // kartu soal menjadi layar GameOverScreen.
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      _openGameOver?.call();
    });
  }
}

/// Tombol tutup + progress bar yang terisi dengan animasi halus.
class _Header extends StatelessWidget {
  final double progress;
  final VoidCallback onClose;

  const _Header({required this.progress, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close_rounded, color: Colors.white),
        ),
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 12,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.cyan,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}

class QuestionCard extends StatelessWidget {
  final String? question;
  final int number;

  const QuestionCard({required this.question, required this.number, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.psychology_alt_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Pertanyaan $number',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                question ?? '',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum AnswerState { idle, correct, wrong, dimmed }

class AnswerCards extends StatelessWidget {
  final List<String> answers;
  final ValueChanged<int> onTapped;
  final int? correctAnswer;
  final int? selectedAnswer;
  final int questionNumber;

  const AnswerCards({
    required this.answers,
    required this.onTapped,
    required this.correctAnswer,
    required this.selectedAnswer,
    required this.questionNumber,
    super.key,
  });

  AnswerState _stateFor(int index) {
    if (correctAnswer == null) return AnswerState.idle;
    if (index == correctAnswer) return AnswerState.correct;
    if (index == selectedAnswer) return AnswerState.wrong;
    return AnswerState.dimmed;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(answers.length, (index) {
        // Kartu berbalik (rotateX) tiap soal berganti, bergiliran per kartu.
        return CardFlipEffect(
          delayAmount: index.toDouble() / 2,
          child: AnswerCard(
            key: ValueKey<String>('$questionNumber-$index'),
            index: index,
            text: answers[index],
            state: _stateFor(index),
            onTap: () => onTapped(index),
          ),
        );
      }),
    );
  }
}

/// Langkah 3: efek kartu dibalik yang dikontrol lewat AnimationController.
/// Animasi berjalan saat `key` child berubah; child lama disimpan di
/// `_previousChild` untuk ditampilkan pada separuh pertama putaran.
class CardFlipEffect extends StatefulWidget {
  final double delayAmount;
  final Widget child;

  const CardFlipEffect({
    required this.delayAmount,
    required this.child,
    super.key,
  });

  @override
  State<CardFlipEffect> createState() => _CardFlipEffectState();
}

class _CardFlipEffectState extends State<CardFlipEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animationWithDelay;
  late Widget _previousChild;

  @override
  void initState() {
    super.initState();
    _previousChild = widget.child;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    // Jeda antarkartu memakai TweenSequence (bukan Future.delayed)
    // supaya tetap terlihat di DevTools.
    _animationWithDelay = TweenSequence<double>([
      if (widget.delayAmount > 0)
        TweenSequenceItem(
          tween: ConstantTween<double>(0.0),
          weight: widget.delayAmount,
        ),
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 1.0),
    ]).animate(_animationController);
  }

  @override
  void didUpdateWidget(covariant CardFlipEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child.key != widget.child.key) {
      _previousChild = oldWidget.child;
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, _) {
        final animating = _animationController.isAnimating;
        final value = animating ? _animationWithDelay.value : 0.0;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspektif 3D
            ..rotateX(value * math.pi),
          child: animating
              ? (value < 0.5
                    ? _previousChild
                    : Transform.flip(flipY: true, child: widget.child))
              : widget.child,
        );
      },
    );
  }
}

class AnswerCard extends StatefulWidget {
  final int index;
  final String text;
  final AnswerState state;
  final VoidCallback onTap;

  const AnswerCard({
    required this.index,
    required this.text,
    required this.state,
    required this.onTap,
    super.key,
  });

  @override
  State<AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends State<AnswerCard>
    with SingleTickerProviderStateMixin {
  // Animasi getar saat jawaban salah.
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  @override
  void didUpdateWidget(covariant AnswerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == AnswerState.wrong &&
        oldWidget.state != AnswerState.wrong) {
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color border;
    switch (widget.state) {
      case AnswerState.correct:
        background = AppColors.mintBg;
        border = AppColors.mint;
        break;
      case AnswerState.wrong:
        background = AppColors.coralBg;
        border = AppColors.coral;
        break;
      case AnswerState.idle:
      case AnswerState.dimmed:
        background = Colors.white;
        border = Colors.transparent;
        break;
    }

    final Widget trailing;
    if (widget.state == AnswerState.correct) {
      trailing = const Icon(
        Icons.check_circle_rounded,
        key: ValueKey('correct'),
        color: AppColors.mint,
      );
    } else if (widget.state == AnswerState.wrong) {
      trailing = const Icon(
        Icons.cancel_rounded,
        key: ValueKey('wrong'),
        color: AppColors.coral,
      );
    } else {
      trailing = const SizedBox(key: ValueKey('none'), width: 24, height: 24);
    }

    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) {
        final dx = math.sin(_shake.value * math.pi * 6) * 10 * (1 - _shake.value);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: widget.state == AnswerState.dimmed ? 0.55 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.12),
                      ),
                      child: Text(
                        String.fromCharCode(65 + widget.index),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.text,
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 450),
                      switchInCurve: Curves.elasticOut,
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: trailing,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Panel umpan balik: muncul dengan fade + slide, berisi penjelasan & tombol lanjut.
class FeedbackCard extends StatelessWidget {
  final bool correct;
  final String explanation;
  final int streak;
  final bool isLast;
  final VoidCallback? onNext;

  const FeedbackCard({
    required this.correct,
    required this.explanation,
    required this.streak,
    required this.isLast,
    required this.onNext,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final accent = correct ? AppColors.mint : AppColors.coral;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent, width: 2.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  correct ? Icons.celebration_rounded : Icons.lightbulb_rounded,
                  color: accent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    correct ? 'Benar sekali!' : 'Belum tepat, tapi tenang!',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                ),
                if (correct && streak >= 2) _StreakBadge(streak: streak),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              explanation,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: AppColors.ink),
            ),
            const SizedBox(height: 12),
            if (isLast)
              Row(
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Menghitung hasil akhir...',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onNext,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Soal Berikutnya'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Lencana "beruntun" yang muncul membal (elasticOut).
class _StreakBadge extends StatelessWidget {
  final int streak;

  const _StreakBadge({required this.streak});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.accent, AppColors.magenta],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          '🔥 x$streak beruntun',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class StatusBar extends StatelessWidget {
  final QuizViewModel viewModel;

  const StatusBar({required this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Soal ${viewModel.answeredQuestionCount} / ${viewModel.totalQuestions}',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 0,
                    children: List.generate(viewModel.totalQuestions, (i) {
                      return AnimatedScoreIcon(isActive: i < viewModel.score);
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _ScoreBadge(score: viewModel.score),
          ],
        ),
      ),
    );
  }
}

/// Langkah 1 (animasi implisit): ikon petir pengganti bintang.
/// AnimatedScale mengatur ukuran, TweenAnimationBuilder + ColorTween mengatur warna.
class AnimatedScoreIcon extends StatelessWidget {
  final bool isActive;

  const AnimatedScoreIcon({super.key, required this.isActive});

  static const Duration _duration = Duration(milliseconds: 1000);
  static const Curve _curve = Curves.elasticOut;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isActive ? 1.0 : 0.5,
      curve: _curve,
      duration: _duration,
      child: TweenAnimationBuilder<Color?>(
        curve: _curve,
        duration: _duration,
        tween: ColorTween(
          begin: AppColors.emptyBolt,
          end: isActive ? AppColors.accent : AppColors.emptyBolt,
        ),
        builder: (context, value, child) {
          return Icon(Icons.bolt_rounded, size: 34, color: value);
        },
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;

  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    // Key berubah saat skor berubah, sehingga efek "pop" diputar ulang.
    return TweenAnimationBuilder<double>(
      key: ValueKey<int>(score),
      tween: Tween<double>(begin: score == 0 ? 1.0 : 1.35, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.accent, AppColors.magenta],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bolt_rounded, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              '$score',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
