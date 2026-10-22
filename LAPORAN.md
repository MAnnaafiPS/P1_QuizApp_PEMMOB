# Laporan Praktikum 1 – Pemrograman Mobile
**Aplikasi: Kuis Animasi Flutter (modifikasi starter code + Advanced Flutter Animations codelab)**

## 1. Dokumentasi
Tempel minimal 2 screenshot (disarankan 4-5), contoh:
1. Beranda (roket melayang + tombol berdenyut)
2. Halaman soal saat kartu jawaban berbalik (flip)
3. Jawaban salah (kartu bergetar) & panel penjelasan
4. Halaman hasil (cincin skor + confetti)

## 2. Langkah-langkah
1. Menjalankan starter code: `flutter pub get` lalu `flutter run`.
2. Mengikuti codelab (Langkah 1-4: animasi implisit, `AnimatedSwitcher` → `PageTransitionSwitcher`, `CardFlipEffect`, transisi navigasi + `OpenContainer`) Advanced Flutter Animations dan menerapkannya dengan tema sendiri.
3. Mengganti warna & ikon (tanpa biru/kuning dan tanpa bintang):
   | Elemen | Codelab | Aplikasi ini |
   |---|---|---|
   | Warna utama | Biru | Violet - magenta (`AppColors`) |
   | Ikon skor | Bintang kuning | Petir `Icons.bolt_rounded` pink |
   | Ikon beranda | Emoji pensil | Roket `Icons.rocket_launch_rounded` |
4. Animasi yang diterapkan:
   | Animasi | Teknik | File |
   |---|---|---|
   | Transisi halaman | `SharedAxisTransition` (scaled), `FadeThroughTransition` | `routes.dart` |
   | Transisi per platform | `pageTransitionsTheme` (`PredictiveBack…`, `FadeThrough…`) | `main.dart` |
   | Pergantian soal | `PageTransitionSwitcher` + `SharedAxisTransition` | `question_screen.dart` |
   | Kartu jawaban berbalik | `CardFlipEffect`: `AnimationController` + `TweenSequence` (jeda per kartu) + `Transform` rotateX | `question_screen.dart` |
   | Game Over | `OpenContainer`: kartu soal "mekar" menjadi `GameOverScreen` | `question_screen.dart`, `game_over_screen.dart` |
   | Warna jawaban benar/salah | `AnimatedContainer`, `AnimatedOpacity` | `AnswerCard` |
   | Ikon skor (petir) | Implisit: `AnimatedScale` + `TweenAnimationBuilder` + `ColorTween` | `AnimatedScoreIcon` |
   | Progress bar | `TweenAnimationBuilder` | `_Header` |
5. Animasi tambahan di luar codelab:
   - Kartu jawaban **bergetar** saat salah (`AnimationController` + `sin`).
   - **Lencana beruntun** (streak) muncul membal dengan `Curves.elasticOut`.
   - Panel penjelasan muncul fade + slide, area diperluas dengan `AnimatedSize`.
   - Beranda: roket melayang, bubble bergerak, tombol berdenyut (controller `repeat(reverse: true)`).
   - Halaman hasil: cincin skor menghitung naik + **confetti** (`CustomPainter`).

## 3. Link GitHub
(isi link repository public kamu di sini)
