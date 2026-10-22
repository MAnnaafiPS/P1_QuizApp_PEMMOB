import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'model.dart';

class QuizViewModel extends ChangeNotifier {
  final QuestionBank _questionBank = QuestionBank();
  final VoidCallback onGameOver;
  late final int totalQuestions;
  Question? currentQuestion;
  int answeredQuestionCount = 0;
  int score = 0;
  int streak = 0;
  int bestStreak = 0;
  int? selectedAnswer;
  bool didAnswerQuestion = false;
  bool get hasNextQuestion => answeredQuestionCount < totalQuestions;
  bool get lastAnswerCorrect =>
      didAnswerQuestion && selectedAnswer == currentQuestion?.correctAnswer;

  QuizViewModel({required this.onGameOver}) {
    totalQuestions = _questionBank.remainingQuestions;
    getNextQuestion();
  }

  void getNextQuestion() {
    if (_questionBank.hasNextQuestion) {
      currentQuestion = _questionBank.getRandomQuestion();
      answeredQuestionCount++;
    }

    didAnswerQuestion = false;
    selectedAnswer = null;

    notifyListeners();
  }

  void checkAnswer(int selectedIndex) {
    // Satu soal hanya bisa dijawab satu kali.
    if (didAnswerQuestion) {
      return;
    }

    selectedAnswer = selectedIndex;
    didAnswerQuestion = true;

    if (currentQuestion?.correctAnswer == selectedIndex) {
      score++;
      streak++;
      bestStreak = math.max(bestStreak, streak);
    } else {
      streak = 0;
    }

    if (!_questionBank.hasNextQuestion) {
      onGameOver();
    }

    notifyListeners();
  }
}
