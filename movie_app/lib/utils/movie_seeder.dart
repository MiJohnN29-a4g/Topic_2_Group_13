import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/movie_data.dart';
import '../models/movie.dart';

/// Script seed dữ liệu phim lên Firestore
/// Chạy script này một lần để đẩy 12 phim từ movie_data.dart lên Firebase
class MovieSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'movies';

  /// Seed tất cả phim lên Firestore
  Future<void> seedAllMovies() async {
    try {
      print('🎬 Bắt đầu seed ${movies.length} phim lên Firestore...');

      for (final movie in movies) {
        await _addMovieIfNotExists(movie);
      }

      print('✅ Seed thành công ${movies.length} phim!');
    } catch (e) {
      print('❌ Lỗi khi seed: $e');
      rethrow;
    }
  }

  /// Thêm phim nếu chưa tồn tại
  Future<void> _addMovieIfNotExists(Movie movie) async {
    final docRef = _firestore.collection(_collection).doc('${movie.id}');
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set(movie.toJson());
      print('  ✓ Đã thêm: ${movie.title}');
    } else {
      print('  → Đã tồn tại: ${movie.title}');
    }
  }

  /// Xóa tất cả phim (dùng để reset)
  Future<void> clearAllMovies() async {
    try {
      print('🗑️ Đang xóa tất cả phim...');

      final snapshot = await _firestore.collection(_collection).get();
      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ Đã xóa ${snapshot.docs.length} phim!');
    } catch (e) {
      print('❌ Lỗi khi xóa: $e');
      rethrow;
    }
  }

  /// Reset và seed lại từ đầu
  Future<void> resetAndSeed() async {
    await clearAllMovies();
    await seedAllMovies();
  }
}
