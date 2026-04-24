import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import '../data/movie_data.dart';

class MovieRepository {
  FirebaseFirestore? _firestore;
  bool _isAvailable = false;
  final String _collection = 'movies';

  MovieRepository() {
    try {
      if (FirebaseFirestore.instance != null) {
        _firestore = FirebaseFirestore.instance;
        _isAvailable = true;
      }
    } catch (e) {
      _firestore = null;
      _isAvailable = false;
    }
  }

  /// Upload toàn bộ phim từ movie_data.dart lên Firestore (chỉ dùng 1 lần)
  Future<void> seedMovies() async {
    if (!_isAvailable || _firestore == null) return;

    const batchSize = 400;
    for (int i = 0; i < movies.length; i += batchSize) {
      final batch = _firestore!.batch();
      final chunk = movies.sublist(i, (i + batchSize).clamp(0, movies.length));
      for (final movie in chunk) {
        final ref = _firestore!.collection(_collection).doc(movie.id.toString());
        batch.set(ref, movie.toJson());
      }
      await batch.commit();
    }
    debugPrint('✅ Seeded ${movies.length} movies to Firestore');
  }

  /// Lấy danh sách tất cả phim
  /// Nếu Firestore không khả dụng hoặc trống, trả về data hardcoded
  Stream<List<Movie>> getMoviesStream() async* {
    if (!_isAvailable || _firestore == null) {
      yield movies;
      return;
    }

    try {
      yield* _firestore!.collection(_collection).snapshots().map((snapshot) {
        if (snapshot.docs.isEmpty) return movies;
        return snapshot.docs
            .map((doc) => Movie.fromJson(doc.data(), doc.id))
            .toList();
      });
    } catch (error) {
      debugPrint('Firestore error: $error');
      yield movies;
    }
  }

  /// Lấy danh sách tất cả phim (one-time)
  Future<List<Movie>> getMovies() async {
    if (!_isAvailable || _firestore == null) {
      return movies;
    }

    try {
      final snapshot = await _firestore!.collection(_collection).get();
      if (snapshot.docs.isEmpty) return movies;
      return snapshot.docs
          .map((doc) => Movie.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Firestore error: $e');
      return movies;
    }
  }

  /// Lấy phim theo ID
  Future<Movie?> getMovieById(String id) async {
    if (!_isAvailable || _firestore == null) {
      return movies.firstWhere((m) => m.id.toString() == id, orElse: () => movies.first);
    }

    try {
      final doc = await _firestore!.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Movie.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Firestore error: $e');
      return movies.firstWhere((m) => m.id.toString() == id, orElse: () => movies.first);
    }
  }

  /// Tìm kiếm phim theo tên, thể loại, diễn viên, đạo diễn
  Future<List<Movie>> searchMovies(String query) async {
    List<Movie> allMovies;

    if (!_isAvailable || _firestore == null) {
      allMovies = movies;
    } else {
      try {
        final snapshot = await _firestore!.collection(_collection).get();
        allMovies = snapshot.docs.isEmpty
            ? movies
            : snapshot.docs
            .map((doc) => Movie.fromJson(doc.data(), doc.id))
            .toList();
      } catch (e) {
        debugPrint('Firestore error: $e');
        allMovies = movies;
      }
    }

    if (query.isEmpty) {
      return [];
    }

    final lowerQuery = query.toLowerCase();
    return allMovies
        .where((movie) =>
    movie.title.toLowerCase().contains(lowerQuery) ||
        movie.genre.toLowerCase().contains(lowerQuery) ||
        movie.year.contains(query) ||
        (movie.director?.toLowerCase().contains(lowerQuery) ?? false) ||
        (movie.cast?.any((c) => c.toLowerCase().contains(lowerQuery)) ?? false))
        .toList();
  }

  /// Lấy phim theo thể loại
  Future<List<Movie>> getMoviesByGenre(String genre) async {
    List<Movie> allMovies;

    if (!_isAvailable || _firestore == null) {
      allMovies = movies;
    } else {
      try {
        final snapshot = await _firestore!.collection(_collection).get();
        allMovies = snapshot.docs.isEmpty
            ? movies
            : snapshot.docs
            .map((doc) => Movie.fromJson(doc.data(), doc.id))
            .toList();
      } catch (e) {
        debugPrint('Firestore error: $e');
        allMovies = movies;
      }
    }

    return allMovies.where((movie) => movie.genre.contains(genre)).toList();
  }

  /// Thêm phim mới (chỉ dành cho admin)
  Future<void> addMovie(Movie movie) async {
    if (_isAvailable && _firestore != null) {
      await _firestore!.collection(_collection).add(movie.toJson());
    }
  }

  /// Cập nhật phim
  Future<void> updateMovie(String id, Movie movie) async {
    if (_isAvailable && _firestore != null) {
      await _firestore!.collection(_collection).doc(id).update(movie.toJson());
    }
  }

  /// Xóa phim
  Future<void> deleteMovie(String id) async {
    if (_isAvailable && _firestore != null) {
      await _firestore!.collection(_collection).doc(id).delete();
    }
  }
}