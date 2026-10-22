import 'dart:math' as math;

class Question {
  final String question;
  final List<String> possibleAnswers;
  final int correctAnswer;
  final String explanation;
  Question(
    this.question,
    this.possibleAnswers,
    this.correctAnswer,
    this.explanation,
  );
}

class QuestionBank {
  final List<Question> _questions = _createQuestions();

  bool get hasNextQuestion => _questions.isNotEmpty;
  int get remainingQuestions => _questions.length;

  Question? getRandomQuestion() {
    if (_questions.isEmpty) {
      return null;
    }

    var i = math.Random().nextInt(_questions.length);
    var question = _questions[i];

    _questions.removeAt(i);
    return question;
  }
}

List<Question> _createQuestions() {
  return [
    Question(
      'Kelas apa yang dipakai untuk mengontrol durasi dan status sebuah animasi eksplisit di Flutter?',
      ['Tween', 'AnimationController', 'Curve', 'Ticker'],
      1,
      'AnimationController menghasilkan nilai 0.0 sampai 1.0 selama durasi tertentu dan bisa di-forward, reverse, atau repeat.',
    ),
    Question(
      'Widget mana yang membangun ulang child-nya setiap kali nilai animasi berubah?',
      ['AnimatedBuilder', 'AnimatedSwitcher', 'Hero', 'SafeArea'],
      0,
      'AnimatedBuilder mendengarkan sebuah Animation dan menjalankan builder-nya pada setiap perubahan nilai.',
    ),
    Question(
      'Mixin apa yang dibutuhkan State agar bisa memakai AnimationController dengan vsync: this?',
      [
        'ChangeNotifier',
        'AutomaticKeepAliveClientMixin',
        'SingleTickerProviderStateMixin',
        'WidgetsBindingObserver',
      ],
      2,
      'SingleTickerProviderStateMixin menyediakan Ticker yang dipakai controller untuk sinkron dengan frame layar.',
    ),
    Question(
      'Widget bawaan mana yang otomatis menganimasikan transisi saat child-nya diganti?',
      ['Stack', 'Expanded', 'Positioned', 'AnimatedSwitcher'],
      3,
      'AnimatedSwitcher melakukan cross-fade (atau transisi kustom) antara child lama dan child baru yang punya key berbeda.',
    ),
    Question(
      'Package mana yang menyediakan SharedAxisTransition dan FadeThroughTransition?',
      ['provider', 'animations', 'http', 'path'],
      1,
      'Package animations berisi pola transisi Material Motion seperti SharedAxis, FadeThrough, dan Container Transform.',
    ),
    Question(
      'Apa fungsi Curve pada sebuah animasi?',
      [
        'Mengatur warna animasi',
        'Menentukan ukuran layar',
        'Mengatur laju perubahan nilai animasi terhadap waktu',
        'Menyimpan state widget',
      ],
      2,
      'Curve mengubah progres linear menjadi pola gerak tertentu, misalnya easeOut, bounceOut, atau elasticOut.',
    ),
    Question(
      'Widget mana yang menganimasikan perubahan properti seperti warna dan ukuran secara implisit?',
      ['AnimatedContainer', 'Scaffold', 'ListView', 'FutureBuilder'],
      0,
      'Widget implisit seperti AnimatedContainer otomatis beranimasi ketika nilai propertinya berubah, tanpa controller.',
    ),
    Question(
      'Method apa pada AnimationController untuk menjalankan animasi maju dari awal?',
      ['dispose()', 'reset()', 'stop()', 'forward()'],
      3,
      'forward() menjalankan animasi dari nilai saat ini menuju upperBound; forward(from: 0) memulai dari awal.',
    ),
  ];
}
