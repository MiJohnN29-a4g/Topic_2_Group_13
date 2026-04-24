class Episode {
  final int number;
  final String title;
  final String? description;
  final String? duration;

  Episode({
    required this.number,
    required this.title,
    this.description,
    this.duration,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      number: json['number'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      duration: json['duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'title': title,
      'description': description,
      'duration': duration,
    };
  }
}

class Movie {
  final int id;
  final String title;
  final String poster;
  final String backdrop;
  final String description;
  final String year;
  final String genre;
  final String rating;
  final String trailerKey; // YouTube video key
  final List<Episode> episodes; // empty = movie, filled = series

  // Thông tin mở rộng (optional - có giá trị default)
  final String? director;      // Đạo diễn
  final List<String>? cast;    // Diễn viên chính
  final String? country;       // Quốc gia sản xuất
  final String? duration;      // Thời lượng (phút) - cho movie
  final String? studio;        // Hãng sản xuất
  final int? views;            // Lượt xem
  final String? contentRating; // Phân loại độ tuổi (P, C13, C18)

  Movie({
    required this.id,
    required this.title,
    required this.poster,
    required this.backdrop,
    required this.description,
    required this.year,
    required this.genre,
    required this.rating,
    required this.trailerKey,
    required this.episodes,
    this.director,
    this.cast,
    this.country,
    this.duration,
    this.studio,
    this.views,
    this.contentRating,
  });

  bool get isSeries => episodes.isNotEmpty;

  // Helper để kiểm tra có thông tin mở rộng không
  bool get hasExtendedInfo => director != null || cast != null || country != null;

  factory Movie.fromJson(Map<String, dynamic> json, String id) {
    return Movie(
      id: int.tryParse(id) ?? 0,
      title: json['title'] ?? '',
      poster: json['poster'] ?? '',
      backdrop: json['backdrop'] ?? '',
      description: json['description'] ?? '',
      year: json['year'] ?? '',
      genre: json['genre'] ?? '',
      rating: json['rating'] ?? '',
      trailerKey: json['trailerKey'] ?? '',
      episodes: (json['episodes'] as List<dynamic>?)
              ?.map((e) => Episode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      director: json['director'],
      cast: json['cast'] != null
          ? List<String>.from(json['cast'])
          : null,
      country: json['country'],
      duration: json['duration'],
      studio: json['studio'],
      views: json['views'],
      contentRating: json['contentRating'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster': poster,
      'backdrop': backdrop,
      'description': description,
      'year': year,
      'genre': genre,
      'rating': rating,
      'trailerKey': trailerKey,
      'episodes': episodes.map((e) => e.toJson()).toList(),
      'director': director,
      'cast': cast,
      'country': country,
      'duration': duration,
      'studio': studio,
      'views': views,
      'contentRating': contentRating,
    };
  }
}