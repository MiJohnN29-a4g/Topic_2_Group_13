// Script seed dữ liệu phim lên Firestore
// Chạy: dart bin/seed_movies.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:movie_app/firebase_options.dart';
import 'package:movie_app/utils/movie_seeder.dart';

void main() async {
  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print('🎬 Movie Seeder - FlixFilm');
  print('=========================\n');

  final seeder = MovieSeeder();

  // Chọn chế độ
  print('Chọn chế độ:');
  print('  1. Seed tất cả phim (nếu chưa tồn tại)');
  print('  2. Xóa tất cả và seed lại từ đầu');
  print('  3. Thoát\n');

  // Tự động chạy seed mode 1
  print('📥 Đang seed phim lên Firestore...\n');
  await seeder.seedAllMovies();

  print('\n✅ Hoàn thành!');
}
