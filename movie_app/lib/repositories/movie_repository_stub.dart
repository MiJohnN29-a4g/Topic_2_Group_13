import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import '../data/movie_data.dart';

class MovieRepository {
  final FirebaseFirestore? _firestore;

  MovieRepository({FirebaseFirestore? firestore}) : _firestore = firestore;

  /// Lấy danh sách tất cả phim
  /// Nếu Firestore không khả dụng, trả về data hardcoded
  Stream<List<Movie>> getMoviesStream() async* {
    if (_firestore == null) {
      yield movies;
      return;
    }

    try {
      yield* _firestore!.collection('movies').snapshots().map((snapshot) {
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
    if (_firestore == null) {
      return movies;
    }

    try {
      final snapshot = await _firestore!.collection('movies').get();
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
    if (_firestore == null) {
      return movies.firstWhere((m) => m.id.toString() == id, orElse: () => movies.first);
    }

    try {
      final doc = await _firestore!.collection('movies').doc(id).get();
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

    if (_firestore == null) {
      allMovies = movies;
    } else {
      try {
        final snapshot = await _firestore!.collection('movies').get();
        allMovies = snapshot.docs
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

    if (_firestore == null) {
      allMovies = movies;
    } else {
      try {
        final snapshot = await _firestore!.collection('movies').get();
        allMovies = snapshot.docs
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
    if (_firestore != null) {
      await _firestore!.collection('movies').add(movie.toJson());
    }
  }

  /// Cập nhật phim
  Future<void> updateMovie(String id, Movie movie) async {
    if (_firestore != null) {
      await _firestore!.collection('movies').doc(id).update(movie.toJson());
    }
  }

  /// Xóa phim
  Future<void> deleteMovie(String id) async {
    if (_firestore != null) {
      await _firestore!.collection('movies').doc(id).delete();
    }
  }
}
